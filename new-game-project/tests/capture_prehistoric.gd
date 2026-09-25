extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(1000,1000)
	var level = HeistLevel.new()
	root.add_child(level)
	level.setup("prehistoric",20)
	level.player.set_physics_process(false)
	level.camera.position = Vector3(10,20,22)
	level.camera.look_at(Vector3(0,0,-1.7))
	level.camera.size = 22
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://assets/ui/jobs/prehistoric.png")
	level.free()
	print("PREHISTORIC PREVIEW CAPTURED")
	quit()
