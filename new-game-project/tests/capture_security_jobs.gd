extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	for location in SecurityPatrol.LOCATIONS:
		root.size = Vector2i(800,800) if location=="museum" else Vector2i(960,800)
		var level := HeistLevel.new()
		root.add_child(level)
		level.setup(location,1)
		match location:
			"electronics":
				level.camera.position = Vector3(8,13,17)
				level.camera.look_at(Vector3.ZERO)
				level.camera.size = 17.5
			"mansion", "laboratory":
				level.camera.position = Vector3(10,17,20)
				level.camera.look_at(Vector3(0,0,-2.3 if location=="mansion" else -2.5))
				level.camera.size = 20.5 if location=="mansion" else 21.0
			"museum":
				level.camera.position = Vector3(8,12,18)
				level.camera.look_at(Vector3(0,0,1.3))
				level.camera.size = 18.0
		await physics_frame
		await physics_frame
		level.security.clock = 4
		level.security.move_sensors(0.1)
		level.security.refresh_cones(false)
		await create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://assets/ui/jobs/"+location+".png")
		level.free()
	print("SECURITY JOBS PREVIEWS UPDATED")
	quit()
