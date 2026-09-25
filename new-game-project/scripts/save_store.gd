class_name SaveStore
extends RefCounted

signal appearance_changed

const SCHEMA = 16
const DAILY_GIFT_COOLDOWN := 86400
var data: Dictionary
var path = "user://progress.json"
var last_error = ""
var notice = ""
var read_only = false
var session_only = false
var dev_rewards_unlimited := false
var wheel_ledger_path = ""
var initial_special_interval = SpecialJobs.roll_interval()

func _init(custom_path: String = "user://progress.json") -> void:
	path = custom_path
	wheel_ledger_path = custom_path + ".daily"
	data = defaults()

func defaults() -> Dictionary:
	var clean = {"schema_version": SCHEMA, "wallet": 0, "diamonds": 0, "daily_spin_day": -1, "wheel_jackpots": [], "daily_gift_last_at": -1, "daily_gift_claims": 0, "upgrades": {"strength": 1, "grip": 1, "carry": 1, "capacity": 1, "noise": 1}, "objectives": {}, "unlocked": ["apartment"], "trophies": [], "rare_loot": [], "bonuses": [], "contracts": {}, "contract_bonuses": [], "records": {}, "cosmetics": {"owned": [], "equipped": {"van": "", "suit": "", "set": ""}}, "successes": 0, "failures": 0, "mode_stats": {}, "duplication": Duplication.defaults()}
	for location in Balance.LOCATION_ORDER:
		clean.objectives[location] = {"cash": false, "signature": false, "full_clear": false}
	for id in Balance.CONTRACTS: clean.contracts[id] = false
	for mode in Balance.MODES:
		clean.records[mode] = {}
		clean.mode_stats[mode] = {"successes": 0, "failures": 0}
	clean.merge({"runs_since_special":0, "special_interval":initial_special_interval, "special_pending":false, "special_type":SpecialJobs.DEFAULT_TYPE, "special_location_id":"", "special_in_progress":false})
	clean.merge({"tutorial_completed": false, "noise_tutorial_completed": false,"heist_briefing_seen":false})
	clean.first_job_at = 0
	clean.garage_owned = []
	clean.level_gifts = {}
	clean.lucky_pending = {}
	clean.merge({"apartment_final_job_completed": false, "museum_final_job_completed": false})
	return clean

func load_progress() -> void:
	if session_only:
		data = defaults()
		return
	last_error = ""
	notice = ""
	read_only = false
	for candidate in [path, path + ".bak"]:
		if not FileAccess.file_exists(candidate): continue
		var file = FileAccess.open(candidate, FileAccess.READ)
		if file == null: continue
		var parsed = parse_json(file.get_as_text())
		file.close()
		if not parsed is Dictionary or not parsed.has("schema_version"): continue
		var schema = number(parsed.schema_version, -1, 999)
		if schema not in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, SCHEMA]:
			read_only = true
			last_error = "Unsupported save schema. Original file preserved; saving disabled."
			return
		if candidate.ends_with(".bak") and FileAccess.file_exists(path):
			DirAccess.copy_absolute(path, path + ".corrupt")
		if schema in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]:
			var backup = candidate + ".schema%d.bak" % schema
			if not FileAccess.file_exists(backup):
				var copy_error = DirAccess.copy_absolute(candidate, backup)
				if copy_error != OK:
					read_only = true
					write_error("migration backup", copy_error)
					return
			data = validate(parsed if schema >= 4 else migrate_v3(migrate_v2(parsed) if schema == 2 else parsed))
			if save_progress(): notice = "Save updated. Existing progress retained." if schema >= 4 else "Save upgraded to V2. Progress retained; Grip/Carry/Van mapped to 20 levels. Noise starts at 1. Levels above tier remain active (grandfathered). No retroactive costs."
			else: notice = "Migration is in memory only; disk save failed. Original backup preserved."
		else: data = validate(parsed)
		if data.special_in_progress:
			SpecialJobs.consume(data)
			notice = "Interrupted Special Job ended. Your secured progress is preserved."
			save_progress()
		elif not parsed.has("special_interval") or not parsed.has("runs_since_special") or not parsed.has("tutorial_completed"):
			save_progress()
		load_daily_ledger()
		if candidate.ends_with(".bak"):
			notice = "Recovered progress from backup. Damaged save preserved as .corrupt."
		return
	if FileAccess.file_exists(path):
		var error = DirAccess.copy_absolute(path, path + ".corrupt")
		if error != OK:
			read_only = true
			write_error("corrupt backup", error)
			return
		notice = "Unreadable save preserved as .corrupt. Started a fresh profile."
	data = defaults()
	load_daily_ledger()
	save_progress()

