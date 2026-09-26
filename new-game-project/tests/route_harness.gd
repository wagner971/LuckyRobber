extends "res://tests/test_suite.gd"

var measurements: Array = []
var campaign_runs: Array = []
const MAXED = {"strength": Balance.STRENGTH_MAX, "grip": 20, "carry": 20, "capacity": 20, "noise": 20}

func new_session(location: String, mode: String = "normal", profile: SaveStore = null) -> void:
	if is_instance_valid(run): run.free()
	if is_instance_valid(world): world.free()
	store = profile if profile != null else SaveStore.new("res://tests/balance_profile.json")
	if profile == null: store.data.upgrades = MAXED.duplicate()
	world = HeistLevel.new()
	root.add_child(world)
	world.setup(location, store.data.upgrades.capacity)
	world.player.set_physics_process(false)
	run = RunManager.new()
	root.add_child(run)
	# Route balance uses standard inventory; random encounters have dedicated tests.
	run.setup(world, store, location, mode, false)
	run.set_physics_process(false)
	await physics_frame
	await physics_frame


func test_settlement() -> void:
	await new_session("apartment", "rush")
	begin()
	load_item(world.items[0])
	run.escape()
	check(run.result.success and not run.result.contract_met and store.data.wallet == 140 and run.result.contract_bonus == 0, "Escaped incomplete contract banks loot, not a medal")
	sell_pending()
	check(store.data.wallet == 140, "Incomplete-contract loot pays once")
	check(Progression.objective_count(store.data, "apartment") == 0 and store.data.records.normal.is_empty(), "Contract never changes career objectives or Normal records")
	check(store.data.records.rush.is_empty(), "Incomplete contract does not set a contract record")
	await new_session("apartment", "small_van")
	begin()
	for i in [7, 6, 8]: load_item(world.items[i])
	check(run.phase == RunManager.Phase.ACTIVE and run.cargo_value == 640 and store.data.wallet == 0, "Meeting contract goal or filling van does not auto escape or bank")
	run.escape()
	run.escape()
	check(store.data.wallet == 1140 and store.data.contracts["apartment.small_van"] and store.data.contract_bonuses == ["apartment.small_van"], "First contract pays its $500 bonus and $640 loot")
	sell_pending()
	check(store.data.wallet == 1140, "Selling contract loot adds its $640 base value")
	check(store.data.trophies == ["flamingo"] and Progression.objective_count(store.data, "apartment") == 0, "Contract awards trophy but no career objectives")
	var profile = store
	await new_session("apartment", "small_van", profile)
	begin()
	for i in [7, 6, 8]: load_item(world.items[i])
	run.escape()
	check(store.data.wallet == 1780 and run.result.contract_bonus == 0 and store.data.trophies.size() == 1, "Repeat contract banks loot only; trophy and bonus stay unique")
	sell_pending()
	check(store.data.wallet == 1780, "Repeated contract loot still has normal sale value")
	var restored = SaveStore.new(profile.path)
	restored.load_progress()
	var record_survived = is_equal_approx(restored.data.records.small_van.get("apartment", -1), profile.data.records.small_van.apartment)
	check(restored.data.contracts == profile.data.contracts and restored.data.contract_bonuses == profile.data.contract_bonuses and record_survived and restored.data.records.normal.is_empty(), "Contract medals, bonus ledger and mode records survive reload")
	await new_session("apartment", "rush")
	begin()
	load_item(world.items[7])
	stand_by(world.items[0])
	tick(1)
	run.remaining = 0
	run.escape()
	check(store.data.wallet == 0 and run.result.lost == 480 and not run.result.success, "Contract timeout loses both cargo and carried loot")
	await new_session("apartment")
	begin()
	world.player.position = world.van.load_position
	run.escape()
	check(store.data.wallet == 0 and run.result.earned == 0, "Empty escape gives $0 without repeatable completion bonus")
	await new_session("apartment")
	begin()
	for i in [0, 1, 8]: load_item(world.items[i])
	run.escape()
	check(run.cargo_value == 270 and not store.data.objectives.apartment.cash, "Cash objectives use delivered value only")

# Exhaustive subset choice by fixed geometry estimate. Every chosen solution is then
# driven through actual physics and interactions; sums alone never pass a route test.

