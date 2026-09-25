extends "res://tests/capture_ui_studio.gd"

func capture() -> void:
	LocalLog.enabled = false
	after = true
	for dimensions in [Vector2i(360, 640), Vector2i(320, 712)]:
		root.size = dimensions
		suffix = "%dx%d" % [dimensions.x, dimensions.y]
		game = load("res://scenes/main.tscn").instantiate()
		game.store = SaveStore.new("res://tests/ui_studio_extra.json")
		game.store.session_only = true
		game.store.data.tutorial_completed = true
		game.store.data.noise_tutorial_completed = true
		game.store.data.successes = 5
		game.store.data.first_job_at = 1
		game.store.data.wallet = 1234567
		game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
		game.store.data.apartment_final_job_completed = true
		game.store.data.museum_final_job_completed = true
		for location in Balance.LOCATION_ORDER:
			game.store.data.objectives[location] = {"cash":true,"signature":true,"full_clear":true}
		for key in Balance.UPGRADE_KEYS: game.store.data.upgrades[key] = Balance.max_level(key)
		root.add_child(game)
		game.ui.set_safe_area_override(Vector4(0,72,0,54))
		await shot("home_rich")
		for location in Balance.LOCATION_ORDER:
			SpecialJobs.make_pending(game.store.data, location)
			game.ui.jobs_index = Balance.LOCATION_ORDER.find(location)
			game.ui.locations(game.store)
			await shot("jobs_" + location)
		game.action("shop")
		await shot("max_upgrades")
		game.ui.contracts_page(game.store, "apartment")
		await shot("contracts")
		game.ui.settings_page(game.store, true, 0.5, false, false)
		await shot("settings_muted")
		game.store.data.trophies = Balance.TROPHIES.keys()
		game.action("collection")
		await shot("collection_all")
		game.ui.tutorial_results({"success":true,"replay":true,"wallet_before":1234567,"earned":0}, game.store)
		await shot("tutorial_replay")
		game.ui.tutorial_results({"success":false,"replay":false,"wallet_before":1234567,"earned":0}, game.store)
		await shot("tutorial_failure")
		game.start_run("apartment")
		game.run.set_physics_process(false)
		game.ui.show_pause()
		var leave = find_button(game.ui.modal, "ABANDON RUN")
		leave.pressed.emit()
		await shot("abandon_confirm")
		game.cleanup_run()
		for label in ["reward_dense", "reward_large"]:
			var result = outcome()
			result.new_trophies = ["QUANTUM CORE"]
			result.full_clear = true
			result.special_unlocked = true
			result.unlocked_locations = ["museum"]
			result.earned = 1234567 if label == "reward_large" else 8940
			game.ui.results(result, game.store, "laboratory")
			await shot(label)
		game.free()
		await process_frame
	print("EXTENDED STUDIO CAPTURE COMPLETE")
	quit()

func find_button(node: Node, caption: String) -> Button:
	if node is Button and node.text == caption: return node
	for child in node.get_children():
		var found = find_button(child, caption)
		if found != null: return found
	return null
