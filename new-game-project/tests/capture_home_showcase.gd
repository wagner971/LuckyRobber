extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/home_showcase_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.successes = 4
	game.store.data.first_job_at = 1
	game.store.data.wallet = 9420
	root.size = Vector2i(522, 938)
	root.add_child(game)
	await shot("reference")
	for dimensions in [Vector2i(320, 712), Vector2i(360, 800), Vector2i(450, 800)]:
		root.size = dimensions
		game.ui.set_safe_area_override(Vector4(0, 72, 0, 54))
		game.ui.home(game.store)
		await shot("%dx%d" % [dimensions.x, dimensions.y])
	root.size = Vector2i(522, 938)
	game.ui.set_safe_area_override(Vector4.ZERO)
	game.ui.home(game.store)
	await shot("motion_a")
	await shot("motion_b")
	game.free()
	await process_frame
	print("HOME SHOWCASE CAPTURES COMPLETE")
	quit()

func shot(label: String) -> void:
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/home_showcase_%s.png" % label)
