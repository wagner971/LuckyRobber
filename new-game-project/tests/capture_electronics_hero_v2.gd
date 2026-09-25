extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(800, 800)
	var level = HeistLevel.new()
	root.add_child(level)
	level.setup("electronics", 1)
	level.camera.position = Vector3(7.0, 11.5, 15.0)
	level.camera.look_at(Vector3(0, 0, 0.1))
	level.camera.size = 19.5
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://assets/ui/jobs/electronics.png")
	level.free()
	print("ELECTRONICS V2 JOB HERO COMPLETE")
	quit()
