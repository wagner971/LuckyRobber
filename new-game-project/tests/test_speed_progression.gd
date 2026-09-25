extends "res://tests/route_harness.gd"

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	check(Balance.upgrade_cost("grip",1) == 850 and Balance.upgrade_cost("carry",1) == 850,"First two speed upgrades cost $1,700 combined")
	var total_cost := 0
	for key in Balance.UPGRADE_KEYS:
		for level in range(1, Balance.max_level(key)):
			check(Balance.upgrade_cost(key, level) > 0 and Balance.upgrade_cost(key, level + 1) >= Balance.upgrade_cost(key, level) or level + 1 >= Balance.max_level(key), "Prices never fall as %s levels rise" % key)
			total_cost += Balance.upgrade_cost(key, level)
	check(total_cost == 1725300, "All 80 purchases cost $1,725,300")
	var walk_monotonic = true
	for level in range(1, 20): walk_monotonic = walk_monotonic and Balance.walk_factor(level + 1) > Balance.walk_factor(level)
	check(walk_monotonic and is_equal_approx(Balance.walk_factor(20), 1.38), "Every Carry level walks faster, up to +38% at MAX")
	check(is_equal_approx(Balance.pickup_time(2.8,2),2.5),"Grip 2 cuts Quantum Core pickup from 2.8s to 2.5s")
	check(is_equal_approx(Balance.carry_factor("VERY_HEAVY",2)*5,3.5185185185),"Carry 2 raises heaviest-loot speed from 3 to 3.519 m/s (+17.28%)")
	for weight in Balance.WEIGHTS:
		var monotonic = true
		for level in range(1,20):
			monotonic = monotonic and Balance.carry_factor(weight,level+1) > Balance.carry_factor(weight,level) and Balance.carry_factor(weight,level+1) < 1.0
		check(monotonic,"Every Carry purchase helps %s without exceeding empty speed" % weight)
	var report = FileAccess.open("res://tests/speed_progression_economy.csv",FileAccess.WRITE)
	report.store_csv_line(PackedStringArray(["location","required_each","pair_cost_from_previous","cumulative_pair_cost","full_haul","pair_as_haul_percent"]))
	var accumulated = 0
	for index in range(Balance.LOCATION_ORDER.size()):
		var location: String = Balance.LOCATION_ORDER[index]
		var required: int = Balance.required_level("grip", location)
		check(required == Balance.required_level("carry", location) and (index == 0 or required > Balance.required_level("grip", Balance.LOCATION_ORDER[index-1])),"Required speed levels increase at every location: "+location)
		var counts = {}
		for spawn in Balance.LOCATIONS[location].items: counts[spawn[1]] = counts.get(spawn[1],0)+1
		var types = counts.keys()
		var special_data = SaveStore.new("res://tests/speed_unused.json").data
		special_data.unlocked = Balance.LOCATION_ORDER.slice(0,index+1)
		special_data.apartment_final_job_completed = index > 0
		special_data.museum_final_job_completed = index > Balance.LOCATION_ORDER.find("museum")
		Progression.settle(special_data,location,SpecialJobs.MODE,counts,[],Balance.totals(location).value,true,20.0)
		check(not special_data.objectives[location].full_clear and (index == Balance.LOCATION_ORDER.size()-1 or Balance.LOCATION_ORDER[index+1] not in special_data.unlocked),"Special Job cannot bypass required speed purchases: "+location)
		for missing in Balance.UPGRADE_KEYS:
			var data = SaveStore.new("res://tests/speed_unused.json").data
			data.unlocked = Balance.LOCATION_ORDER.slice(0,index+1)
			data.apartment_final_job_completed = index > 0
			data.museum_final_job_completed = index > Balance.LOCATION_ORDER.find("museum")
			for key in Balance.UPGRADE_KEYS: data.upgrades[key] = Balance.required_level(key, location)
			var mode = "FINAL_JOB" if location in ["apartment","museum"] else "normal"
			var result: Dictionary
			if index == 0 or Balance.required_level(missing, location) > Balance.required_level(missing, Balance.LOCATION_ORDER[index-1]):
				data.upgrades[missing] = Balance.required_level(missing, location)-1
				result = Progression.settle(data,location,mode,counts,[],Balance.totals(location).value,true,20.0)
				check(not data.objectives[location].full_clear and result.bonus == 0 and not result.get("final_job_completed",false),"Missing %s cannot clear %s even through direct settlement" % [missing,location])
				check(data.wallet == Balance.totals(location).value,"Blocked career clear still pays every original: %s %s" % [location,missing])
				check(index == Balance.LOCATION_ORDER.size()-1 or Balance.LOCATION_ORDER[index+1] not in data.unlocked,"Missing %s cannot open next location after %s" % [missing,location])
				data.upgrades[missing] = Balance.required_level(missing, location)
			result = Progression.settle(data,location,mode,counts,[],Balance.totals(location).value,true,20.0)
			check(data.objectives[location].full_clear and result.bonus == Balance.CLEAR_BONUS,"Complete loadout permits the real clear: "+location)
			check(index == Balance.LOCATION_ORDER.size()-1 or Balance.LOCATION_ORDER[index+1] in data.unlocked,"Complete loadout permits advancement: "+location)
		var profile = SaveStore.new("res://tests/speed_route.json")
		profile.session_only = true
		profile.data.unlocked = Balance.LOCATION_ORDER.slice(0,index+1)
		profile.data.upgrades = MAXED.duplicate()
		profile.data.upgrades.grip = required
		profile.data.upgrades.carry = required
		check(required <= Balance.purchase_cap("grip",profile.data) and required <= Balance.purchase_cap("carry",profile.data),"Required speeds can be purchased before leaving "+location)
		var pair = Balance.upgrade_cost("grip",required-1)+Balance.upgrade_cost("carry",required-1)
		accumulated += pair
		report.store_csv_line(PackedStringArray([location,str(required),str(pair),str(accumulated),str(Balance.totals(location).value),str(pair*100.0/Balance.totals(location).value)]))
		await new_session(location,"FINAL_JOB" if location in ["apartment","museum"] else "normal",profile)
		var solved = await drive_indices(range(world.items.size()),"speed_minimum_"+location)
		check(solved and run.result.full_clear,"Physical clear works with required minimum speed levels: "+location)
	report.close()
	# Purchases refresh a blocked ordinary-map unlock without requiring a reload.
	var purchase_store = SaveStore.new("res://tests/speed_purchase.json")
	purchase_store.session_only = true
	purchase_store.data.unlocked = ["apartment","house"]
	purchase_store.data.apartment_final_job_completed = true
	purchase_store.data.objectives.house.cash = true
	purchase_store.data.objectives.house.signature = true
	for key in Balance.UPGRADE_KEYS: purchase_store.data.upgrades[key] = Balance.required_level(key, "house")
	purchase_store.data.upgrades.carry = 2
	purchase_store.data.wallet = Balance.upgrade_cost("carry", 2)
	check(purchase_store.purchase("carry",true) and "villa" in purchase_store.data.unlocked,"Last required purchase unlocks an already-earned ordinary map immediately")
	print("SPEED PROGRESSION: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