func migrate_v2(raw: Dictionary) -> Dictionary:
	var migrated = raw.duplicate(true)
	migrated.schema_version = SCHEMA
	migrated.objectives = {}
	var old_objectives = raw.get("objectives", {})
	if old_objectives is Dictionary:
		for location in ["apartment", "house"]:
			var values = old_objectives.get(location, [])
			if values is Array:
				migrated.objectives[location] = {}
				for i in range(mini(3, values.size())):
					migrated.objectives[location][Balance.OBJECTIVE_IDS[i]] = values[i] == true
	migrated.records = {"normal": raw.get("records", {})}
	migrated.mode_stats = {"normal": {"successes": raw.get("successes", 0), "failures": raw.get("failures", 0)}}
	# Only these four explicitly compatible named upgrade categories are validated.
	# No bag/inventory categories are mapped, and no new-price difference is charged.
	return migrated

func number(value: Variant, low: int, high: int) -> int:
	if not value is int and not value is float: return low
	if not is_finite(float(value)): return low
	return clampi(int(value), low, high)

func dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

func unique_ids(value: Variant, allowed: Array) -> Array:
	var output: Array = []
	if value is Array:
		for id in value:
			if id is String and id in allowed and id not in output: output.append(id)
	return output

func validate(raw: Dictionary) -> Dictionary:
	var clean = defaults()
	var lucky := dictionary(raw.get("lucky_pending",{}))
	if LuckyEffects.CATALOG.has(lucky.get("id","")):
		clean.lucky_pending = {"id":str(lucky.id),"seen":lucky.get("seen",false) == true}
	clean.garage_owned = unique_ids(raw.get("garage_owned", []), GarageDecor.CATALOG.keys())
	for key in ["wallet", "successes", "failures"]: clean[key] = number(raw.get(key, 0), 0, 1000000000)
	clean.diamonds = number(raw.get("diamonds", 0), 0, 1000000)
	clean.daily_spin_day = number(raw.get("daily_spin_day", -1), -1, 100000000)
	clean.daily_gift_last_at = number(raw.get("daily_gift_last_at", -1), -1, 4102444800)
	clean.daily_gift_claims = number(raw.get("daily_gift_claims", 0), 0, 100000000)
	var gifts := dictionary(raw.get("level_gifts",{}))
	for location in Balance.LOCATION_ORDER:
		if gifts.get(location) is Dictionary:
			clean.level_gifts[location] = {"rarity":number(gifts[location].get("rarity",0),0,3), "seen":gifts[location].get("seen",false) == true}
	clean.wheel_jackpots = unique_ids(raw.get("wheel_jackpots", []), ["character", "van"])
	var upgrades = dictionary(raw.get("upgrades", {}))
	for key in clean.upgrades: clean.upgrades[key] = number(upgrades.get(key, 1), 1, Balance.max_level(key))
	var objectives = dictionary(raw.get("objectives", {}))
	for location in clean.objectives:
		var values = dictionary(objectives.get(location, {}))
		for id in Balance.OBJECTIVE_IDS: clean.objectives[location][id] = values.get(id, false) == true
	# Existing collections keep their Suburban trophy after the bust became a duck.
	var trophy_ids = raw.get("trophies", [])
	if trophy_ids is Array:
		trophy_ids = trophy_ids.duplicate()
		for i in range(trophy_ids.size()):
			if trophy_ids[i] == "bust": trophy_ids[i] = "duck"
	clean.trophies = unique_ids(trophy_ids, Balance.TROPHIES.keys())
	clean.rare_loot = unique_ids(raw.get("rare_loot", []), LootRarity.all_ids())
	clean.duplication = Duplication.validate(raw.get("duplication", {}))
	if number(raw.get("schema_version", SCHEMA), 0, SCHEMA) < 9:
		var old_machine = dictionary(raw.get("duplication", {}))
		clean.wallet = mini(1000000000,int(clean.wallet)+number(old_machine.get("charges",0),0,12)*Duplication.SCAN_REFUND)
	if number(raw.get("schema_version", SCHEMA), 0, SCHEMA) < 8:
		# Retire Pawn/Hideout without deleting value the player already secured.
		# Pending and kept loot was never paid; shelves and register had earned value.
		var legacy: Dictionary = dictionary(raw.get("loot_economy", {}))
		var compensation: int = number(legacy.get("register", 0), 0, 1000000000)
		for key in ["pending", "kept", "shelves"]:
			var items = legacy.get(key, [])
			if not items is Array: continue
			for item in items:
				if not item is Dictionary: continue
				var type_id := str(item.get("type_id", ""))
				if Balance.ITEMS.has(type_id):
					compensation += number(item.get("price", Balance.ITEMS[type_id].cash_value), 0, 1000000000) if key == "shelves" else int(Balance.ITEMS[type_id].cash_value)
				if type_id not in clean.duplication.known and Balance.ITEMS.has(type_id): clean.duplication.known.append(type_id)
		clean.wallet = mini(1000000000, int(clean.wallet) + compensation)
	clean.bonuses = unique_ids(raw.get("bonuses", []), Balance.LOCATION_ORDER)
	# Valid persisted unlocks remain available even after recovery from an older backup.
	clean.unlocked = unique_ids(raw.get("unlocked", ["apartment"]), Balance.LOCATION_ORDER)
	# Final Job pilot: existing saves that already had Suburban unlocked (under the
	# old 2-objective rule) are grandfathered as having "completed" the Final Job,
	# so nobody who already has House access ever gets relocked.
	clean.apartment_final_job_completed = raw.get("apartment_final_job_completed", "house" in clean.unlocked) == true
	# Chapter 2 requires an explicitly completed Museum finale, including on older saves.
	clean.museum_final_job_completed = raw.get("museum_final_job_completed", false) == true
	var contracts = dictionary(raw.get("contracts", {}))
	for id in Balance.CONTRACTS: clean.contracts[id] = contracts.get(id, false) == true
	clean.contract_bonuses = unique_ids(raw.get("contract_bonuses", []), Balance.CONTRACTS.keys())
	var records = dictionary(raw.get("records", {}))
	var stats = dictionary(raw.get("mode_stats", {}))
	for mode in Balance.MODES:
		var mode_records = dictionary(records.get(mode, {}))
		for location in Balance.LOCATION_ORDER:
			var value = mode_records.get(location, 0)
			# Pyramid (Chapter 2) ships without mastery contracts yet: no contract, no record.
			if mode not in ["normal", "FINAL_JOB", SpecialJobs.MODE] and not Balance.CONTRACTS.has(location + "." + mode): continue
			var limit = Balance.LOCATIONS[location].duration if mode in ["normal", "FINAL_JOB"] else (SpecialJobs.definition(SpecialJobs.DEFAULT_TYPE).time_override if mode == SpecialJobs.MODE else Balance.CONTRACTS[location + "." + mode].duration)
			if (value is float or value is int) and is_finite(float(value)) and value > 0 and value <= limit:
				clean.records[mode][location] = float(value)
		var mode_stats = dictionary(stats.get(mode, {}))
		for key in ["successes", "failures"]: clean.mode_stats[mode][key] = number(mode_stats.get(key, 0), 0, 1000000000)
	var cosmetics = dictionary(raw.get("cosmetics", {}))
	clean.cosmetics.owned = unique_ids(cosmetics.get("owned", []), Balance.COSMETICS.keys())
	var equipped = dictionary(cosmetics.get("equipped", {}))
	for slot in clean.cosmetics.equipped:
		var id = equipped.get(slot, "")
		if id in clean.cosmetics.owned and Balance.COSMETICS[id].slot == slot: clean.cosmetics.equipped[slot] = id
	Progression.refresh(clean)
	clean.special_interval = number(raw.get("special_interval", initial_special_interval), 2, 4)
	clean.runs_since_special = number(raw.get("runs_since_special", 0), 0, clean.special_interval)
	var pending_location = raw.get("special_location_id", "")
	var pending_type = raw.get("special_type", SpecialJobs.DEFAULT_TYPE)
	if raw.get("special_pending", false) == true and pending_location in clean.unlocked and pending_type in SpecialJobs.DEFINITIONS:
		clean.special_pending = true
		clean.special_location_id = pending_location
		clean.special_type = pending_type
		clean.runs_since_special = clean.special_interval
		clean.special_in_progress = raw.get("special_in_progress", false) == true
	# Missing flags identify legacy data. Infer experience from permanent progress,
	# never from the mere existence of a file (fresh old profiles still onboard).
	var experienced = has_real_progress(clean)
	clean.tutorial_completed = raw.get("tutorial_completed", experienced) == true
	clean.noise_tutorial_completed = clean.tutorial_completed and raw.get("noise_tutorial_completed", experienced) == true
	clean.heist_briefing_seen = raw.get("heist_briefing_seen",int(clean.successes) > 0 or int(clean.failures) > 0) == true
	clean.first_job_at = number(raw.get("first_job_at", 1 if experienced else 0), 0, 4102444800)
	if clean.objectives.laboratory.cash or clean.objectives.laboratory.signature or clean.objectives.laboratory.full_clear or clean.records.normal.has("laboratory"):
		clean.duplication.unlocked = true
	return clean

