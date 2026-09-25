extends SceneTree

var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("test")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ",label)
	else: print("PASS: ",label)

func profile() -> Dictionary:
	var data = SaveStore.new("res://tests/idle_unused.json").data
	Duplication.register_heist(data,"laboratory",["lab_microscope","lab_quantum_core","fridge"])
	return data

func test() -> void:
	LocalLog.enabled = false
	var data = SaveStore.new("res://tests/idle_unused.json").data
	check(not Duplication.start(data,0,"lab_microscope",1000),"Locked lab cannot start")
	Duplication.register_heist(data,"apartment",["fridge"])
	check(not data.duplication.unlocked and "fridge" in data.duplication.known,"Earlier stolen originals become blueprints without unlocking the lab")
	Duplication.register_heist(data,"laboratory",[])
	check(not data.duplication.unlocked,"An empty lab escape does not unlock technology")
	data = profile()
	check(data.duplication.unlocked and not data.duplication.has("charges"),"Lab unlocks autonomous production without scans")
	check(not Duplication.start(data,0,"time_machine",1000),"Unknown blueprints cannot start")
	check(not Duplication.start(data,-1,"fridge",1000) and not Duplication.start(data,1,"fridge",1000),"Invalid and locked chambers cannot start")
	check(Duplication.start(data,0,"lab_microscope",1000),"First automatic cycle starts")
	check(not Duplication.start(data,0,"lab_microscope",1001),"Repeated start cannot reset or duplicate a job")
	check(Duplication.claim(data,0,1019) == 0,"Nothing paid before the exact first cycle")
	check(Duplication.claim(data,0,1020) == 40 and data.wallet == 40,"First microscope replica pays $40 after 20 seconds")
	check(Duplication.claim(data,0,1020) == 0,"Collect cannot pay twice")
	check(Duplication.claim(data,0,1045) == 40 and data.duplication.jobs[0].progress == 5,"Cycles restart automatically and partial progress survives collect")
	check(Duplication.claim(data,0,1059) == 0 and Duplication.claim(data,0,1060) == 40,"Frequent claims do not delay or accelerate the next cycle")
	Duplication.settle(data,2000)
	check(data.duplication.jobs[0].stored == 3 and data.duplication.jobs[0].progress == 0,"Long absence fills only three copies, then pauses")
	check(not Duplication.start(data,0,"fridge",2000),"Blueprint swap cannot erase stored rewards")
	check(Duplication.claim(data,0,2000) == 120,"Offline payout is capped at actual buffer contents")
	check(Duplication.claim(data,0,2019) == 0 and Duplication.claim(data,0,2020) == 40,"No hidden offline backlog bursts after collect")
	Duplication.settle(data,2025)
	check(Duplication.start(data,0,"fridge",2025) and data.duplication.jobs[0].progress == 0,"Changing blueprint explicitly restarts the cycle")
	check(Duplication.claim(data,0,2020) == 0 and not Duplication.start(data,0,"lab_microscope",2020),"Clock rollback cannot pay or reset the high-water mark")
	check(Duplication.claim(data,0,2025+Duplication.duration("fridge")) == Duplication.copy_value("fridge"),"Clock catches up without double accrual")
	data.wallet = 1199
	check(not Duplication.upgrade(data),"Cannot buy a chamber without its full cost")
	data.wallet = 3600
	check(Duplication.upgrade(data) and data.wallet == 2400 and Duplication.upgrade(data) and data.wallet == 0,"Chambers cost exactly $1,200 and $2,400")
	check(not Duplication.upgrade(data) and data.duplication.slot_level == 3,"Three chambers is the limit")
	check(Duplication.start(data,1,"lab_quantum_core",3000) and Duplication.start(data,2,"lab_quantum_core",3000),"Additional chambers run concurrently")
	check(Duplication.claim(data,1,3034) == 174 and Duplication.claim(data,2,3034) == 174,"Quantum Core replica pays $174 every 34 seconds in each chamber")
	# Persistence retains fractional-cycle time and unclaimed copies.
	var save = SaveStore.new("res://tests/idle_roundtrip.json")
	save.data = profile()
	Duplication.start(save.data,0,"lab_quantum_core",4000)
	Duplication.settle(save.data,4040)
	check(save.save_progress(),"Idle state saves successfully")
	var restored = SaveStore.new(save.path)
	restored.load_progress()
	check(restored.data.duplication.jobs[0].stored == 1 and restored.data.duplication.jobs[0].progress == 6,"Reload preserves accrued copies and partial progress")
	check(Duplication.claim(restored.data,0,4068) == 348,"Offline time across restart completes the next cycle exactly")
	# Genuine schema-8 save migration, including backups and one-time compensation.
	var legacy = SaveStore.new("res://tests/idle_schema8.json")
	var old = legacy.defaults()
	old.schema_version = 8
	old.wallet = 700
	old.duplication = {"unlocked":true,"charges":2,"slot_level":2,"known":["lab_microscope"],"jobs":[{"type_id":"lab_microscope","ready_at":int(Time.get_unix_time_from_system())+10},{},{}]}
	var file = FileAccess.open(legacy.path,FileAccess.WRITE)
	file.store_string(JSON.stringify(old)); file.close()
	legacy.load_progress()
	check(legacy.data.schema_version == SaveStore.SCHEMA and legacy.data.wallet == 800 and FileAccess.file_exists(legacy.path+".schema8.bak"),"Schema 8 is backed up; unused scans convert once at $50 each")
	legacy.load_progress()
	check(legacy.data.wallet == 800,"Migration compensation cannot pay twice")
	var migrated = profile()
	migrated.duplication = Duplication.validate(old.duplication,1000)
	migrated.duplication.jobs[0].legacy_ready_at = 1010
	migrated.duplication.jobs[0].last_at = 1010
	check(Duplication.claim(migrated,0,1009) == 0 and Duplication.claim(migrated,0,1010) == 200,"Existing in-flight copy retains its promised full original value")
	check(Duplication.claim(migrated,0,1010) == 0 and Duplication.claim(migrated,0,1030) == 40,"Legacy reward settles once, then normal idle pricing applies")
	var bad = Duplication.validate({"unlocked":true,"slot_level":3,"known":["bad","fridge","fridge"],"jobs":[{"type_id":"bad"},{"type_id":"fridge","stored":999,"progress":999,"last_at":1000},{}],"version":2},1000)
	check(bad.known == ["fridge"] and bad.jobs[0].is_empty() and bad.jobs[1].stored == 3 and bad.jobs[1].progress < Duplication.duration("fridge"),"Malformed jobs and counters are bounded during load")
	var pawn = legacy.validate({"schema_version":7,"wallet":100,"loot_economy":{"pending":[{"type_id":"lab_microscope"}],"kept":[{"type_id":"lab_analyzer"}],"shelves":[{"type_id":"lab_microscope","price":300}],"register":50}})
	check(pawn.wallet == 1000 and legacy.validate(pawn).wallet == 1000,"Old pawn compensation still migrates exactly once")
	# Exhaustive formula and 24-hour simulations for every selectable item.
	var all_bound = true
	var all_fast = true
	var all_offline = true
	var report = FileAccess.open("res://tests/duplication_idle_economy.csv",FileAccess.WRITE)
	report.store_csv_line(PackedStringArray(["type","source","original","seconds","replica","one_slot_per_min","three_slots_per_min","benchmark_per_min","three_slot_share_pct","buffer_cash_3_slots","chamber2_payback_min","chamber3_payback_min"]))
	for id in Balance.ITEMS:
		var cycle = Duplication.duration(id)
		var value = Duplication.copy_value(id)
		var rate = float(value)/cycle
		all_bound = all_bound and rate <= Duplication.benchmark(id)*0.06+0.00001 and value <= int(Balance.ITEMS[id].cash_value)*0.2
		all_fast = all_fast and cycle >= 20 and cycle <= 45
		var sim = profile()
		if id not in sim.duplication.known: sim.duplication.known.append(id)
		sim.duplication.slot_level = 3
		for slot in range(3): Duplication.start(sim,slot,id,1000)
		var paid = 0
		for slot in range(3): paid += Duplication.claim(sim,slot,1000+86400)
		all_offline = all_offline and paid == value*9
		report.store_csv_line(PackedStringArray([id,Duplication.source_location(id),str(Balance.ITEMS[id].cash_value),str(cycle),str(value),str(rate*60),str(rate*180),str(Duplication.benchmark(id)*60),str(rate*3/Duplication.benchmark(id)*100),str(value*9),str(1200/(rate*60)),str(2400/(rate*60))]))
	report.close()
	check(all_bound,"Every blueprint obeys the 6%/chamber rate ceiling and 20% replica price ceiling")
	check(all_fast,"Every first copy completes in 20–45 seconds")
	check(all_offline,"Every blueprint is capped at nine stored copies total even after 24 hours")
	# Active collection over 30 minutes cannot escape the sustained rate ceiling.
	var sim = profile()
	sim.duplication.slot_level = 3
	for slot in range(3): Duplication.start(sim,slot,"lab_quantum_core",1000)
	for second in range(1,1801):
		for slot in range(3): Duplication.claim(sim,slot,1000+second)
	check(sim.wallet <= floori(Duplication.benchmark("lab_quantum_core")*0.18*1800),"30-minute frequent collecting stays under 18% of the full-haul benchmark")
	print("IDLE ECONOMY core: $174 / 34s; 3 slots $",174.0/34*180," per minute; buffer $",174*9)
	print("DUPLICATION IDLE: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
