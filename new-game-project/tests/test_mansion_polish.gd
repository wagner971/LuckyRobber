extends "res://tests/route_harness.gd"

func _initialize() -> void: call_deferred("test")

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 8
	Engine.physics_ticks_per_second = 480
	Engine.max_physics_steps_per_frame = 64
	var profile = SaveStore.new("res://tests/mansion_polish_profile.json")
	profile.session_only = true
	profile.data.upgrades = {"strength":Balance.max_level("strength"),"grip":16,"carry":16,"capacity":16,"noise":16}
	await new_session("mansion","normal",profile)
	check(not world.valid_drop(Vector3(6,0,-4.83),0.1) and not world.valid_drop(Vector3(-6.24,0,-2.6),0.1),"Bed and library desk block movement/drop footprints")
	var roots_ok = true
	for item in world.items:
		if item.data.type_id in ["small_tv","gaming_pc","monitor"]:
			roots_ok = roots_ok and item.position.y > 0.55 and is_zero_approx(item.model.position.y)
	check(roots_ok,"Electronics sit on furniture without a carried-model elevation offset")
	var cleared = await drive_indices([0,1,2,3,4,5,6,7,8,9],"mansion_polish_local_tier")
	check(cleared and run.result.full_clear and run.cargo_value == 5170 and run.cargo_used == 38,"Mansion-tier upgrades can physically clear all ten items and escape")
	print("MANSION POLISH: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
