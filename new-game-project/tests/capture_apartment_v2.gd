extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(720, 1280)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/apartment_v2_visual_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	root.add_child(game)
	game.start_run("apartment")
	game.run.set_physics_process(false)
	await save_frame("res://tests/apartment_v2_720x1280.png")
	root.size = Vector2i(450, 800)
	await save_frame("res://tests/apartment_v2_450x800.png")
	game.level.player.position = Vector3(-2.4, 0, -2.4)
	game.camera_juice._process(0.8)
	await save_frame("res://tests/apartment_follow_450x800.png")
	for edge in [
		["left", Vector3(-4.8, 0, 0.0)],
		["right", Vector3(4.8, 0, 0.0)],
		["rear", Vector3(0, 0, -3.0)],
		["van", Vector3(0, 0, 5.8)],
	]:
		game.level.player.position = edge[1]
		game.camera_juice._process(3.0)
		await save_frame("res://tests/apartment_follow_%s_450x800.png" % edge[0])
	game.free()
	print("APARTMENT V2 CAPTURES COMPLETE")
	quit()


func save_frame(path: String) -> void:
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