func has_real_progress(profile: Dictionary) -> bool:
	if not profile.get("garage_owned",[]).is_empty(): return true
	if profile.wallet > 0 or profile.successes > 0 or profile.failures > 0: return true
	if profile.duplication.unlocked or not profile.duplication.known.is_empty(): return true
	if profile.unlocked.size() > 1 or not profile.trophies.is_empty() or not profile.cosmetics.owned.is_empty(): return true
	if profile.special_pending or profile.runs_since_special > 0: return true
	for value in profile.upgrades.values():
		if value > 1: return true
	for objectives in profile.objectives.values():
		if true in objectives.values(): return true
	if true in profile.contracts.values(): return true
	for records in profile.records.values():
		if not records.is_empty(): return true
	return not profile.bonuses.is_empty() or not profile.contract_bonuses.is_empty()

func load_daily_ledger() -> void:
	if session_only or not FileAccess.file_exists(wheel_ledger_path): return
	var file := FileAccess.open(wheel_ledger_path, FileAccess.READ)
	if file == null: return
	var parsed = parse_json(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		data.daily_spin_day = maxi(int(data.daily_spin_day), number(parsed.get("last_day", -1), -1, 100000000))
		data.daily_gift_last_at = maxi(int(data.daily_gift_last_at), number(parsed.get("gift_last_at", -1), -1, 4102444800))
		data.daily_gift_claims = maxi(int(data.daily_gift_claims), number(parsed.get("gift_claims", 0), 0, 100000000))
		if parsed.has("diamonds"): data.diamonds = number(parsed.diamonds, 0, 1000000)
		if parsed.has("tickets"): data.wheel_jackpots = unique_ids(parsed.tickets, ["character", "van"])

func write_daily_ledger() -> void:
	if session_only or dev_rewards_unlimited: return
	var ledger := FileAccess.open(wheel_ledger_path, FileAccess.WRITE)
	if ledger == null: return
	ledger.store_string(JSON.stringify({"last_day":data.daily_spin_day, "diamonds":data.diamonds, "tickets":data.wheel_jackpots, "gift_last_at":data.daily_gift_last_at, "gift_claims":data.daily_gift_claims}))
	ledger.close()

func daily_spin_available(now: int = -1) -> bool:
	if read_only: return false
	if dev_rewards_unlimited: return true
	if now < 0: now = int(Time.get_unix_time_from_system())
	return DailyWheel.utc_day(now) > int(data.daily_spin_day)

func claim_daily_spin(now: int = -1, draw: int = -1) -> Dictionary:
	if now < 0: now = int(Time.get_unix_time_from_system())
	if not daily_spin_available(now): return {}
	var prize := DailyWheel.choose(data, draw)
	if prize.is_empty(): return {}
	var previous := data.duplicate(true)
	DailyWheel.award(data, prize, DailyWheel.utc_day(now))
	if not save_progress():
		data = previous
		return {}
	write_daily_ledger()
	return prize

func daily_gift_remaining(now: int = -1) -> int:
	if dev_rewards_unlimited: return 0
	if now < 0: now = int(Time.get_unix_time_from_system())
	if int(data.daily_gift_last_at) < 0: return 0
	return maxi(0, int(data.daily_gift_last_at) + DAILY_GIFT_COOLDOWN - now)

func claim_daily_gift(now: int = -1) -> Dictionary:
	if read_only or daily_gift_remaining(now) > 0: return {}
	if now < 0: now = int(Time.get_unix_time_from_system())
	var previous := data.duplicate(true)
	var diamonds := 2 if (int(data.daily_gift_claims) + 1) % 4 == 0 else 1
	data.wallet = mini(1000000000, int(data.wallet) + 300)
	data.diamonds = mini(1000000, int(data.diamonds) + diamonds)
	data.daily_gift_last_at = now
	data.daily_gift_claims = mini(100000000, int(data.daily_gift_claims) + 1)
	if not save_progress():
		data = previous
		return {}
	write_daily_ledger()
	return {"cash": 300, "diamonds": diamonds}

func save_progress() -> bool:
	if session_only:
		last_error = ""
		return true
	if read_only:
		last_error = "SAVE DISABLED: existing save requires a compatible migration."
		return false
	var temp = path + ".tmp"
	var file = FileAccess.open(temp, FileAccess.WRITE)
	if file == null: return write_error("open", FileAccess.get_open_error())
	file.store_string(JSON.stringify(data, "\t", true, true))
	file.flush()
	var error = file.get_error()
	file.close()
	if error != OK: return write_error("write", error)
	if FileAccess.file_exists(path):
		var old = FileAccess.open(path, FileAccess.READ)
		var raw: Variant = parse_json(old.get_as_text()) if old != null else null
		if old != null: old.close()
		if raw is Dictionary and number(raw.get("schema_version", 0), -1, 999) in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, SCHEMA]:
			error = DirAccess.copy_absolute(path, path + ".bak")
			if error != OK: return write_error("backup", error)
	error = DirAccess.rename_absolute(temp, path)
	if error != OK: return write_error("replace", error)
	last_error = ""
	return true

