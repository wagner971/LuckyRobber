extends "res://tests/route_harness.gd"

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	check(Balance.totals("vikings") == {"cargo":44,"value":17000}, "Unique Viking inventory: $17,000 / 44 cargo")
	var profile = SaveStore.new("res://tests/vikings_profile.json")
	profile.session_only = true
	profile.data.upgrades = MAXED.duplicate()
	profile.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	Progression.refresh(profile.data)
	check("vikings" not in profile.data.unlocked, "Museum finale protects the entire new chapter")
	profile.data.museum_final_job_completed = true
	profile.data.unlocked = Balance.LOCATION_ORDER.slice(0,Balance.LOCATION_ORDER.find("vikings"))
	Progression.refresh(profile.data)
	check("vikings" not in profile.data.unlocked, "Viking Hall stays locked before Pirate Ship objectives")
	profile.data.objectives.pirate_ship.cash = true
	profile.data.objectives.pirate_ship.signature = true
	Progression.refresh(profile.data)
	check("vikings" in profile.data.unlocked, "Pirate Ship completion opens Viking Hall")
	check(Balance.powerup_requirement("vikings") == 12 and Balance.purchase_cap("carry",profile.data) == 20, "New tier has safe upgrade caps")
	var old_save = profile.data.duplicate(true)
	old_save.objectives.erase("vikings")
	old_save.unlocked.erase("vikings")
	old_save.wallet = 12345
	var migrated = profile.validate(old_save)
	check(migrated.wallet == 12345 and migrated.objectives.has("vikings") and "vikings" in migrated.unlocked, "Previous save preserves wallet and gains new level defaults")
	profile.data.upgrades.carry = 11
	check(not Progression.powerups_ready(profile.data,"vikings"), "Full clear requires both speed upgrades")
	var seen: Array = []
	for row in Balance.LOCATIONS.vikings.items:
		check(row[1] not in seen and str(row[1]).begins_with("viking_"), "Distinct thematic loot: "+row[1])
		seen.append(row[1])
		check(Duplication.source_location(row[1]) == "vikings" and Duplication.duration(row[1]) <= 45, "Viking loot uses bounded idle economy: "+row[1])
	for speed in [20,12]:
		profile.data.upgrades = {"strength":5,"grip":speed,"carry":speed,"capacity":20,"noise":1}
		await new_session("vikings","normal",profile)
		check(world.valid_drop(Vector3(1.15,0,-3),0.3), "Clear lane beside hearth")
		for item in world.items: check(item.model.get_child_count()>0, "Visible model: "+item.data.type_id)
		var complete = await drive_indices(range(10),"viking_full_clear_speed_"+str(speed))
		check(complete and run.result.get("full_clear",false),"Physical full clear at speed level "+str(speed))
		check(run.elapsed < 85 and run.cargo_value == 17000, "Hall time and payout at speed level "+str(speed))
		check("viking_raven" in profile.data.trophies,"Escaped raven becomes collection trophy")
	profile.data.upgrades = MAXED.duplicate()
	await new_session("vikings","special",profile)
	check(await drive_indices([7,8,9],"viking_special_short_route"), "Short 35-second Special Job has a valuable escape route")
	check(run.cargo_value == 5300, "Short route banks cauldron, anvil and raven")
	print("VIKING CHECKS ",checks," FAILURES ",failures)
	if is_instance_valid(run): run.free()
	if is_instance_valid(world): world.free()
	quit(1 if failures else 0)
