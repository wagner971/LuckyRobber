extends "res://tests/route_harness.gd"

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	check(Balance.totals("pirate_ship") == {"cargo":56,"value":13200}, "Unique pirate inventory: $13,200 / 56 cargo")
	var profile = SaveStore.new("res://tests/pirate_profile.json")
	profile.session_only = true
	profile.data.upgrades = MAXED.duplicate()
	profile.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	Progression.refresh(profile.data)
	check("pirate_ship" not in profile.data.unlocked, "Museum finale protects the entire new chapter")
	profile.data.museum_final_job_completed = true
	profile.data.unlocked = Balance.LOCATION_ORDER.slice(0,Balance.LOCATION_ORDER.find("pirate_ship"))
	Progression.refresh(profile.data)
	check("pirate_ship" not in profile.data.unlocked, "Ship stays locked before Castle objectives")
	profile.data.objectives.castle.cash = true
	profile.data.objectives.castle.signature = true
	Progression.refresh(profile.data)
	check("pirate_ship" in profile.data.unlocked, "Castle completion opens Pirate Ship")
	check(Balance.powerup_requirement("pirate_ship") == 14 and Balance.purchase_cap("carry",profile.data) == Balance.required_level("carry","pirate_ship"), "New tier caps match its loadout")
	var old_save = profile.data.duplicate(true)
	old_save.objectives.erase("pirate_ship")
	old_save.unlocked.erase("pirate_ship")
	old_save.wallet = 12345
	var migrated = profile.validate(old_save)
	check(migrated.wallet == 12345 and migrated.objectives.has("pirate_ship") and "pirate_ship" in migrated.unlocked, "Previous save preserves wallet and gains new level defaults")
	profile.data.upgrades.carry = 10
	check(not Progression.powerups_ready(profile.data,"pirate_ship"), "Full clear requires both speed upgrades")
	var seen: Array = []
	for row in Balance.LOCATIONS.pirate_ship.items:
		check(row[1] not in seen and str(row[1]).begins_with("pirate_"), "Distinct thematic loot: "+row[1])
		seen.append(row[1])
		check(Duplication.source_location(row[1]) == "pirate_ship" and Duplication.duration(row[1]) <= 45, "Pirate loot uses bounded idle economy: "+row[1])
	for speed in [20,Balance.required_level("grip","pirate_ship")]:
		profile.data.upgrades = {"strength":Balance.max_level("strength"),"grip":speed,"carry":speed,"capacity":20,"noise":Balance.required_level("noise","pirate_ship")}
		await new_session("pirate_ship","normal",profile)
		check(not world.valid_drop(Vector3(6,0,-4),0.4), "Cannot drop cargo into the sea")
		check(world.valid_drop(Vector3(1.0,0,-5),0.3), "Clear deck lane")
		for edge in [[Vector3(2.8,0.4,5.5),Vector3(2.8,0.4,3.5)],[Vector3(-4,0.4,-3),Vector3(-6,0.4,-3)],[Vector3(0,0.4,-9.6),Vector3(0,0.4,-11.6)]]:
			check(not world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(edge[0],edge[1],1)).is_empty(), "Railing collision prevents walking into the sea")
		for item in world.items: check(item.model.get_child_count()>0, "Visible model: "+item.data.type_id)
		var complete = await drive_indices(range(10),"pirate_full_clear_speed_"+str(speed))
		check(complete and run.result.get("full_clear",false),"Physical full clear at speed level "+str(speed))
		check(run.elapsed < 80 and run.cargo_value == 13200, "Ship time and payout at speed level "+str(speed))
		check("pirate_parrot" in profile.data.trophies,"Escaped parrot becomes collection trophy")
	profile.data.upgrades = MAXED.duplicate()
	await new_session("pirate_ship","special",profile)
	check(await drive_indices([6,8,9],"pirate_special_short_route"), "Short 35-second Special Job has a valuable escape route")
	check(run.cargo_value == 5250, "Short route banks parrot, wheel and chest")
	print("PIRATE CHECKS ",checks," FAILURES ",failures)
	if is_instance_valid(run): run.free()
	if is_instance_valid(world): world.free()
	quit(1 if failures else 0)