func write_error(operation: String, error: Error) -> bool:
	last_error = "SAVE FAILED (%s): %s" % [operation, error_string(error)]
	push_error(last_error)
	return false

func parse_json(contents: String) -> Variant:
	var parser = JSON.new()
	if parser.parse(contents) != OK: return null
	return parser.data

func unlocked(location: String) -> bool:
	if location in Balance.LOCATION_ORDER.slice(Balance.LOCATION_ORDER.find("pyramid")) and not Progression.chapter_two_unlocked(data): return false
	return location in data.unlocked

func purchase(key: String, between_rounds: bool) -> bool:
	if not between_rounds or key not in Balance.UPGRADE_KEYS: return false
	var level: int = data.upgrades[key]
	if level >= Balance.max_level(key) or level >= Balance.purchase_cap(key, data): return false
	var cost: int = Balance.upgrade_cost(key, level)
	if data.wallet < cost: return false
	data.wallet -= cost
	data.upgrades[key] += 1
	Progression.refresh(data)
	save_progress()
	return true

func purchase_cosmetic(id: String, between_rounds: bool, now: int = -1, equip_on_purchase: bool = false) -> bool:
	if not between_rounds or id not in Balance.COSMETICS or id in data.cosmetics.owned: return false
	var cosmetic: Dictionary = Balance.COSMETICS[id]
	if id not in PlayRewards.today_shop(now): return false
	if cosmetic.reward != "": return false
	var before := data.duplicate(true)
	var gem_price := int(cosmetic.get("gem_price", 0))
	if gem_price > 0:
		if data.diamonds < gem_price: return false
		data.diamonds -= gem_price
	else:
		if data.wallet < int(cosmetic.price): return false
		data.wallet -= int(cosmetic.price)
	data.cosmetics.owned.append(id)
	if equip_on_purchase and cosmetic.has("vehicle_style"):
		data.cosmetics.equipped.van = id
		data.cosmetics.equipped.set = ""
	if not save_progress():
		data = before
		return false
	if gem_price > 0: write_daily_ledger()
	if equip_on_purchase: appearance_changed.emit()
	return true

