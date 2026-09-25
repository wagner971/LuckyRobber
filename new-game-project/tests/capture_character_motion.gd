extends SceneTree

var actors: Array = []
var items: Array = []
var vans: Array = []
var labels: Array = []
var viewports: Array = []

func _initialize() -> void: call_deferred("capture")

func make_cell(grid: GridContainer, index: int, title: String) -> void:
	var panel = VBoxContainer.new()
	panel.add_theme_constant_override("separation", 0)
	grid.add_child(panel)
	var label = Label.new()
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size.y = 32
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color("e9efe8"))
	panel.add_child(label)
	labels.append(label)
	var container = SubViewportContainer.new()
	container.custom_minimum_size = Vector2(320,348)
	panel.add_child(container)
	var vp = SubViewport.new()
	vp.size = Vector2i(320,348)
	vp.own_world_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(vp)
	viewports.append(vp)
	var stage = Node3D.new()
	vp.add_child(stage)
	var env = WorldEnvironment.new()
	var settings = Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("cbd3d0")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color.WHITE
	settings.ambient_light_energy = 0.3
	env.environment = settings
	stage.add_child(env)
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50,-30,0)
	light.light_energy = 0.65
	light.shadow_enabled = true
	stage.add_child(light)
	Models.box(stage, Vector3(100,0.1,100),Vector3(0,-0.09,0),Color("cbd3d0"))
	var camera = Camera3D.new()
	stage.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.35 if index < 2 else (4.25 if index == 3 else 3.3)
	var aim = Vector3(0,0.95 if index < 2 else (1.65 if index == 3 else 1.3),0)
	if index == 5:
		camera.size = 5.7
		aim = Vector3(0.9,0.9,0)
	camera.position = aim + Vector3(3,2,6)
	camera.look_at(aim)
	camera.current = true
	var actor = ThiefVisual.new()
	stage.add_child(actor)
	actors.append(actor)
	var item: Node3D = Models.loot("fridge" if index == 3 else "small_tv") if index >= 2 else Node3D.new()
	actor.carry_anchor.add_child(item)
	items.append(item)
	var van: LootVan = null
	if index == 5:
		van = LootVan.new()
		stage.add_child(van)
		van.setup(1)
		van.position = Vector3(-0.45,0,-4.65)
		van.zone.visible = false
		for child in van.get_children():
			if child is Label3D: child.visible = false
	vans.append(van)

func capture() -> void:
	root.size = Vector2i(960,760)
	root.content_scale_size = Vector2i(960,760)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var bg = ColorRect.new()
	bg.color = Color("152b38")
	bg.size = Vector2(960,760)
	root.add_child(bg)
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 0)
	grid.add_theme_constant_override("v_separation", 0)
	root.add_child(grid)
	var titles = ["IDLE", "RUN", "CARRY", "HEAVY CARRY · FRIDGE", "PICKUP · 0.15 s", "LOAD · WHAM!"]
	for i in range(6): make_cell(grid,i,titles[i])
	DirAccess.make_dir_recursive_absolute("res://tests/character_frames")
	for frame in range(60):
		var t = float(frame) / 30.0
		for i in range(6):
			var actor: ThiefVisual = actors[i]
			actor.carrying = i in [2,3] or (i == 4 and t >= 0.65) or (i == 5 and t < 0.35)
			actor.heavy = i == 3
			actor.pickup_amount = clampf((t-0.5)/0.15,0,1) if i == 4 and t < 0.65 else 0.0
			actor.loading = i == 5 and t < 0.35
			if i == 4 and frame == 20: actor.picked_up()
			if i == 5 and frame == 11: actor.loaded()
			actor.animate(1.0/30,3.0 if i in [1,2,3] else 0.0)
			if i == 4 and t < 0.65:
				items[i].global_position = Vector3(0,0,0.65)
			elif i == 5:
				if t < 0.35: items[i].position = Vector3.ZERO
				else:
					var progress = clampf((t-0.35)/0.26,0,1)
					items[i].global_position = LootVan.arc_position(Vector3(0,1.8,0.3),Vector3(1.3,0.67,-0.35),progress)
					items[i].scale = Vector3.ONE.lerp(Vector3.ONE*0.38,progress)
					labels[i].text = "WHAM!" if t > 0.61 and t < 0.85 else titles[i]
			elif i >= 2: items[i].position = Vector3.ZERO
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/character_frames/frame_%03d.png" % frame)
		if frame == 28: root.get_texture().get_image().save_png("res://tests/character_states.png")
	print("CHARACTER MOTION CAPTURE COMPLETE")
	quit()
