extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/house_surroundings_visual_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.first_job_at = 1
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	root.add_child(game)
	game.start_run("house")
	game.run.set_physics_process(false)
	await save_frame("res://tests/house_follow_center_450x800.png")
	for edge in [
		["left", Vector3(-4.7, 0, -3.0)],
		["right", Vector3(4.7, 0, -3.0)],
		["rear", Vector3(0, 0, -7.0)],
		["van", Vector3(0, 0, 7.0)],
	]:
		game.level.player.position = edge[1]
		game.camera_juice._process(3.0)
		await save_frame("res://tests/house_follow_%s_450x800.png" % edge[0])
	game.free()
	print("HOUSE SURROUNDINGS CAPTURES COMPLETE")
	quit()

func save_frame(path: String) -> void:
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