func choose_indices(mode: String, require_signature: bool = false) -> Array:
	var best: Array = []
	var best_score = INF if mode != "normal" else -INF
	var inventory: Array = Balance.LOCATIONS[run.location_id].items
	for mask in range(1, 1 << inventory.size()):
		var value = 0
		var space_used = 0
		var counts: Dictionary = {}
		var selected: Array = []
		var estimate = 0.0
		var valid = true
		for i in range(inventory.size()):
			if not mask & (1 << i): continue
			var item = world.items[i]
			if item.data.required_strength > run.upgrades.strength:
				valid = false
				break
			space_used += int(item.data.cargo_space)
			value += int(item.data.cash_value)
			counts[item.data.type_id] = counts.get(item.data.type_id, 0) + 1
			selected.append(i)
			var distance = 3.6 - item.position.z + absf(item.position.x) - float(item.data.radius)
			estimate += distance / 5 + distance / (5 * run.movement_factor(item)) + Balance.pickup_time(item.data.pickup_duration, run.upgrades.grip) + 1.0
		if not valid or space_used > run.capacity(): continue
		if require_signature and counts.get(Balance.LOCATIONS[run.location_id].special, 0) == 0: continue
		if mode != "normal" and not Balance.contract_met(run.rules.contract_id, value, counts): continue
		if mode == "normal" and estimate > run.remaining - 1: continue
		var score = float(value) - estimate * 0.001 if mode == "normal" else estimate
		if (mode == "normal" and score > best_score) or (mode != "normal" and score < best_score):
			best_score = score
			best = selected
	return best


func drive_indices(indices: Array, label: String) -> bool:
	var delivered: Array = []
	var complete = not indices.is_empty()
	var circuits: Array = []
	for i in indices:
		var before = run.elapsed
		if not await route_item(world.items[i]):
			complete = false
			break
		delivered.append(world.items[i].data.type_id)
		circuits.append(snappedf(run.elapsed - before, 0.01))
	run.escape()
	measurements.append({"label": label, "location": run.location_id, "mode": run.mode, "time": snappedf(run.elapsed, 0.01), "limit": run.rules.duration, "value": run.cargo_value, "cargo": run.cargo_used, "types": delivered, "circuits": circuits, "upgrades": run.upgrades.duplicate(), "escaped": run.result.get("success", false), "contract_met": run.result.get("contract_met", false)})
	print("MEASURE ", label, " %.2fs / %.0fs | $%d | cargo %d" % [run.elapsed, run.rules.duration, run.cargo_value, run.cargo_used])
	return complete and run.result.get("success", false)


func test_all_routes() -> void:
	for location in Balance.LOCATION_ORDER:
		await new_session(location)
		var indices: Array = []
		for i in range(world.items.size()):
			indices.append(i)
			check(world.items[i].model.get_child_count() > 0, "Visible model " + world.items[i].data.type_id)
		var complete = await drive_indices(indices, location + ".full_clear")
		check(complete and run.result.get("full_clear", false) and run.elapsed < run.rules.duration, "Physical full clear at MAX " + location)
		check(run.result.get("bonus", 0) == 250 and store.data.wallet == run.cargo_value + 250, "First Normal full-clear banks its bonus and loot " + location)
		sell_pending()
		check(store.data.wallet == run.cargo_value + 250, "Sold full-clear haul has configured value " + location)
		for mode in ["rush", "small_van", "client_order"]:
			if not Balance.CONTRACTS.has(location + "." + mode): continue
			await new_session(location, mode)
			var chosen = choose_indices(mode)
			var solved = await drive_indices(chosen, location + "." + mode)
			check(solved and run.result.get("contract_met", false) and run.elapsed < run.rules.duration, "Physical contract solution " + location + "." + mode)
			check(store.data.wallet == run.cargo_value + int(Balance.CONTRACTS[location + "." + mode].bonus), "Correct immediate contract and loot payment " + location + "." + mode)
			sell_pending()
			check(store.data.wallet == run.cargo_value + int(Balance.CONTRACTS[location + "." + mode].bonus), "Correct sale plus contract reward tier " + location + "." + mode)
