extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func shot(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/pyramid_redesign_%s.png" % name)

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(900, 1600)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("user://pyramid_redesign_capture.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.upgrades = {"strength": 5, "grip": 20, "carry": 20, "capacity": 19, "noise": 1}
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	root.add_child(game)
	game.start_run("pyramid")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	await shot("full")
	game.ui.hud.hide()
	var camera: Camera3D = game.level.camera
	for place in [["treasury", -3.25, 1.1], ["antechamber", 0.0, 1.0], ["burial", 0.0, -2.1], ["hall_of_gods", 3.25, 1.1]]:
		camera.size = 5.7
		camera.position = Vector3(place[1], 12.0, place[2] + 7.2)
		camera.look_at(Vector3(place[1], 0, place[2]))
		await shot(place[0])
	game.free()
	print("PYRAMID REDESIGN CAPTURES COMPLETE")
	quit()
