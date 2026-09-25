extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(720, 1280)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/home_v2_profile.json")
	game.store.session_only = true
	root.add_child(game)
	await save_frame("res://tests/home_v2_first_job.png")
	game.store.data.wallet = 1250
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.ui.home(game.store)
	await save_frame("res://tests/home_v2_next_target.png")
	root.size = Vector2i(450, 800)
	game.ui.home(game.store)
	await save_frame("res://tests/home_reference_450x800.png")
	root.size = Vector2i(720, 1100)
	game.ui.home(game.store)
	await save_frame("res://tests/home_v2_compact.png")
	root.size = Vector2i(720, 1280)
	game.store.data.objectives.apartment.cash = true
	game.store.data.objectives.apartment.signature = true
	game.store.data.upgrades.strength = 2
	game.store.data.upgrades.capacity = 6
	game.ui.home(game.store)
	await save_frame("res://tests/home_v2_final_job.png")
	game.free()
	print("HOME V2 CAPTURES COMPLETE")
	quit()


func save_frame(path: String) -> void:
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
