extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(720, 1280)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/museum_v2_visual_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	root.add_child(game)
	game.start_run("museum")
	game.run.set_physics_process(false)
	await frame("res://tests/museum_v2_720x1280.png")
	root.size = Vector2i(450, 800)
	await frame("res://tests/museum_v2_450x800.png")
	game.free()
	root.size = Vector2i(800, 800)
	var level = HeistLevel.new()
	root.add_child(level)
	level.setup("museum", 1)
	level.camera.position = Vector3(8, 12, 20)
	level.camera.look_at(Vector3(0, 0, -1.2))
	level.camera.size = 19.9
	await frame("res://assets/ui/jobs/museum.png")
	level.free()
	print("MUSEUM V2 CAPTURES COMPLETE")
	quit()

func frame(path: String) -> void:
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
