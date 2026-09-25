extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func shot(name: String) -> void:
	await create_timer(0.48).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/" + name + ".png")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/play_rewards_capture_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.heist_briefing_seen = true
	game.store.data.getaway_progress = 2
	root.add_child(game)
	game.open_menu("cosmetics")
	await shot("today_shop_450x800")
	game.open_menu("home")
	game.start_run("apartment")
	await physics_frame
	await physics_frame
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	game.run.phase = RunManager.Phase.ACTIVE
	game.run.started = true
	game.run.cargo.append(game.level.items[0])
	game.run.cargo_value = 140
	game.level.player.position = game.level.van.load_position
	game.run.escape()
	await create_timer(0.55).timeout
	await shot("stash_crate_results_450x800")
	root.size = Vector2i(360,640)
	await shot("stash_crate_results_360x640")
	game.free()
	print("PLAY REWARDS CAPTURES COMPLETE")
	quit()
