class_name Duplication
extends RefCounted

# Automatic, bounded production. Each chamber earns <=6% of the source map's
# full-haul/time benchmark. Three chambers together cannot exceed 18% of the
# highest benchmark represented by their blueprints. This is not a novice KPI.
const MAX_SLOTS := 3
const BUFFER_COPIES := 3
const SLOT_COSTS := [1200, 2400]
const RATE_SHARE := 0.06
const REPLICA_SHARE := 0.20
const SCAN_REFUND := 50
const MAX_TIME := 4102444800

static func defaults() -> Dictionary:
	return {"version":2,"unlocked":false,"slot_level":1,"known":[],"jobs":[{},{},{}]}

static func bounded(value: Variant, low: int, high: int) -> int:
	if not (value is int or value is float) or not is_finite(float(value)): return low
	return clampi(int(value),low,high)

static func source_location(type_id: String) -> String:
	for location in Balance.LOCATION_ORDER:
		for item in Balance.LOCATIONS[location].items:
			if item[1] == type_id: return location
	return "laboratory"

static func benchmark(type_id: String) -> float:
	var location = source_location(type_id)
	# Security adds a small reaction-time allowance, not an idle economy nerf.
	var config: Dictionary = Balance.LOCATIONS[location]
	return float(Balance.totals(location).value) / float(config.get("economy_duration",config.duration))

static func duration(type_id: String) -> int:
	if not Balance.ITEMS.has(type_id): return 0
	return clampi(18 + ceili(float(Balance.ITEMS[type_id].cash_value)/100.0),20,45)

static func copy_value(type_id: String) -> int:
	if not Balance.ITEMS.has(type_id): return 0
	return maxi(1,mini(floori(float(Balance.ITEMS[type_id].cash_value)*REPLICA_SHARE),floori(benchmark(type_id)*RATE_SHARE*duration(type_id))))

static func validate(raw: Variant, now: int = -1) -> Dictionary:
	if now < 0: now = int(Time.get_unix_time_from_system())
	var clean = defaults()
	if not raw is Dictionary: return clean
	clean.unlocked = raw.get("unlocked",false) == true
	clean.slot_level = bounded(raw.get("slot_level",1),1,MAX_SLOTS)
	var known = raw.get("known",[])
	if known is Array:
		for id in known:
			if id is String and Balance.ITEMS.has(id) and id not in clean.known: clean.known.append(id)
	var jobs = raw.get("jobs",[])
	if jobs is Array and clean.unlocked:
		for i in range(mini(clean.slot_level,jobs.size())):
			if not jobs[i] is Dictionary: continue
			var id = str(jobs[i].get("type_id",""))
			if id not in clean.known: continue
			if bounded(raw.get("version",1),1,2) < 2:
				# Preserve the old full-value paid-for copy, with no retroactive loops.
				var ready = bounded(jobs[i].get("ready_at",now),1,MAX_TIME)
				clean.jobs[i] = {"type_id":id,"last_at":maxi(now,ready),"progress":0,"stored":0,"legacy_ready_at":ready,"legacy_value":int(Balance.ITEMS[id].cash_value)}
			else:
				clean.jobs[i] = {"type_id":id,"last_at":bounded(jobs[i].get("last_at",now),1,MAX_TIME),"progress":bounded(jobs[i].get("progress",0),0,duration(id)-1),"stored":bounded(jobs[i].get("stored",0),0,BUFFER_COPIES),"legacy_ready_at":bounded(jobs[i].get("legacy_ready_at",0),0,MAX_TIME),"legacy_value":bounded(jobs[i].get("legacy_value",0),0,int(Balance.ITEMS[id].cash_value))}
	return clean

static func register_heist(data: Dictionary, location: String, type_ids: Array) -> void:
	var machine: Dictionary = data.duplication
	# Learn genuine stolen originals, including those secured before recovery.
	for id in type_ids:
		if Balance.ITEMS.has(id) and id not in machine.known: machine.known.append(id)
	if location == "laboratory" and not type_ids.is_empty(): machine.unlocked = true

static func settle(data: Dictionary, now: int) -> void:
	var machine: Dictionary = data.duplication
	if not machine.unlocked: return
	for i in range(int(machine.slot_level)):
		var job: Dictionary = machine.jobs[i]
		if job.is_empty() or now <= int(job.last_at): continue
		var elapsed = now - int(job.last_at)
		job.last_at = now
		if int(job.stored) >= BUFFER_COPIES:
			job.progress = 0
			continue
		var cycle = duration(job.type_id)
		var total = int(job.progress) + elapsed
		var completed = total / cycle
		job.stored = mini(BUFFER_COPIES,int(job.stored)+int(completed))
		# Full storage pauses the machine; no hidden backlog survives collection.
		job.progress = 0 if int(job.stored) >= BUFFER_COPIES else total % cycle

static func available_cash(job: Dictionary, now: int) -> int:
	if job.is_empty(): return 0
	var legacy = int(job.get("legacy_value",0)) if now >= int(job.get("legacy_ready_at",0)) else 0
	return int(job.stored)*copy_value(job.type_id) + legacy

static func seconds_left(job: Dictionary, now: int) -> int:
	if job.is_empty() or int(job.stored) >= BUFFER_COPIES: return 0
	return maxi(0,int(job.last_at)-now) + duration(job.type_id)-int(job.progress)

static func start(data: Dictionary, slot: int, type_id: String, now: int) -> bool:
	var machine: Dictionary = data.duplication
	if not machine.unlocked or slot < 0 or slot >= int(machine.slot_level): return false
	if type_id not in machine.known or not Balance.ITEMS.has(type_id): return false
	settle(data,now)
	var old: Dictionary = machine.jobs[slot]
	if not old.is_empty():
		if int(old.stored) > 0 or int(old.get("legacy_value",0)) > 0 or old.type_id == type_id or now < int(old.last_at): return false
	machine.jobs[slot] = {"type_id":type_id,"last_at":now,"progress":0,"stored":0,"legacy_ready_at":0,"legacy_value":0}
	return true

static func claim(data: Dictionary, slot: int, now: int) -> int:
	var machine: Dictionary = data.duplication
	if not machine.unlocked or slot < 0 or slot >= int(machine.slot_level): return 0
	settle(data,now)
	var job: Dictionary = machine.jobs[slot]
	var earned = available_cash(job,now)
	if earned <= 0: return 0
	job.stored = 0
	if now >= int(job.get("legacy_ready_at",0)): job.legacy_value = 0
	data.wallet += earned
	return earned

static func upgrade(data: Dictionary) -> bool:
	var machine: Dictionary = data.duplication
	var level = int(machine.slot_level)
	if not machine.unlocked or level >= MAX_SLOTS or data.wallet < SLOT_COSTS[level-1]: return false
	data.wallet -= SLOT_COSTS[level-1]
	machine.slot_level += 1
	return true
