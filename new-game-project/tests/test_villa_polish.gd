extends "res://tests/route_harness.gd"

func _initialize() -> void: call_deferred("test")

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 8
	Engine.physics_ticks_per_second = 480
	Engine.max_physics_steps_per_frame = 64
	var profile = SaveStore.new("res://tests/villa_polish_profile.json")
	profile.session_only = true
	profile.data.upgrades = {"strength":4,"grip":10,"carry":10,"capacity":10,"noise":10}
	await new_session("villa","normal",profile)
	var unique: Dictionary = {}
	for item in world.items: unique[item.data.type_id] = true
	check(unique.size() == 9 and world.items.size() == 9,"Villa retains nine different loot types")
	var chosen = choose_indices("normal",true)
	var progressed = await drive_indices(chosen,"villa_polish_local_tier")
	check(progressed and run.cargo_value >= 1600 and run.cargo.any(func(item): return item.data.type_id == "piano"),"Villa-tier upgrades can reach both progression objectives through real movement")
	profile = SaveStore.new("res://tests/villa_polish_clear_profile.json")
	profile.session_only = true
	# Existing progression opens Electronics after cash + piano, permitting Van L11.
	profile.data.upgrades = {"strength":4,"grip":10,"carry":10,"capacity":11,"noise":10}
	await new_session("villa","normal",profile)
	var cleared = await drive_indices([0,1,2,7,4,3,6,5,8],"villa_polish_full_clear")
	check(cleared and run.result.full_clear and run.cargo_value == 3260 and run.cargo_used == 28,"Full clear remains possible with moderate movement upgrades and exactly 28 cargo")
	print("VILLA POLISH: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
