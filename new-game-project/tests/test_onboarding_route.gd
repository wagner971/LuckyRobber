extends "res://tests/test_suite.gd"

func test() -> void:
	LocalLog.enabled = false
	store = SaveStore.new("res://tests/onboarding_route_v2_profile.json")
	store.session_only = true
	world = HeistLevel.new()
	root.add_child(world)
	world.setup("apartment", 1, false, true)
	world.player.set_physics_process(false)
	run = RunManager.new()
	root.add_child(run)
	run.setup(world, store, "apartment")
	run.set_physics_process(false)
	await physics_frame
	await physics_frame
	run.enable_tutorial()
	check(await route_item(world.items[0]), "Real movement through practice garage picks TV and loads first cargo")
	check(run.cargo_value == 140 and run.onboarding.step == Onboarding.Step.GET_SECOND_ITEM, "Physical first delivery advances free-choice step")
	check(await route_item(world.items[1]), "Gaming PC can be reached, picked up and loaded with real physics")
	check(run.cargo_used == 5 and not run.can_escape(), "Second delivery teaches near-full cargo")
	check(await route_item(world.items[2]), "Final chair is reachable without crossing garage walls")
	check(run.can_escape(), "Physical route ends in correct escape zone")
	run.escape()
	check(store.data.wallet == 640 and store.data.tutorial_completed, "Physical three-delivery route settles exact reward")
	print("ONBOARDING ROUTE SECONDS ", snappedf(run.onboarding.active_elapsed, 0.01))
	world.free()
	run.free()
	print("ONBOARDING ROUTE CHECKS %d; FAILURES %d" % [checks, failures])
	quit(1 if failures else 0)
