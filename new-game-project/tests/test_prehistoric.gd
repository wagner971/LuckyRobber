extends "res://tests/route_harness.gd"

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	check(Balance.totals("prehistoric") == {"cargo":65,"value":25700}, "Unique Prehistoric inventory: $25,700 / 65 cargo")
	var profile = SaveStore.new("res://tests/prehistoric_profile.json")
	profile.session_only = true
	profile.data.upgrades = MAXED.duplicate()
	profile.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	Progression.refresh(profile.data)
	check("prehistoric" not in profile.data.unlocked, "Museum finale protects the entire new chapter")
	profile.data.museum_final_job_completed = true
	profile.data.unlocked = Balance.LOCATION_ORDER.slice(0,Balance.LOCATION_ORDER.find("prehistoric"))
	Progression.refresh(profile.data)
	check("prehistoric" not in profile.data.unlocked, "Prehistoric Era stays locked before English Pub objectives")
	profile.data.objectives.english_pub.cash = true
	profile.data.objectives.english_pub.signature = true
	Progression.refresh(profile.data)
	check("prehistoric" in profile.data.unlocked, "English Pub completion opens Prehistoric Era")
	check(Balance.powerup_requirement("prehistoric") == 20 and Balance.purchase_cap("carry",profile.data) == Balance.required_level("carry","prehistoric"), "New tier caps match its loadout")
	var old_save = profile.data.duplicate(true)
	old_save.objectives.erase("prehistoric")
	old_save.unlocked.erase("prehistoric")
	old_save.wallet = 12345
	var migrated = profile.validate(old_save)
	check(migrated.wallet == 12345 and migrated.objectives.has("prehistoric") and "prehistoric" in migrated.unlocked, "Previous save preserves wallet and gains new level defaults")
	profile.data.upgrades.carry = 13
	check(not Progression.powerups_ready(profile.data,"prehistoric"), "Full clear requires both speed upgrades")
	var seen: Array = []
	for row in Balance.LOCATIONS.prehistoric.items:
		check(row[1] not in seen and str(row[1]).begins_with("prehistoric_"), "Distinct thematic loot: "+row[1])
		seen.append(row[1])
		check(Duplication.source_location(row[1]) == "prehistoric" and Duplication.duration(row[1]) <= 45, "Prehistoric loot uses bounded idle economy: "+row[1])
	for speed in [20,Balance.required_level("grip","prehistoric")]:
		profile.data.upgrades = {"strength":Balance.max_level("strength"),"grip":speed,"carry":speed,"capacity":20,"noise":Balance.required_level("noise","prehistoric")}
		await new_session("prehistoric","normal",profile)
		check(world.valid_drop(Vector3(1.15,0,-3),0.3), "Clear cave travel lane")
		for item in world.items: check(item.model.get_child_count()>0, "Visible model: "+item.data.type_id)
		var complete = await drive_indices(range(10),"prehistoric_full_clear_speed_"+str(speed))
		check(complete and run.result.get("full_clear",false),"Physical full clear at speed level "+str(speed))
		check(run.elapsed < 85 and run.cargo_value == 25700, "Hall time and payout at speed level "+str(speed))
		check("prehistoric_amber" in profile.data.trophies,"Escaped amber becomes collection trophy")
	profile.data.upgrades = MAXED.duplicate()
	await new_session("prehistoric","special",profile)
	check(await drive_indices([7,8,9],"prehistoric_special_short_route"), "Short 35-second Special Job has a valuable escape route")
	check(run.cargo_value == 5600, "Short route banks mortar, drum and bedroll")
	print("PREHISTORIC CHECKS ",checks," FAILURES ",failures)
	if is_instance_valid(run): run.free()
	if is_instance_valid(world): world.free()
	quit(1 if failures else 0)
