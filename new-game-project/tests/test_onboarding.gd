extends "res://tests/test_suite.gd"

var game: Node

func make_game() -> void:
	if is_instance_valid(game): game.free()
	game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/onboarding_v2_profile.json")
	game.store.session_only = true
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	store = game.store

func attach_run() -> void:
	run = game.run
	world = game.level
	run.set_physics_process(false)
	world.player.set_physics_process(false)
	await physics_frame
	await physics_frame

func load_item(item: LootItem) -> void:
	world.player.velocity = Vector3.ZERO
	run.intention = Vector2.ZERO
	super.load_item(item)

func button_named(node: Node, label: String) -> Button:
	if node is Button and node.text == label: return node
	for child in node.get_children():
		var found = button_named(child, label)
		if found != null: return found
	return null

func capture(label: String) -> void:
	await process_frame
	await process_frame
	if not OS.get_cmdline_user_args().has("--capture"): return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/tutorial_v3_" + label + ".png")

func check_buttons_fit(node: Node) -> void:
	for child in node.get_children():
		if child is Button and child.is_visible_in_tree():
			var safe: Rect2 = game.ui.root.get_global_rect()
			safe.position.y += game.ui.safe_insets.y
			safe.size.y -= game.ui.safe_insets.y + game.ui.safe_insets.w
			check(safe.grow(1).encloses(child.get_global_rect()), child.text + " fits safe area")
		check_buttons_fit(child)

