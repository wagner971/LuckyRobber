extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	root.size = Vector2i(960, 720)
	var stage := Node3D.new()
	root.add_child(stage)
	var van := LootVan.new()
	stage.add_child(van)
	van.setup(1)
	van.model.position = Vector3.ZERO
	van.zone.visible = false
	for child in van.get_children():
		if child is Label3D:
			child.visible = false
	var floor_mesh := Models.box(stage, Vector3(7, 0.08, 7), Vector3(0, -0.08, 0), Color("273b4e"))
	floor_mesh.name = "PreviewFloor"
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 25, -20)
	sun.light_energy = 1.6
	stage.add_child(sun)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.4
	camera.current = true
	stage.add_child(camera)
	camera.position = Vector3(4.2, 3.2, 4.2)
	camera.look_at(Vector3(0, 1.03, 0))
	await process_frame
	await create_timer(0.3).timeout
	root.get_texture().get_image().save_png("res://tests/van_v2_front.png")
	camera.position = Vector3(-4.2, 3.2, 4.2)
	camera.look_at(Vector3(0, 1.03, 0))
	await process_frame
	await create_timer(0.3).timeout
	root.get_texture().get_image().save_png("res://tests/van_v2_rear.png")
	print("VAN V2 CAPTURE COMPLETE")
	quit()