func purchase_garage(id: String, between_rounds: bool) -> bool:
	if not between_rounds or id not in GarageDecor.CATALOG or id in data.garage_owned: return false
	var price: int = GarageDecor.CATALOG[id].price
	if data.wallet < price: return false
	var before := data.duplicate(true)
	data.wallet -= price
	data.garage_owned.append(id)
	if not save_progress():
		data = before
		return false
	appearance_changed.emit()
	return true

func equip_cosmetic(id: String, between_rounds: bool) -> bool:
	if not between_rounds or id not in data.cosmetics.owned: return false
	var before: Dictionary = data.cosmetics.equipped.duplicate()
	var slot: String = Balance.COSMETICS[id].slot
	data.cosmetics.equipped[slot] = id
	# Sets replace both outfit and van; equipping an individual piece clears the set.
	if slot == "set":
		data.cosmetics.equipped.van = ""
		data.cosmetics.equipped.suit = ""
	else: data.cosmetics.equipped.set = ""
	if not save_progress():
		data.cosmetics.equipped = before
		return false
	appearance_changed.emit()
	return true

func unequip_cosmetics(between_rounds: bool) -> void:
	if not between_rounds: return
	data.cosmetics.equipped = {"van": "", "suit": "", "set": ""}
	save_progress()
	appearance_changed.emit()


func migrate_v3(raw: Dictionary) -> Dictionary:
	var migrated = raw.duplicate(true)
	migrated.schema_version = SCHEMA
	var old = dictionary(raw.get("upgrades", {}))
	migrated.upgrades = {"strength": number(old.get("strength", 1), 1, 5), "noise": 1}
	for key in ["grip", "carry", "capacity"]:
		var old_max = 6 if key == "capacity" else 5
		var old_level = number(old.get(key, 1), 1, old_max)
		migrated.upgrades[key] = 1 + roundi(float(old_level - 1) / float(old_max - 1) * 19)
	return migrated

