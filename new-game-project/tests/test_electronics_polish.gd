extends "res://tests/route_harness.gd"

func _initialize() -> void: call_deferred("test")

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 8
	Engine.physics_ticks_per_second = 480
	Engine.max_physics_steps_per_frame = 64
	var profile = SaveStore.new("res://tests/electronics_polish_profile.json")
	profile.session_only = true
	profile.data.upgrades = {"strength":4,"grip":13,"carry":13,"capacity":13,"noise":13}
	await new_session("electronics","normal",profile)
	var supports_ok = true
	for item in world.items:
		if item.data.type_id in ["small_tv","monitor","gaming_pc"]:
			supports_ok = supports_ok and item.position.y > 0.6 and is_zero_approx(item.model.position.y)
	check(supports_ok,"Displayed electronics sit at furniture height on the loot root, without a carried-model offset")
	check(not world.valid_drop(Vector3(4,0,-2.1),0.1) and not world.valid_drop(Vector3(4.15,0,0.57),0.1),"Permanent TV console and demo table have solid footprints")
	# Quiet stock first, bulky arcade machines last: the alarm rewards route planning.
	var clear = await drive_indices([3,4,5,6,7,8,9,10,1,2,0],"electronics_polish_local_tier")
	print("STORE ROUTE: alarm at %.2fs; escape with %.2fs left" % [run.time_when_alarm_triggered,run.remaining])
	check(clear and run.result.full_clear and run.cargo_value == 4060 and run.cargo_used == 32,"Electronics-tier upgrades clear and escape with all eleven items through actual movement")
	print("ELECTRONICS POLISH: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
