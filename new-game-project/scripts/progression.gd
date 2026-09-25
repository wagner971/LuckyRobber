class_name Progression
extends RefCounted

static func objective_count(data: Dictionary, location: String) -> int:
	var count = 0
	for id in Balance.OBJECTIVE_IDS:
		if data.objectives[location][id]: count += 1
	return count

static func campaign_cleared(data: Dictionary) -> bool:
	return data.get("museum_final_job_completed",false) == true or (objective_count(data, "museum") >= 2 and powerups_ready(data, "museum"))

static func powerups_ready(data: Dictionary, location: String) -> bool:
	var required = Balance.powerup_requirement(location)
	return int(data.upgrades.grip) >= required and int(data.upgrades.carry) >= required

static func powerup_target(data: Dictionary) -> Dictionary:
	var location: String = Balance.LOCATION_ORDER[Balance.unlocked_tier(data)]
	var required = Balance.powerup_requirement(location)
	# Carry first: its first purchase is noticeable on the very next delivery.
	for key in ["carry", "grip"]:
		if int(data.upgrades[key]) < required:
			var label = "Carry Speed" if key == "carry" else "Pickup Speed"
			return {"title":"MOVE FASTER WITH LOOT" if key == "carry" else "PICK UP FASTER", "hint":"Upgrade %s to Level %d" % [label,required], "type_id":"", "upgrade_key":key, "location":location, "required":required}
	return {}

static func upgrades_maxed(data: Dictionary) -> bool:
	for key in Balance.UPGRADE_KEYS:
		if data.upgrades[key] != Balance.max_level(key): return false
	return true

static func contract_count(data: Dictionary) -> int:
	var count = 0
	for id in Balance.CONTRACTS:
		if data.contracts[id]: count += 1
	return count

static func mastery_complete(data: Dictionary) -> bool:
	for location in Balance.LOCATION_ORDER:
		if objective_count(data, location) != 3: return false
	return data.trophies.size() == Balance.TROPHIES.size() and contract_count(data) == Balance.CONTRACTS.size()

static func final_job_unlocked(data: Dictionary) -> bool:
	return objective_count(data, "apartment") >= 2 and powerups_ready(data, "apartment")

static func museum_final_job_unlocked(data: Dictionary) -> bool:
	return objective_count(data, "museum") >= 2 and powerups_ready(data, "museum")

static func chapter_two_unlocked(data: Dictionary) -> bool:
	return data.get("museum_final_job_completed", false) == true

static func refresh(data: Dictionary) -> Array:
	var rewards: Array = []
	# Older campaigns that already reached Museum keep the inserted Laboratory.
	# New campaigns cannot acquire Museum without first passing Laboratory's gate.
	if "museum" in data.unlocked and "laboratory" not in data.unlocked: data.unlocked.append("laboratory")
	# Unlocks are persisted using stable location IDs; prerequisites are the only gate.
	# Pilot exception: House unlocks only once the Apartment Final Job (STEAL
	# EVERYTHING) has been completed, not merely from 2 Apartment objectives.
	# The Museum finale gates the whole second chapter, including saved unlocks.
	if not chapter_two_unlocked(data):
		for location in Balance.LOCATION_ORDER.slice(Balance.LOCATION_ORDER.find("pyramid")):
			data.unlocked.erase(location)
	for i in range(Balance.LOCATION_ORDER.size()):
		var id: String = Balance.LOCATION_ORDER[i]
		var gate: bool = data.get("apartment_final_job_completed", false) == true if id == "house" else (chapter_two_unlocked(data) if id == "pyramid" else (i == 0 or objective_count(data, Balance.LOCATION_ORDER[i - 1]) >= 2))
		if i >= Balance.LOCATION_ORDER.find("pyramid"): gate = gate and chapter_two_unlocked(data)
		if i > 0:
			var previous: String = Balance.LOCATION_ORDER[i-1]
			gate = gate and previous in data.unlocked and powerups_ready(data, previous)
		if gate:
			if id not in data.unlocked: data.unlocked.append(id)
	# Older saves may already contain Museum but not the newly inserted Laboratory.
	# Keep the presentation order stable after adding the missing location.
	var ordered: Array = []
	for id in Balance.LOCATION_ORDER:
		if id in data.unlocked: ordered.append(id)
	data.unlocked = ordered
	for id in Balance.COSMETICS:
		var cosmetic: Dictionary = Balance.COSMETICS[id]
		if cosmetic.reward == "": continue
		var count = data.trophies.size() if cosmetic.reward == "trophies" else contract_count(data)
		if count >= int(cosmetic.target) and id not in data.cosmetics.owned:
			data.cosmetics.owned.append(id)
			rewards.append(id)
	return rewards

