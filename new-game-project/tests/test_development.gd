extends "res://tests/test_ui_v2.gd"

func fresh_game(reload_profile: bool = false) -> Node:
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/dev_persistent_profile.json")
	if reload_profile: game.store.load_progress()
	root.add_child(game)
	return game

func test() -> void:
	LocalLog.enabled = false
	var reset_path = "res://tests/dev_reset_profile.json"
	var old_session = SaveStore.new(reset_path)
	old_session.data.wallet = 9850
	old_session.data.tutorial_completed = true
	old_session.data.noise_tutorial_completed = true
	old_session.data.special_pending = true
	old_session.data.special_location_id = "apartment"
	old_session.save_progress()
	var reset_game = load("res://scenes/main.tscn").instantiate()
	reset_game.store = reset_game.create_launch_store(reset_path)
	root.add_child(reset_game)
	check(reset_game.store.data.wallet == 0 and not reset_game.store.data.tutorial_completed and not reset_game.store.data.noise_tutorial_completed, "DEV startup begins with a fresh tutorial and zero cash")
	check(not reset_game.store.data.special_pending and reset_game.store.path == reset_path, "DEV startup clears previous Special Job in its isolated profile")
	reset_game.store.data.wallet = 1234
	reset_game.store.data.tutorial_completed = true
	reset_game.store.data.special_pending = true
	reset_game.store.save_progress()
	var written = JSON.parse_string(FileAccess.get_file_as_string(reset_path))
	check(written is Dictionary and written.get("wallet") == 1234, "DEV progress is saved during the current session")
	reset_game.free()
	await process_frame
	reset_game = load("res://scenes/main.tscn").instantiate()
	check(reset_game.launch_profile_path(false) == "user://dev_progress.json" and reset_game.launch_profile_path(true) == "user://challenge_v2_test_profile.json", "DEV launch uses a separate profile and keeps QA isolated")
	reset_game.store = reset_game.create_launch_store(reset_path)
	root.add_child(reset_game)
	check(reset_game.store.data.wallet == 0 and not reset_game.store.data.tutorial_completed and not reset_game.store.data.special_pending, "Next DEV launch resets wallet, tutorial and Special Jobs again")
	reset_game.free()
	await process_frame
	if OS.get_cmdline_user_args().has("--test-profile"):
		var boot_game = load("res://scenes/main.tscn").instantiate()
		root.add_child(boot_game)
		check(boot_game.store.path == "user://challenge_v2_test_profile.json" and boot_game.store.data.wallet == 0 and not boot_game.store.data.tutorial_completed, "Real DEV boot selects the isolated QA profile and starts fresh")
		boot_game.store.data.wallet = 77
		boot_game.store.data.tutorial_completed = true
		boot_game.store.save_progress()
		boot_game.free()
		await process_frame
		boot_game = load("res://scenes/main.tscn").instantiate()
		root.add_child(boot_game)
		check(boot_game.store.data.wallet == 0 and not boot_game.store.data.tutorial_completed, "Real DEV relaunch resets the QA profile")
		boot_game.free()
		await process_frame
	var game = fresh_game()
	check(game.development_mode and not game.store.session_only, "Injected DEV fixture can still exercise persistent saving")
	check(game.store.data == game.store.defaults(), "New isolated DEV profile starts empty")
	check(find_button(game.ui.menu, "DEV · MAX ALL + UNLOCK ALL LEVELS") == null, "Home keeps DEV out of the normal composition")
	game.action("settings")
	find_button(game.ui.menu, "DEV TOOLS ▾").pressed.emit()
	var button = find_button(game.ui.menu, "DEV · MAX ALL + UNLOCK ALL LEVELS")
	check(button != null and not button.disabled, "DEV max is available inside the Settings drawer")
	button.pressed.emit()
	check(game.store.data.upgrades == {"strength":5,"grip":20,"carry":20,"capacity":20,"noise":20}, "DEV maxes all five abilities, bypassing tier caps")
	check(game.store.data.unlocked == Balance.LOCATION_ORDER, "DEV unlocks every location, Chapter 2 included")
	game.start_run("pyramid")
	check(game.screen in ["run", "heist_briefing"] and is_instance_valid(game.run) and game.current_location == "pyramid", "Direct Pyramid launch works after DEV unlock")
	game.cleanup_run()
	game.action("settings")
	check(game.store.data.wallet == 0 and Progression.objective_count(game.store.data, "museum") == 0, "DEV grants no money or objectives")
	check(find_button(game.ui.menu, "DEV · MAXED + ALL LEVELS UNLOCKED").disabled, "Button confirms MAX and disables repeated use")
	game.start_run("apartment")
	check(game.run.capacity() == 46 and game.run.upgrades.noise == 20 and game.run.upgrades.strength == 5, "MAX abilities apply to actual next round")
	game.store.data.upgrades.noise = 1
	game.action("dev_max")
	check(game.store.data.upgrades.noise == 1, "DEV action cannot change abilities during a round")
	game.run.abandon()
	game.action("shop")
	check(find_button(game.ui.menu, "DEV · MAX ALL + UNLOCK ALL LEVELS") == null, "DEV remains hidden in the shop")
	game.store.data.wallet = 1234
	game.store.data.objectives.apartment.cash = true
	game.action("locations")
	check(game.store.data.wallet == 1234 and game.store.data.objectives.apartment.cash, "Progress survives menu and round changes within current session")
	game.store.save_progress()
	game.free()
	await process_frame
	game = fresh_game(true)
	check(game.store.data.wallet == 1234 and game.store.data.objectives.apartment.cash and game.store.data.upgrades.strength == 5, "Second DEV launch retains abilities, wallet and objectives")
	game.free()
	await process_frame
	# Prove the session-only store never reads or overwrites an existing save.
	var path = "res://tests/dev_existing_save.json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string('{"sentinel":"preserve existing progress"}')
	file.close()
	var before = FileAccess.get_file_as_string(path)
	var memory = SaveStore.new(path)
	memory.session_only = true
	memory.load_progress()
	memory.data.wallet = 99999
	check(memory.save_progress() and FileAccess.get_file_as_string(path) == before, "Explicit QA session-only store leaves disk untouched")
	memory.load_progress()
	check(memory.data.wallet == 0, "Session-only load ignores existing disk data")
	game = load("res://scenes/main.tscn").instantiate()
	game.development_mode = false
	check(game.launch_profile_path(false) == "user://progress.json", "Production launch keeps the original persistent profile")
	game.store = SaveStore.new("res://tests/dev_disabled_profile.json")
	root.add_child(game)
	check(find_button(game.ui.menu, "DEV · MAX ALL + UNLOCK ALL LEVELS") == null, "DEV hidden when development mode disabled")
	game.action("dev_max")
	check(not Progression.upgrades_maxed(game.store.data), "DEV disabled action cannot bypass progression")
	game.free()
	print("DEV SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
