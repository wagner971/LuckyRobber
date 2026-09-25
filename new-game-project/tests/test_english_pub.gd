extends "res://tests/route_harness.gd"

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	check(Balance.totals("english_pub") == {"cargo":44,"value":21000}, "Unique Pub inventory: $21,000 / 44 cargo")
	var profile = SaveStore.new("res://tests/english_pub_profile.json")
	profile.session_only = true
	profile.data.upgrades = MAXED.duplicate()
	profile.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	Progression.refresh(profile.data)
	check("english_pub" not in profile.data.unlocked, "Museum finale protects the entire new chapter")
	profile.data.museum_final_job_completed = true
	profile.data.unlocked = Balance.LOCATION_ORDER.slice(0,Balance.LOCATION_ORDER.find("english_pub"))
	Progression.refresh(profile.data)
	check("english_pub" not in profile.data.unlocked, "Pub Hall stays locked before Viking Hall objectives")
	profile.data.objectives.vikings.cash = true
	profile.data.objectives.vikings.signature = true
	Progression.refresh(profile.data)
	check("english_pub" in profile.data.unlocked, "Viking Hall completion opens Pub Hall")
	check(Balance.powerup_requirement("english_pub") == 18 and Balance.purchase_cap("carry",profile.data) == Balance.required_level("carry","english_pub"), "New tier caps match its loadout")
	var old_save = profile.data.duplicate(true)
	old_save.objectives.erase("english_pub")
	old_save.unlocked.erase("english_pub")
	old_save.wallet = 12345
	var migrated = profile.validate(old_save)
	check(migrated.wallet == 12345 and migrated.objectives.has("english_pub") and "english_pub" in migrated.unlocked, "Previous save preserves wallet and gains new level defaults")
	profile.data.upgrades.carry = 12
	check(not Progression.powerups_ready(profile.data,"english_pub"), "Full clear requires both speed upgrades")
	var seen: Array = []
	for row in Balance.LOCATIONS.english_pub.items:
		check(row[1] not in seen and str(row[1]).begins_with("pub_"), "Distinct thematic loot: "+row[1])
		seen.append(row[1])
		check(Duplication.source_location(row[1]) == "english_pub" and Duplication.duration(row[1]) <= 45, "Pub loot uses bounded idle economy: "+row[1])
	for speed in [20,Balance.required_level("grip","english_pub")]:
		profile.data.upgrades = {"strength":5,"grip":speed,"carry":speed,"capacity":20,"noise":Balance.required_level("noise","english_pub")}
		await new_session("english_pub","normal",profile)
		check(world.valid_drop(Vector3(1.15,0,-3),0.3), "Open central pub aisle")
		for item in world.items: check(item.model.get_child_count()>0, "Visible model: "+item.data.type_id)
		var complete = await drive_indices(range(10),"pub_full_clear_speed_"+str(speed))
		check(complete and run.result.get("full_clear",false),"Physical full clear at speed level "+str(speed))
		check(run.elapsed < 85 and run.cargo_value == 21000, "Hall time and payout at speed level "+str(speed))
		check("pub_tankard" in profile.data.trophies,"Escaped tankard becomes collection trophy")
	profile.data.upgrades = MAXED.duplicate()
	await new_session("english_pub","special",profile)
	check(await drive_indices([7,8,9],"pub_special_short_route"), "Short 35-second Special Job has a valuable escape route")
	check(run.cargo_value == 6000, "Short route banks register, beer engine and sign")
	print("PUB CHECKS ",checks," FAILURES ",failures)
	if is_instance_valid(run): run.free()
	if is_instance_valid(world): world.free()
	quit(1 if failures else 0)
