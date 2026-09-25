extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(1000,1000)
	var level = HeistLevel.new()
	root.add_child(level)
	level.setup("vikings",20)
	level.player.set_physics_process(false)
	level.camera.position = Vector3(12,22,23)
	level.camera.look_at(Vector3(0,0,-1.1))
	level.camera.size = 24
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://assets/ui/jobs/vikings.png")
	level.free()
	print("VIKING PREVIEW CAPTURED")
	quit()
