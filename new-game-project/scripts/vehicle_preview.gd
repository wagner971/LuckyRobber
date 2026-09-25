class_name VehiclePreview
extends SubViewportContainer

var viewport: SubViewport
var van: LootVan
var camera: Camera3D
var rotating := false
var suspended := false
var clock := 0.0
var accumulated := 0.0

func setup(style: String, level: int = 1, animate: bool = false) -> void:
	var vivid := ShaderMaterial.new()
	vivid.shader = preload("res://assets/shaders/vivid_preview.gdshader")
	material = vivid
	add_to_group("menu_character_previews")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	stretch = true
	rotating = animate
	viewport = SubViewport.new()
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_2X
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	var stage := Node3D.new()
	viewport.add_child(stage)
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("0b2238")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("98b9d4")
	env.ambient_light_energy = 0.48
	world.environment = env
	stage.add_child(world)
	van = LootVan.new()
	stage.add_child(van)
	van.setup(level)
	van.zone.hide()
	van.label.hide()
	van.model.position = Vector3.ZERO
	van.set_vehicle(style)
	Models.cylinder(stage,2.65,0.14,Vector3(0,-0.01,0),Color("174257"))
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-42,-38,0)
	light.light_color = Color("fff0d3")
	light.light_energy = 1.05
	light.shadow_enabled = animate
	stage.add_child(light)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-30,145,0)
	rim.light_color = Color("70ceef")
	rim.light_energy = 0.5
	stage.add_child(rim)
	camera = Camera3D.new()
	stage.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.position = Vector3(5.5,3.8,6.2)
	camera.look_at(Vector3(0,1.0,0))
	resized.connect(resize_preview)
	resize_preview()
	set_process(animate)

func resize_preview() -> void:
	if not is_instance_valid(viewport): return
	stretch_shrink = maxi(1, ceili(size.x / 640.0))
	camera.size = maxf(3.3,6.0/maxf(0.3,size.x/maxf(size.y,1)))
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _process(delta: float) -> void:
	if suspended or not is_visible_in_tree(): return
	accumulated += delta
	if accumulated < 1.0/30.0: return
	clock += accumulated
	accumulated = 0
	van.model.rotation.y = sin(clock*0.45)*0.22
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func suspend(value: bool) -> void:
	suspended = value
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED if value else SubViewport.UPDATE_ONCE

func stop() -> void:
	suspend(true)
	set_process(false)
