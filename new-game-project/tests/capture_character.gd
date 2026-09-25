extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(900, 1000)
	var stage = Node3D.new()
	root.add_child(stage)
	var env = WorldEnvironment.new()
	var settings = Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("e8eceb")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("ffffff")
	settings.ambient_light_energy = 0.3
	settings.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.environment = settings
	stage.add_child(env)
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-42,-30,0)
	light.light_energy = 0.65
	light.shadow_enabled = true
	stage.add_child(light)
	Models.box(stage, Vector3(200,0.1,200), Vector3(0,-0.085,0), Color("e5e8e6"))
	var camera = Camera3D.new()
	stage.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.6
	camera.position = Vector3(2.8,2.2,5)
	camera.look_at(Vector3(0,0.94,0))
	camera.current = true
	var actor = ThiefVisual.new()
	stage.add_child(actor)
	actor.animate(0.2,0)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/character_hero.png")
	print("CHARACTER CAPTURE COMPLETE")
	quit()

