extends "res://tests/route_harness.gd"
func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 8
	Engine.physics_ticks_per_second = 480
	Engine.max_physics_steps_per_frame = 64
	for location in ["apartment", "house", "villa"]:
		var tier := Balance.LOCATION_ORDER.find(location)
		var profile := SaveStore.new()
		profile.session_only = true
		profile.data.upgrades = {"strength": Balance.required_level("strength", location), "grip": Balance.required_level("grip", location), "carry": Balance.required_level("carry", location), "capacity": 20, "noise": Balance.required_level("noise", location)}
		await new_session(location, "FINAL_JOB" if location == "apartment" else "normal", profile)
		var solved := await drive_indices(range(world.items.size()), "strength_noise_min_speeds_" + location)
		check(solved and run.result.get("full_clear", false), "Full clear at legal Strength and minimum speed requirements: " + location)
		print("ALARM ", location, " triggered at ", run.time_when_alarm_triggered, ", left ", run.remaining)
	print("STRENGTH ROUTES: %d checks, %d failures" % [checks, failures])
	run.free()
	world.free()
	quit(1 if failures else 0)
