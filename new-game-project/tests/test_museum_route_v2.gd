extends "res://tests/route_harness.gd"

func _initialize() -> void:
	call_deferred("test")

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	check(Balance.totals("museum") == {"cargo": 45, "value": 9700} and Balance.LOCATIONS.museum.items.size() == 8, "Museum has eight themed exhibits and the new economy")
	check(Balance.session("museum", "normal", MAXED).alarm_window == 24.0 and Balance.session("museum", "FINAL_JOB", MAXED).alarm_window == 24.0 and Balance.session("museum", "rush", MAXED).alarm_window == 12.0 and Balance.session("museum", SpecialJobs.MODE, MAXED).alarm_window == 12.0, "Only Museum Normal and Final Job widen the alarm window")
	await new_session("museum")
	var all_items: Array = []
	for i in range(world.items.size()): all_items.append(i)
	var cleared := await drive_indices(all_items, "museum_v2_full_clear")
	print("MUSEUM DIAGNOSTIC circuits=", measurements.back().circuits, " types=", measurements.back().types, " alarm_at=", run.time_when_alarm_triggered, " remaining=", run.remaining)
	check(cleared and run.result.full_clear and run.elapsed < run.rules.duration, "Every Museum gallery and the Time Machine can be cleared physically")
	check(run.cargo_used == 45 and run.cargo_value == 9700, "Full clear banks the complete Museum inventory")
	for mode in ["rush", "small_van", "client_order"]:
		await new_session("museum", mode)
		var selected := choose_indices(mode)
		var solved := await drive_indices(selected, "museum_v2_" + mode)
		check(solved and run.result.contract_met and run.elapsed < run.rules.duration, "Museum " + mode + " contract remains physically solvable")
	var profile = SaveStore.new("res://tests/museum_final_route_profile.json")
	profile.session_only = true
	profile.data.unlocked = Balance.LOCATION_ORDER.slice(0,Balance.LOCATION_ORDER.find("museum")+1)
	profile.data.apartment_final_job_completed = true
	profile.data.upgrades = MAXED.duplicate()
	profile.data.objectives.museum.cash = true
	profile.data.objectives.museum.signature = true
	Progression.refresh(profile.data)
	check(not profile.unlocked("pyramid") and Progression.museum_final_job_unlocked(profile.data), "Two Museum goals offer the finale without opening Chapter 2")
	var legacy_save := profile.defaults()
	legacy_save.unlocked = Balance.LOCATION_ORDER.slice(0, Balance.LOCATION_ORDER.find("pyramid") + 1)
	legacy_save.erase("museum_final_job_completed")
	legacy_save = profile.validate(legacy_save)
	check(not legacy_save.museum_final_job_completed and not legacy_save.unlocked.has("pyramid"), "Older saves without Museum completion keep Chapter 2 locked")
	await new_session("museum", "FINAL_JOB", profile)
	var finale_order := all_items.duplicate()
	finale_order.erase(3) # Leave the Time Machine for the last gallery visit.
	finale_order.append(3)
	var finished := await drive_indices(finale_order, "museum_v2_final_job")
	check(finished and profile.data.museum_final_job_completed and profile.unlocked("pyramid") and run.result.get("time_machine_stolen", false), "Physical Museum Final Job steals Time Machine and opens Pyramid")
	var mid_tier = SaveStore.new("res://tests/museum_mid_tier_profile.json")
	mid_tier.session_only = true
	mid_tier.data.upgrades = {"strength": 5, "grip": 10, "carry": 10, "capacity": 20, "noise": 10}
	mid_tier.data.objectives.museum.cash = true
	mid_tier.data.objectives.museum.signature = true
	await new_session("museum", "FINAL_JOB", mid_tier)
	var mid_tier_finished := await drive_indices(finale_order, "museum_v2_final_job_mid_tier")
	check(mid_tier_finished and run.result.full_clear, "Museum Final Job is feasible without maxing Grip, Carry, or Noise")
	print("MUSEUM V2 ROUTES: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
