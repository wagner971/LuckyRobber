extends "res://tests/route_harness.gd"

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 8
	Engine.physics_ticks_per_second = 480
	Engine.max_physics_steps_per_frame = 64
	for strength in range(1, 6):
		for noise in [1, 4, 20]:
			for weight in Balance.WEIGHTS:
				var amount := Balance.pickup_noise(weight, strength, noise)
				if strength < 5:
					check(Balance.pickup_noise(weight, strength + 1, noise) < amount, "Every STR upgrade reduces " + weight + " noise at Noise Control " + str(noise))
				check(is_equal_approx(Balance.pickup_noise(weight, strength, 20) / Balance.pickup_noise(weight, strength, 1), 0.81), "Noise Control retains its own independent reduction")
	for location in Balance.LOCATION_ORDER:
		check(Balance.location_noise(location) * Balance.strength_noise_multiplier(5) * Balance.noise_multiplier(20) > Balance.alarm_threshold(location), "MAX full haul still triggers alarm: " + location)
	for strength in [1, 2]:
		var profile := SaveStore.new()
		profile.session_only = true
		profile.data.upgrades.strength = strength
		profile.data.heist_briefing_seen = true
		await new_session("apartment", "normal", profile)
		# Exclude random replacements from balance measurements.
		run.lucky.id = ""
		for i in [0, 1, 2]:
			check(await route_item(world.items[i]), "Real starter circuit STR %d, item %d" % [strength, i])
		if strength == 1:
			check(run.alarm_warning_sent and not run.alarm_active, "Three starter items warn before triggering alarm")
		check(await route_item(world.items[3]), "Fourth object can reach van safely at STR %d" % strength)
		check(run.alarm_active == (strength == 1), "Same four-item haul: STR1 alarm, STR2 below alarm")
		if strength == 1:
			check(run.remaining > 0 and run.remaining <= Balance.ALARM_WINDOW, "Real 12-second pressure still leaves time to escape")
		run.escape()
		check(run.result.get("success", false), "Small run remains winnable at STR %d" % strength)
		print("STARTER STR %d: %.2f noise / %.2f threshold, %.2fs active, %.2fs left" % [strength, run.current_noise, run.alarm_threshold, run.elapsed, run.remaining])
	# Tutorial, modifier and idempotence rules remain in the authority, not the UI.
	await new_session("apartment")
	run.phase = RunManager.Phase.ACTIVE
	run.upgrades.strength = 1
	run.upgrades.noise = 1
	run.carried = world.items[0]
	run.lucky.id = "silent"
	run.add_pickup_noise(run.carried)
	check(run.current_noise == 0, "Silent Heist remains silent despite low Strength")
	run.carried.noise_generated_this_run = false
	run.lucky.id = "noise"
	var expected := Balance.pickup_noise(run.carried.data.weight_class, 1, 1) * 2
	run.add_pickup_noise(run.carried)
	check(is_equal_approx(run.current_noise, expected), "Double Noise still applies on top of handling noise")
	run.add_pickup_noise(run.carried)
	check(is_equal_approx(run.current_noise, expected), "Repeated pickup callback never adds noise twice")
	print("STRENGTH NOISE: %d checks, %d failures" % [checks, failures])
	run.free()
	world.free()
	quit(1 if failures else 0)
