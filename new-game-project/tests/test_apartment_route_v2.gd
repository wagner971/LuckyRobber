extends "res://tests/route_harness.gd"


func _initialize() -> void:
	call_deferred("test")


func test() -> void:
	LocalLog.enabled = false
	await new_session("apartment")
	var route: Array = []
	for index in range(world.items.size()): route.append(index)
	var reached_every_item := await drive_indices(route, "apartment_v2_full_clear")
	check(reached_every_item and run.result.full_clear and run.elapsed < run.rules.duration, "Every Apartment item remains reachable and loadable through real movement")
	check(world.van.in_zone(world.van.load_position) and run.cargo_used == Balance.LOCATIONS.apartment.expected_cargo, "Short return to the centered van still completes full cargo")
	var tier_profile := SaveStore.new("res://tests/apartment_v2_tier_profile.json")
	tier_profile.session_only = true
	tier_profile.data.upgrades = {"strength": 2, "grip": 4, "carry": 4, "capacity": 6, "noise": 4}
	await new_session("apartment", "FINAL_JOB", tier_profile)
	var tier_complete := await drive_indices(route, "apartment_v2_final_job_tier")
	check(tier_complete and run.result.full_clear and run.elapsed < run.rules.duration, "Final Job remains physically completable at its entry upgrade tier")
	print("APARTMENT V2 ROUTE: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
