extends SceneTree

# QA helper: dumps the balance tables to JSON for offline economy simulation.
func _initialize() -> void:
	var out := {"items": Balance.ITEMS, "locations": {}, "order": Balance.LOCATION_ORDER, "noise": Balance.NOISE, "strength_noise": range(1, Balance.max_level("strength") + 1).map(func(l): return Balance.strength_noise_multiplier(l)), "threshold_factor": Balance.ALARM_THRESHOLD_FACTOR, "tier_caps": Balance.TIER_CAPS, "tier_price": Balance.TIER_PRICE, "walk_step": Balance.WALK_SPEED_STEP, "costs": Balance.COSTS, "clear_bonus": Balance.CLEAR_BONUS}
	for id in Balance.LOCATIONS:
		var c: Dictionary = Balance.LOCATIONS[id].duplicate(true)
		c["alarm_threshold"] = Balance.alarm_threshold(id)
		c["alarm_window"] = Balance.session(id, "normal", {"strength": 1, "grip": 1, "carry": 1, "capacity": 1, "noise": 1}).alarm_window
		out.locations[id] = c
	var file := FileAccess.open(OS.get_environment("BALANCE_DUMP") if OS.get_environment("BALANCE_DUMP") != "" else "res://tests/balance_dump.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(out))
	file.close()
	quit()