static func record(data: Dictionary, mode: String, location: String, elapsed: float) -> void:
	if elapsed < float(data.records[mode].get(location, INF)):
		data.records[mode][location] = elapsed

# Called once, and only by the round authority after it locks the result.
static func settle(data: Dictionary, location: String, mode: String, counts: Dictionary, trophies: Array, value: int, full_clear: bool, elapsed: float, special_type: String = SpecialJobs.DEFAULT_TYPE) -> Dictionary:
	# Loot still pays in full. Career clear, its bonus, and Final Job completion
	# require both power-ups even when settlement is invoked outside the UI.
	full_clear = full_clear and powerups_ready(data, location)
	var result = {"bonus": 0, "contract_bonus": 0, "rush_bonus": 0, "new_objectives": [], "new_trophies": [], "new_cosmetics": [], "unlocked_locations": [], "contract_met": false}
	var old_unlocked: Array = data.unlocked.duplicate()
	for trophy in trophies:
		if trophy in Balance.TROPHIES and trophy not in data.trophies:
			data.trophies.append(trophy)
			result.new_trophies.append(Balance.ITEMS[Balance.TROPHIES[trophy].type_id].display_name)
	if mode in ["normal", SpecialJobs.MODE, "FINAL_JOB"]:
		var config: Dictionary = Balance.LOCATIONS[location]
		var signature: bool = counts.get(config.special, 0) >= 1
		# Dracula's Castle: objective 2 needs every listed signature piece in the same run.
		for type_id in config.get("signature_items", []): signature = signature and counts.get(type_id, 0) >= 1
		var achieved = {"cash": value >= int(config.threshold), "signature": signature, "full_clear": full_clear}
		for id in Balance.OBJECTIVE_IDS:
			if achieved[id] and not data.objectives[location][id]:
				data.objectives[location][id] = true
				result.new_objectives.append(config.objectives[Balance.OBJECTIVE_IDS.find(id)])
				LocalLog.event("objective_completed", {"location": location, "objective": id})
		if full_clear:
			if location not in data.bonuses:
				data.bonuses.append(location)
				result.bonus = Balance.CLEAR_BONUS
			record(data, mode, location, elapsed)
		# Apartment Final Job: completion is its own persisted flag (not merely
		# the "full_clear" objective, which a plain NORMAL run could also set),
		# since only a genuine FINAL_JOB-mode clear should unlock Suburban.
		if mode == "FINAL_JOB" and location == "apartment" and full_clear and data.get("apartment_final_job_completed", false) != true:
			data.apartment_final_job_completed = true
			result.final_job_completed = true
		if mode == "FINAL_JOB" and location == "museum" and full_clear and counts.get("time_machine", 0) >= 1 and data.get("museum_final_job_completed", false) != true:
			data.museum_final_job_completed = true
			result.final_job_completed = true
			result.time_machine_stolen = true
	else:
		var contract_id = location + "." + mode
		result.contract_met = Balance.contract_met(contract_id, value, counts)
		if result.contract_met:
			data.contracts[contract_id] = true
			if contract_id not in data.contract_bonuses:
				result.contract_bonus = Balance.CONTRACTS[contract_id].bonus
				data.contract_bonuses.append(contract_id)
				LocalLog.event("contract_completed", {"contract": contract_id})
			record(data, mode, location, elapsed)
	if mode in ["normal", SpecialJobs.MODE, "FINAL_JOB"]:
		result.level_gift = LevelGifts.settle(data,location,full_clear)
	if mode == SpecialJobs.MODE: result.rush_bonus = SpecialJobs.bonus(value, special_type)
	data.wallet += value + result.bonus + result.contract_bonus + result.rush_bonus
	result.new_cosmetics = refresh(data)
	for id in data.unlocked:
		if id not in old_unlocked:
			result.unlocked_locations.append(id)
			LocalLog.event("location_unlocked", {"location": id})
	return result

