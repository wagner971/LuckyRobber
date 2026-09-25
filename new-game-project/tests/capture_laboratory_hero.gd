extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(800, 800)
	var level := HeistLevel.new()
	root.add_child(level)
	level.setup("laboratory", 1)
	level.camera.position = Vector3(9.0, 13.5, 20.0)
	level.camera.look_at(Vector3(0, 0, -1.0))
	level.camera.size = 18.0
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://assets/ui/jobs/laboratory.png")
	level.free()
	print("LABORATORY JOB HERO COMPLETE")
	quit()
