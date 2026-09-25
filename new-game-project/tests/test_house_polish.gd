extends "res://tests/route_harness.gd"

func _initialize() -> void: call_deferred("test")

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 8
	Engine.physics_ticks_per_second = 480
	Engine.max_physics_steps_per_frame = 64
	var profile = SaveStore.new("res://tests/house_polish_profile.json")
	profile.session_only = true
	profile.data.upgrades = {"strength":3,"grip":7,"carry":7,"capacity":7,"noise":7}
	await new_session("house","normal",profile)
	var first_route = choose_indices("normal",true)
	var first_success = await drive_indices(first_route,"house_polish_local_tier")
	check(first_success and run.cargo_value >= 800 and run.cargo.any(func(item): return item.data.type_id == "sofa"),"Local tier can physically earn both House progression objectives")
	profile = SaveStore.new("res://tests/house_polish_clear_profile.json")
	profile.session_only = true
	# The existing progression opens Villa after cash + sofa. Its Van L9 fits 23 cargo.
	profile.data.upgrades = {"strength":3,"grip":7,"carry":7,"capacity":9,"noise":7}
	await new_session("house","normal",profile)
	var cleared = await drive_indices([0,6,3,4,7,1,2,5],"house_polish_full_clear")
	print("HOUSE CLEAR DIAGNOSTIC phase=",run.phase," remaining=",run.remaining," alarm_at=",run.time_when_alarm_triggered," progress=",run.progress," needed=",run.progress_duration," velocity=",world.player.velocity)
	check(cleared and run.result.full_clear and run.cargo_used == 23 and run.cargo_value == 2140,"Furnished House stays clearable with 24 cargo and moderate speed upgrades")
	for mode in ["rush","small_van","client_order"]:
		await new_session("house",mode)
		var chosen = choose_indices(mode)
		var solved = await drive_indices(chosen,"house_polish_"+mode)
		check(solved and run.result.contract_met,"House "+mode+" contract remains physically solvable")
	print("HOUSE POLISH: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
