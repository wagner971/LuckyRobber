class_name CashVisual
extends Control


# Menu/result preview of the user-supplied Meshy cash mesh. During a heist,
# CashBurst3D animates MeshInstance3D nodes directly in the level instead.
const CASH_MESH = preload("res://assets/cash/Meshy_AI_Cash_Bundle_0820173211_texture.obj")
const CASH_TEXTURE = preload("res://assets/cash/Meshy_AI_Cash_Bundle_0820173211_texture.png")
var viewport: SubViewport
var animated := false
var model_root: Node3D
var animation_time := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport = SubViewport.new()
	viewport.size = Vector2i(512, 384) if animated else Vector2i(256, 192)
	viewport.own_world_3d = true
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE if animated else SubViewport.UPDATE_ONCE
	add_child(viewport)
	var display = TextureRect.new()
	display.texture = viewport.get_texture()
	var vivid := ShaderMaterial.new()
	vivid.shader = preload("res://assets/shaders/vivid_preview.gdshader")
	display.material = vivid
	display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	display.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(display)
	var mesh = MeshInstance3D.new()
	mesh.mesh = CASH_MESH
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = CASH_TEXTURE
	mat.roughness = 0.95
	mesh.material_override = mat
	var bounds = CASH_MESH.get_aabb()
	var normalizer = 1.7 / maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	mesh.scale = Vector3.ONE * normalizer
	mesh.position = -bounds.get_center() * normalizer
	model_root = Node3D.new()
	viewport.add_child(model_root)
	model_root.add_child(mesh)
	var environment = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color.TRANSPARENT
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.7
	environment.environment = env
	viewport.add_child(environment)
	var key = DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-40, -30, 0)
	key.light_energy = 0.7
	viewport.add_child(key)
	var camera = Camera3D.new()
	viewport.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 1.7
	camera.position = Vector3(2.8, 2.3, 3.4)
	camera.look_at(Vector3.ZERO)
	visibility_changed.connect(func():
		if is_visible_in_tree(): viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE if animated else SubViewport.UPDATE_ONCE
		else: viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED)
	set_process(animated)

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	animation_time += delta
	model_root.rotation.y = sin(animation_time * 1.1) * 0.13
	model_root.rotation.z = sin(animation_time * 0.85) * 0.025
