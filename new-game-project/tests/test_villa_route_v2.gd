extends "res://tests/route_harness.gd"


func _initialize() -> void:
	call_deferred("test")


func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 8
	Engine.physics_ticks_per_second = 480
	Engine.max_physics_steps_per_frame = 64
	check(Balance.session("villa", "normal", MAXED).duration == 70.0 and Balance.session("villa", "normal", MAXED).alarm_window == 26.0 and Balance.session("villa", "rush", MAXED).alarm_window == 12.0 and Balance.session("villa", SpecialJobs.MODE, MAXED).alarm_window == 12.0, "Only Normal Villa gets the longer timer and alarm window")
	await new_session("villa")
	var all_items: Array = []
	for i in range(world.items.size()): all_items.append(i)
	var finished := await drive_indices(all_items, "villa_v2_full_clear")
	print("VILLA DIAGNOSTIC circuits=", measurements.back().circuits, " types=", measurements.back().types, " alarm_at=", run.time_when_alarm_triggered, " remaining=", run.remaining)
	check(finished and run.result.full_clear and run.elapsed < run.rules.duration, "Every Villa room is reachable and full clear fits the timer")
	check(run.cargo_used == Balance.LOCATIONS.villa.expected_cargo and run.cargo_value == Balance.LOCATIONS.villa.expected_value, "New premium inventory matches its cargo and value budget")
	for mode in ["rush", "small_van", "client_order"]:
		await new_session("villa", mode)
		var chosen := choose_indices(mode)
		var solved := await drive_indices(chosen, "villa_v2_" + mode)
		check(solved and run.result.contract_met and run.elapsed < run.rules.duration, "Villa " + mode + " contract remains physically solvable")
	print("VILLA V2 ROUTES: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
