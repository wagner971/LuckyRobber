extends "res://tests/route_harness.gd"

func _initialize() -> void: call_deferred("test")

func apartment_tier_profile(unlocked: Array = ["apartment"]) -> SaveStore:
	var profile = SaveStore.new("res://tests/final_job_v1_profile.json")
	profile.data.unlocked = unlocked.duplicate()
	profile.data.upgrades = {"strength": 2, "grip": 4, "carry": 4, "capacity": 6, "noise": 4}
	return profile

func test() -> void:
	LocalLog.enabled = false

	# 1. Two Apartment objectives unlock Final Job, not Suburban directly.
	var p1 = apartment_tier_profile()
	p1.data.objectives.apartment.cash = true
	p1.data.objectives.apartment.signature = true
	Progression.refresh(p1.data)
	check(Progression.final_job_unlocked(p1.data) and not p1.unlocked("house"), "Two objectives unlock Final Job, not Suburban directly")

	# 2. Final Job uses the same fixed canonical Apartment layout as Normal (no procedural remix exists or is introduced).
	await new_session("apartment", "normal", apartment_tier_profile())
	var normal_layout = world.items.map(func(i): return [i.data.type_id, i.position])
	await new_session("apartment", "FINAL_JOB", apartment_tier_profile())
	var final_job_layout = world.items.map(func(i): return [i.data.type_id, i.position])
	check(normal_layout == final_job_layout, "Final Job and Normal build the identical canonical Apartment layout")

	# 3/4. Van capacity gate: L5 (16 cargo) is short, L6 (18 cargo) covers the 17 needed.
	check(Balance.van_capacity(5) < Balance.LOCATIONS.apartment.expected_cargo, "Van L5 (16 cargo) is short of Apartment's 17")
	check(Balance.van_capacity(6) >= Balance.LOCATIONS.apartment.expected_cargo, "Van L6 (18 cargo) covers Apartment's 17")
	var p3 = apartment_tier_profile()
	p3.data.objectives.apartment.cash = true
	p3.data.objectives.apartment.signature = true
	p3.data.upgrades.capacity = 5
	check(not Progression.final_job_unlocked(p3.data) and Balance.van_capacity(p3.data.upgrades.capacity) < Balance.LOCATIONS.apartment.expected_cargo, "Final Job waits for the Van L6 loadout level; L5 is also mathematically too small")

	# 5. Carrying the last item is NOT enough — it must be loaded, not just carried.
	var p5 = apartment_tier_profile()
	p5.data.upgrades.capacity = 6
	await new_session("apartment", "FINAL_JOB", p5)
	begin()
	for i in range(world.items.size() - 1): load_item(world.items[i])
	var last_item = world.items[world.items.size() - 1]
	stand_by(last_item)
	tick(2)
	check(run.carried == last_item and run.cargo.size() == world.items.size() - 1, "Last item picked up but not yet loaded")
	check(not run.can_escape(), "Cannot Escape while still carrying the last item (must load, not just carry)")
	world.player.position = world.van.load_position
	tick(0.4)
	check(run.carried == null and run.cargo.size() == world.items.size(), "Reaching the van loads the carried item into cargo")
	run.escape()
	check(run.result.success and run.result.full_clear and p5.data.apartment_final_job_completed and p5.unlocked("house"), "Loading the final item then Escaping completes Final Job and unlocks Suburban")
	check(run.result.get("final_job_completed", false), "Result flags final_job_completed on first completion")

	# 6. Timeout does NOT complete Final Job even with everything already loaded.
	var p6 = apartment_tier_profile()
	p6.data.upgrades.capacity = 6
	await new_session("apartment", "FINAL_JOB", p6)
	begin()
	for item in world.items: load_item(item)
	run.remaining = 0
	run.escape()
	check(not run.result.success and not p6.data.apartment_final_job_completed and not p6.unlocked("house"), "Timeout does not complete Final Job or unlock Suburban despite full cargo")

	# 7. Success unlocks Suburban exactly once; replay does not duplicate unlock/reward.
	var p7 = apartment_tier_profile()
	p7.data.upgrades.capacity = 6
	await new_session("apartment", "FINAL_JOB", p7)
	begin()
	for item in world.items: load_item(item)
	run.escape()
	var wallet_after_first = p7.data.wallet
	var unlocked_after_first = p7.data.unlocked.duplicate()
	await new_session("apartment", "FINAL_JOB", p7)
	begin()
	for item in world.items: load_item(item)
	run.escape()
	check(run.result.success and not run.result.get("final_job_completed", false), "Replay does not re-trigger the one-time completion flag")
	check(p7.data.unlocked == unlocked_after_first, "Replay does not unlock Suburban again / no duplicate entries")
	check(p7.data.wallet == wallet_after_first + run.result.earned, "Replay pays loot normally, with no duplicate one-time bonus")

	# 8. Existing saves that already had Suburban unlocked are grandfathered, never relocked.
	var raw = {"schema_version": 6, "wallet": 500, "unlocked": ["apartment", "house"], "upgrades": {"strength": 1, "grip": 1, "carry": 1, "capacity": 1, "noise": 1}}
	var raw_file = FileAccess.open("res://tests/final_job_v1_legacy.json", FileAccess.WRITE)
	raw_file.store_string(JSON.stringify(raw))
	raw_file.close()
	var legacy = SaveStore.new("res://tests/final_job_v1_legacy.json")
	legacy.load_progress()
	check(legacy.data.apartment_final_job_completed and legacy.unlocked("house"), "Existing save with Suburban already unlocked is grandfathered, not relocked")

	# 9. A brand-new save is NOT grandfathered.
	var fresh = SaveStore.new("res://tests/final_job_v1_fresh.json")
	check(not fresh.data.apartment_final_job_completed and not fresh.unlocked("house"), "Fresh save starts without Final Job completed or Suburban unlocked")

	# 10. Alarm-escape window override: Final Job = 16s; Normal/Mastery/Special = 12s (global constant untouched).
	await new_session("apartment", "normal", apartment_tier_profile())
	check(is_equal_approx(run.alarm_window, 12.0), "Normal Apartment keeps the 12s Alarm window")
	await new_session("apartment", "FINAL_JOB", apartment_tier_profile())
	check(is_equal_approx(run.alarm_window, 16.0), "Final Job uses the 16s Alarm-escape window override")
	await new_session("apartment", "small_van", apartment_tier_profile())
	check(is_equal_approx(run.alarm_window, 12.0), "Mastery contract keeps the 12s Alarm window")
	await new_session("apartment", SpecialJobs.MODE, apartment_tier_profile())
	check(is_equal_approx(run.alarm_window, 12.0), "Special Job keeps the 12s Alarm window")
	check(Balance.ALARM_WINDOW == 12.0, "Global ALARM_WINDOW constant itself is never changed")

	# 11. Other location unlock rules are unchanged (generic 2-objective rule still applies beyond Apartment->House).
	var p11 = SaveStore.new("res://tests/final_job_v1_progression.json")
	p11.data.unlocked = ["apartment", "house"]
	p11.data.objectives.house.cash = true
	p11.data.objectives.house.signature = true
	Progression.refresh(p11.data)
	check(not p11.unlocked("villa"), "Two House objectives alone cannot bypass the loadout requirements")
	p11.data.upgrades.grip = 3
	p11.data.upgrades.carry = 3
	Progression.refresh(p11.data)
	check(not p11.unlocked("villa"), "Speed levels alone do not open Villa without the rest of the House loadout")
	for key in Balance.UPGRADE_KEYS: p11.data.upgrades[key] = Balance.required_level(key, "house")
	Progression.refresh(p11.data)
	check(p11.unlocked("villa"), "Two House objectives plus the full House loadout open Villa")

	# 12. Final Job is its own mode, not counted as a Special Job or Mastery Contract.
	var p12 = apartment_tier_profile()
	p12.data.upgrades.capacity = 6
	p12.data.runs_since_special = 1
	await new_session("apartment", "FINAL_JOB", p12)
	begin()
	for item in world.items: load_item(item)
	run.escape()
	check(p12.data.runs_since_special == 1, "Final Job does not advance the Special Job scheduler")
	check(Progression.contract_count(p12.data) == 0, "Final Job does not register as a Mastery Contract medal")

	print("FINAL JOB V1 SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
