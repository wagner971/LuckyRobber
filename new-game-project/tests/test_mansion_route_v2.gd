extends "res://tests/route_harness.gd"

func _initialize() -> void:
	call_deferred("test")

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 8
	Engine.physics_ticks_per_second = 480
	Engine.max_physics_steps_per_frame = 64
	check(Balance.totals("mansion") == {"cargo": 38, "value": 5170} and Balance.LOCATIONS.mansion.items.size() == 10, "Mansion keeps its original loot, cargo and value")
	await new_session("mansion")
	var all_items: Array = []
	for i in range(world.items.size()): all_items.append(i)
	var completed := await drive_indices(all_items, "mansion_v2_full_clear")
	print("MANSION DIAGNOSTIC circuits=", measurements.back().circuits, " types=", measurements.back().types, " alarm_at=", run.time_when_alarm_triggered, " remaining=", run.remaining)
	check(completed and run.result.full_clear and run.elapsed < run.rules.duration, "Every Mansion wing and its heavy loot can be cleared physically")
	check(run.cargo_used == 38 and run.cargo_value == 5170, "Full clear banks the unchanged Mansion inventory")
	for mode in ["rush", "small_van", "client_order"]:
		await new_session("mansion", mode)
		var selected := choose_indices(mode)
		var solved := await drive_indices(selected, "mansion_v2_" + mode)
		check(solved and run.result.contract_met and run.elapsed < run.rules.duration, "Mansion " + mode + " contract remains physically solvable")
	print("MANSION V2 ROUTES: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
