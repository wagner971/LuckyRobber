extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(800, 800)
	var level := HeistLevel.new()
	root.add_child(level)
	level.setup("pyramid", 1)
	level.camera.position = Vector3(8, 11.5, 17)
	level.camera.look_at(Vector3(0, 0, 1.0))
	level.camera.size = 17.2
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://assets/ui/jobs/pyramid.png")
	level.free()
	print("PYRAMID EXTERIOR JOB HERO COMPLETE")
	quit()