func test() -> void:
	LocalLog.enabled = false
	create_timer(90).timeout.connect(func(): printerr("ONBOARDING V3 TIMEOUT"); quit(1))
	root.size = Vector2i(450,800)
	make_game()
	check(not store.data.tutorial_completed and store.data.successes == 0, "New profile starts before the first job")
	game.start_tutorial()
	await attach_run()
	var ui: GameUI = game.ui
	check(world.training_layout and world.items.size() == 3 and run.onboarding != null, "Separate garage teaches with three objects")
	ui.update_run(run,0)
	check(ui.pause_button.visible and ui.instruction_panel.visible and ui.guidance.show_gesture, "Move gesture has a readable first step and an exit through pause")
	check(not ui.time_panel.visible and not ui.loot_panel.visible and not ui.cargo_panel.visible and not ui.noise_panel.visible, "No timer, cash, capacity or noise overload at the start")
	await capture("move")
	game.action("pause")
	check(run.phase == RunManager.Phase.PAUSED and not ui.input.enabled, "Garage can be paused")
	game.action("resume")
	tick(120)
	check(run.phase == RunManager.Phase.READY and run.remaining == 90, "Practice has no countdown pressure")
	check(await go_to(Vector3(0,0,1.25)), "Physical movement starts tutorial")
	check(run.onboarding.step == Onboarding.Step.GET_FIRST_ITEM, "Movement highlights only the TV")
	load_item(world.items[0])
	ui.update_run(run,0)
	check(run.cargo_value == 140 and ui.loot_panel.visible and not ui.cargo_panel.visible and not ui.noise_panel.visible, "First delivery reveals money")
	await capture("first_delivery")
	load_item(world.items[1])
	ui.update_run(run,0)
	check(run.cargo_used == 5 and run.capacity() == 6 and ui.cargo_panel.visible and not ui.escape_button.visible, "Bigger second object reveals capacity")
	load_item(world.items[2])
	ui.update_run(run,0)
	check(run.cargo_used == 6 and ui.escape_button.visible, "Full van reveals Escape")
	await capture("escape")
	run.escape()
	check(store.data.tutorial_completed and store.data.wallet == 640 and game.screen == "tutorial_departure", "Escape banks $640 once and animates departure")
	await create_timer(0.85).timeout
	check(game.screen == "results" and world.training_layout and run.phase == RunManager.Phase.FINISHED, "Departure ends at the reward, never auto-starts Apartment")
	await capture("reward")
	check_buttons_fit(ui.menu)
	button_named(ui.menu,"CHOOSE A JOB").pressed.emit()
	check(game.screen == "locations" and not is_instance_valid(game.run), "Choose a Job opens Jobs before the noise lesson")
	for destination in ["home","locations","shop","locations","locations"]:
		game.action(destination)
		check(game.screen == destination and not is_instance_valid(game.run), "Menu navigation stays in " + destination)
	game.start_run("apartment")
	await attach_run()
	check(game.screen == "heist_briefing" and run.phase == RunManager.Phase.PAUSED and not ui.input.enabled, "First explicit job choice opens a paused briefing")
	game.start_run("apartment")
	check(game.run == run, "Repeated Play cannot replace the paused briefing run")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(game.screen == "heist_briefing" and run.phase == RunManager.Phase.PAUSED and not ui.input.enabled, "Returning from background keeps the briefing paused")
	check(world.items.filter(func(item): return item.data.type_id != "lucky_block").size() == Balance.LOCATIONS.apartment.items.size() and world.items[7].strength_lock.visible, "First Apartment already has its real map and visible Strength locks")
	tick(80)
	check(run.remaining == 60 and not run.started, "Briefing cannot spend time or start a heist")
	game.action("resume")
	check(run.phase == RunManager.Phase.PAUSED, "Generic Resume cannot bypass the briefing")
	await capture("briefing")
	check_buttons_fit(ui.modal)
	button_named(ui.modal,"BACK TO JOBS").pressed.emit()
	check(game.screen == "locations" and store.data.failures == 0 and not store.data.heist_briefing_seen, "Back to Jobs cancels briefing without losing a run")
	root.size = Vector2i(320,712)
	ui.set_safe_area_override(Vector4(0,40,0,30))
	game.start_run("apartment")
	await attach_run()
	await capture("briefing_narrow")
	check_buttons_fit(ui.modal)
	button_named(ui.modal,"START HEIST").pressed.emit()
	check(game.screen == "run" and run.phase == RunManager.Phase.READY and store.data.heist_briefing_seen and ui.input.enabled, "Start Heist acknowledges briefing and waits for movement")
	check(store.validate(store.data).heist_briefing_seen, "Briefing acknowledgement survives save validation")
	var disk = SaveStore.new("user://tutorial_v3_persistence_test.json")
	disk.data = store.data.duplicate(true)
	check(disk.save_progress(), "Tutorial state writes to an isolated profile")
	var reloaded = SaveStore.new(disk.path)
	reloaded.load_progress()
	check(reloaded.data.heist_briefing_seen and reloaded.data.tutorial_completed and not reloaded.data.noise_tutorial_completed, "Reload retains independent briefing and garage flags before first noisy pickup")
	DirAccess.remove_absolute(disk.path)
	tick(10)
	check(run.remaining == 60, "Reading the real HUD before moving costs no time")
	begin()
	load_item(world.items[0])
	check(run.current_noise > 0 and store.data.noise_tutorial_completed, "First real pickup uses real noise rules and saves the one-time hint")
	run.escape()
	check(store.data.successes == 1 and game.screen == "results" and store.data.wallet == 780, "First Apartment pays real loot and returns to Results")
	game.action("guided_upgrade")
	check(game.screen == "shop" and ui.shop_selected_key == "carry", "Optional guide focuses Carry Speed")
	store.data.wallet = Balance.upgrade_cost("carry", 1)
	game.buy("carry")
	check(store.data.upgrades.carry == 2 and game.screen == "shop" and not is_instance_valid(game.run), "Buying an upgrade stays in the shop, never auto-starts a run")
	game.action("locations")
	game.start_run("apartment")
	await attach_run()
	check(game.screen == "run" and run.phase == RunManager.Phase.READY, "Later explicit job starts skip the acknowledged briefing")
	game.action("locations")
	check(game.screen == "locations" and store.data.failures == 0, "Leaving before moving does not count as a failure")
	var saved_cash: int = store.data.wallet
	game.action("settings")
	game.action("replay_tutorial")
	await attach_run()
	await go_to(Vector3(0,0,1.25))
	for item in world.items: load_item(item)
	run.escape()
	check(game.screen == "results" and store.data.wallet == saved_cash and store.data.heist_briefing_seen, "Replay ends at results without paying twice or resetting onboarding")
	button_named(ui.menu,"CHOOSE A JOB").pressed.emit()
	check(game.screen == "locations", "Practice completion also opens Jobs")
	game.action("settings")
	game.action("replay_tutorial")
	await attach_run()
	begin()
	game.action("abandon")
	check(game.screen == "results", "Abandoned practice has a reachable result screen")
	button_named(ui.menu,"RETURN TO HOMESCREEN").pressed.emit()
	check(game.screen == "home", "Abandoned practice can leave for Home")
	var legacy = store.defaults()
	legacy.successes = 2
	legacy.erase("heist_briefing_seen")
	check(store.validate(legacy).heist_briefing_seen, "Existing experienced saves do not repeat the new briefing")
	legacy = store.defaults()
	legacy.tutorial_completed = true
	legacy.noise_tutorial_completed = false
	legacy.wallet = 640
	store.data = store.validate(legacy)
	game.action("locations")
	check(game.screen == "locations" and not is_instance_valid(game.run), "Migrated garage-only save can select Jobs with noise still unlearned")
	game.free()
	print("ONBOARDING V3 CHECKS %d; FAILURES %d" % [checks,failures])
	quit(1 if failures else 0)