static func next_goal(data: Dictionary) -> String:
	var powerup = powerup_target(data)
	if not powerup.is_empty(): return "NEXT GOAL · " + str(powerup.hint) + " to clear " + str(Balance.LOCATIONS[powerup.location].name)
	if mastery_complete(data):
		return "MASTERY COMPLETE · This version is complete. Replay for records or optional cosmetics."
	var maxed = upgrades_maxed(data)
	if museum_final_job_unlocked(data) and not data.get("museum_final_job_completed", false):
		return "NEXT GOAL · STEAL EVERYTHING IN MUSEUM TO OPEN CHAPTER 2"
	# Chapter 2: once Pyramid / Dracula's Castle open, their cash/signature goals lead like any campaign stop.
	var chapter_two_open := false
	for location in Balance.LOCATION_ORDER.slice(Balance.LOCATION_ORDER.find("pyramid")):
		if location in data.unlocked and objective_count(data, location) < 2: chapter_two_open = true
	if not campaign_cleared(data) or chapter_two_open:
		for location in Balance.LOCATION_ORDER:
			if location not in data.unlocked: continue
			if objective_count(data, location) >= 2: continue
			var config: Dictionary = Balance.LOCATIONS[location]
			var required: int = Balance.ITEMS[config.special].required_strength
			if not data.objectives[location].signature and data.upgrades.strength < required:
				return "NEXT GOAL · STRENGTH %d for %s in %s" % [required, Balance.ITEMS[config.special].display_name, config.name]
			for id in ["cash", "signature"]:
				if not data.objectives[location][id]:
					return "NEXT GOAL · %s: %s" % [config.name, config.objectives[Balance.OBJECTIVE_IDS.find(id)]]
	if not maxed:
		for key in Balance.UPGRADE_KEYS:
			if data.upgrades[key] < Balance.purchase_cap(key, data):
				return "NEXT GOAL · %s LV %d ($%d), or play a mastery contract" % [Balance.NAMES[key], data.upgrades[key] + 1, Balance.upgrade_cost(key, data.upgrades[key])]
	for location in Balance.LOCATION_ORDER:
		if not data.objectives[location].full_clear: return "NEXT GOAL · FULL CLEAR " + Balance.LOCATIONS[location].name
	for id in Balance.TROPHIES:
		if id not in data.trophies: return "NEXT GOAL · Collect " + Balance.ITEMS[Balance.TROPHIES[id].type_id].display_name
	for id in Balance.CONTRACTS:
		if not data.contracts[id]: return "NEXT GOAL · " + Balance.LOCATIONS[Balance.CONTRACTS[id].location].name + " / " + Balance.CONTRACTS[id].name
	return "NEXT GOAL · Improve your records"

# Short, player-facing objective for the one-screen run result. The Jobs and
# Upgrades pages keep the detailed progression and prices.
static func next_result_target(data: Dictionary) -> Dictionary:
	var powerup = powerup_target(data)
	if not powerup.is_empty() and objective_count(data, powerup.location) >= 1: return powerup
	for location in Balance.LOCATION_ORDER:
		if location not in data.unlocked or objective_count(data, location) >= 2: continue
		var config: Dictionary = Balance.LOCATIONS[location]
		var type_id: String = config.special
		var loot: Dictionary = Balance.ITEMS[type_id]
		if not data.objectives[location].signature:
			var required: int = loot.required_strength
			return {
				"title": "STEAL THE " + str(loot.display_name),
				"hint": "Upgrade Strength to Level %d" % required if data.upgrades.strength < required else "Bring it to the van in " + str(config.name).capitalize(),
				"type_id": type_id
			}
		if not data.objectives[location].cash:
			return {"title": "BANK $%d" % config.threshold, "hint": "Collect more loot in " + str(config.name).capitalize(), "type_id": ""}
	if final_job_unlocked(data) and not data.get("apartment_final_job_completed", false):
		var cargo: int = Balance.LOCATIONS.apartment.expected_cargo
		return {"title": "STEAL EVERYTHING", "hint": "Upgrade the van to fit %d cargo" % cargo if Balance.van_capacity(data.upgrades.capacity) < cargo else "Complete the Apartment Final Job", "type_id": ""}
	if museum_final_job_unlocked(data) and not data.get("museum_final_job_completed", false):
		var museum_cargo: int = Balance.LOCATIONS.museum.expected_cargo
		return {"title": "STEAL THE TIME MACHINE", "hint": "Upgrade the van to fit %d cargo" % museum_cargo if Balance.van_capacity(data.upgrades.capacity) < museum_cargo else "Complete the Museum Final Job", "type_id": "time_machine"}
	for location in Balance.LOCATION_ORDER:
		if not data.objectives[location].full_clear:
			return {"title": "STEAL EVERYTHING", "hint": "Clear every item in " + str(Balance.LOCATIONS[location].name).capitalize(), "type_id": ""}
	for trophy in Balance.TROPHIES:
		if trophy not in data.trophies:
			var type_id: String = Balance.TROPHIES[trophy].type_id
			return {"title": "FIND THE " + str(Balance.ITEMS[type_id].display_name), "hint": "Load it and escape to keep the trophy", "type_id": type_id}
	return {"title": "BEAT YOUR BEST TIME", "hint": "Choose a job and try a faster route", "type_id": ""}
