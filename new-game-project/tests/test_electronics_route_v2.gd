extends "res://tests/route_harness.gd"


func _initialize() -> void:
	call_deferred("test")


func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 8
	Engine.physics_ticks_per_second = 480
	Engine.max_physics_steps_per_frame = 64
	check(Balance.totals("electronics") == {"cargo": 32, "value": 4060} and Balance.LOCATIONS.electronics.items.size() == 11, "Store inventory, cargo and value stay unchanged")
	check(Balance.session("electronics", "normal", MAXED).alarm_window == 18.0 and Balance.session("electronics", "rush", MAXED).alarm_window == 12.0 and Balance.session("electronics", SpecialJobs.MODE, MAXED).alarm_window == 12.0, "Only Normal Electronics gets the longer alarm escape window")
	await new_session("electronics")
	var all_items: Array = []
	for i in range(world.items.size()): all_items.append(i)
	var completed := await drive_indices(all_items, "electronics_v2_full_clear")
	print("ELECTRONICS DIAGNOSTIC circuits=", measurements.back().circuits, " types=", measurements.back().types, " alarm_at=", run.time_when_alarm_triggered, " remaining=", run.remaining)
	check(completed and run.result.full_clear and run.elapsed < run.rules.duration, "Every electronics display, arcade and stock item is physically reachable and loadable")
	check(run.cargo_used == 32 and run.cargo_value == 4060, "Full clear banks every unchanged loot item")
	for mode in ["rush", "small_van", "client_order"]:
		await new_session("electronics", mode)
		var selected := choose_indices(mode)
		var solved := await drive_indices(selected, "electronics_v2_" + mode)
		check(solved and run.result.contract_met and run.elapsed < run.rules.duration, "Electronics " + mode + " contract remains physically solvable")
	print("ELECTRONICS V2 ROUTES: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
