extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(800, 800)
	var camera_sizes := {
		"apartment": 11.5, "house": 15.5, "villa": 15.0,
		"electronics": 13.5, "mansion": 15.5, "laboratory": 16.5, "museum": 15.0,
		"pyramid": 14.0, "castle": 15.0
	}
	for location in Balance.LOCATION_ORDER:
		var level = HeistLevel.new()
		root.add_child(level)
		level.setup(location, 1)
		level.camera.position = Vector3(7, 10, 15)
		level.camera.look_at(Vector3(0, 0, 0))
		level.camera.size = camera_sizes[location]
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://assets/ui/jobs/" + location + ".png")
		level.queue_free()
		await process_frame
	quit()
