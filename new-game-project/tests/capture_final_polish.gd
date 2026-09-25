extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	for dimensions in [Vector2i(360, 720), Vector2i(360, 800), Vector2i(320, 712)]:
		root.size = dimensions
		var game = load("res://scenes/main.tscn").instantiate()
		game.store = SaveStore.new("res://tests/final_polish_profile.json")
		game.store.session_only = true
		game.store.data.tutorial_completed = true
		game.store.data.noise_tutorial_completed = true
		game.store.data.first_job_at = 1
		game.store.data.successes = 4
		game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
		game.store.data.museum_final_job_completed = true
		root.add_child(game)
		# Simulate a top cutout and gesture navigation area at both portrait sizes.
		game.ui.set_safe_area_override(Vector4(0, 72, 0, 54))
		await shot("home", dimensions)
		game.action("locations")
		await shot("jobs", dimensions)
		game.action("shop")
		await shot("upgrades", dimensions)
		game.action("collection")
		await shot("collection", dimensions)
		game.action("cosmetics")
		await shot("cosmetics", dimensions)
		game.action("settings")
		await shot("settings", dimensions)
		game.start_run("apartment")
		game.run.set_physics_process(false)
		game.level.player.set_physics_process(false)
		await shot("hud", dimensions)
		game.ui.show_pause()
		await shot("pause", dimensions)
		game.ui.close_pause()
		game.run.abandon()
		await shot("results", dimensions)
		game.ui.show_new_trophy(["PINK FLAMINGO"], 1, 6)
		await shot("trophy", dimensions)
		game.free()
		await process_frame
	print("FINAL POLISH CAPTURES COMPLETE")
	quit()

func shot(label: String, dimensions: Vector2i) -> void:
	await create_timer(0.12).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/final_polish_safe_%s_%dx%d.png" % [label, dimensions.x, dimensions.y])
