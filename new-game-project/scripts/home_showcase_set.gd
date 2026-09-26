class_name HomeShowcaseSet
extends Node3D

# One shared 3D set for the Home background: a night garage full of Lucky
# Blocks around the character's spotlit platform. The preview owns the update
# clock, so particles and rendering suspend with the menu.
#
# Camera mapping (orthographic, from +x/+z): screen_x ~ 0.908x - 0.363z,
# screen_y ~ 0.956y - 0.190z. Props are placed by where they land on screen.
const PARTICLE_COUNT := 44
const BLOCK_TINT := Color("7a1fd4")
const BLOCK_FRAME := Color("f2b21b")
const BLOCK_MARK := Color("ffd23c")
var motes: MultiMeshInstance3D
var stage_center := Vector3(0.18, 0.0, 0.38)

func build(display_stage: Node3D) -> void:
	name = "HomeShowcaseSet"
	build_garage()
	for node in find_children("*", "MeshInstance3D", true, false):
		node.layers = 3 if node.name == "GarageFloor" else 2
	build_platform(display_stage)
	build_particles(display_stage)
	animate(0.0)

func emissive(mesh: MeshInstance3D, color: Color, energy: float = 1.0) -> void:
	var material := mesh.material_override as StandardMaterial3D
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func lamp_light(at: Vector3, color: Color, energy: float, range_units: float) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.position = at
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_units
	light.light_cull_mask = 2
	add_child(light)
	return light

func build_garage() -> void:
	var floor := Models.box(self, Vector3(26, 0.16, 30), Vector3(0, -0.30, -2), Color("2a1640"))
	var floor_material := ShaderMaterial.new()
	floor_material.shader = preload("res://assets/shaders/home_floor.gdshader")
	floor.material_override = floor_material
	floor.name = "GarageFloor"
	# Back wall: dark concrete panels with a purple neon line and a warm strip.
	Models.box(self, Vector3(20, 9, 0.25), Vector3(-1.5, 4.0, -4.5), Color("2f1747"))
	for x in [-5.6, -4.1, -2.65, 0.3, 1.7]:
		Models.box(self, Vector3(0.14, 8.0, 0.3), Vector3(x, 3.6, -4.30), Color("1e0c30"))
	var neon := Models.box(self, Vector3(20, 0.05, 0.05), Vector3(-1.5, 3.05, -4.34), Color("c86bff"))
	emissive(neon, Color("b04dff"), 1.4)
	Models.box(self, Vector3(20, 0.18, 0.32), Vector3(-1.5, 2.85, -4.28), Color("3d1f5c"))
	# Garage shutter, centred on screen behind the character.
	var door_x := -0.5
	Models.box(self, Vector3(2.9, 3.4, 0.16), Vector3(door_x, 1.42, -4.22), Color("463060"))
	for i in range(12):
		Models.box(self, Vector3(2.76, 0.21, 0.05), Vector3(door_x, 0.16 + i * 0.26, -4.11), Color("5b3f79"))
	for x in [door_x - 1.52, door_x + 1.52]:
		Models.box(self, Vector3(0.12, 3.6, 0.24), Vector3(x, 1.5, -4.02), Color("8a53b8"))
	var door_window := Models.box(self, Vector3(1.9, 0.5, 0.03), Vector3(door_x, 2.55, -4.08), Color("7b3cc9"))
	emissive(door_window, Color("6b2ab8"), 0.9)
	# Pegboard with tools, left of the shutter.
	Models.box(self, Vector3(1.5, 1.35, 0.06), Vector3(-2.9, 1.85, -4.15), Color("3a2551"))
	for i in range(5):
		var x := -3.45 + i * 0.27
		Models.box(self, Vector3(0.05, 0.42, 0.05), Vector3(x, 1.95, -4.08), Color("cfd3dc") if i % 2 == 0 else Color("f3c33a"))
		Models.box(self, Vector3(0.13, 0.11, 0.05), Vector3(x, 2.2, -4.08), Color("8d94a3"))
	# Hanging fluorescent lamp: the warm key for the whole garage.
	Models.box(self, Vector3(0.04, 1.4, 0.04), Vector3(-1.0, 3.9, -2.5), Color("120818"))
	Models.box(self, Vector3(1.9, 0.14, 0.42), Vector3(-1.0, 3.2, -2.5), Color("241329"))
	var tube := Models.box(self, Vector3(1.72, 0.05, 0.28), Vector3(-1.0, 3.12, -2.5), Color("fff0c8"))
	emissive(tube, Color("ffd591"), 1.6)
	lamp_light(Vector3(-1.0, 2.9, -2.4), Color("ffbe6e"), 2.1, 7.0)
	lamp_light(Vector3(-1.5, 2.2, -4.0), Color("ffb877"), 1.1, 5.0)
	var haze := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.7
	cone.bottom_radius = 2.3
	cone.height = 3.1
	cone.radial_segments = 24
	cone.cap_top = false
	cone.cap_bottom = false
	haze.mesh = cone
	haze.position = Vector3(-1.0, 1.6, -2.5)
	haze.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var haze_material := ShaderMaterial.new()
	haze_material.shader = preload("res://assets/shaders/home_uplight.gdshader")
	haze_material.set_shader_parameter("beam_color", Color("ffc68a"))
	haze_material.set_shader_parameter("strength", 0.07)
	haze_material.set_shader_parameter("downward", true)
	haze.material_override = haze_material
	add_child(haze)
	# Left: shelving rack stacked with Lucky Blocks and crates.
	rack(Vector3(-2.65, 0, -2.9), 1.4, 2.5, 0.6)
	lucky_block(Vector3(-2.95, 0.05, -2.9), 0.42)
	lucky_block(Vector3(-2.35, 0.05, -2.9), 0.42)
	crate(Vector3(-2.65, 1.15, -2.9), Vector3(0.62, 0.42, 0.5))
	lucky_block(Vector3(-2.3, 1.68, -2.9), 0.40)
	lucky_block(Vector3(-2.95, 1.68, -2.9), 0.40)
	plant(Vector3(-3.35, 2.32, -2.9))
	# Left: red tool cabinet.
	toolbox(Vector3(-1.85, 0, -1.65))
	# Left foreground: Lucky Blocks on the floor.
	lucky_block(Vector3(-1.66, 0.0, 0.25), 0.72)
	lucky_block(Vector3(-1.62, 0.62, 0.25), 0.58)
	lucky_block(Vector3(-2.0, 0.0, 1.05), 0.66)
	# Right: shelving with blocks, tyres and a cone.
	rack(Vector3(0.36, 0, -3.5), 1.5, 2.5, 0.6)
	lucky_block(Vector3(0.05, 0.05, -3.5), 0.44)
	lucky_block(Vector3(0.7, 0.05, -3.5), 0.44)
	lucky_block(Vector3(0.36, 1.15, -3.5), 0.46)
	crate(Vector3(0.36, 2.2, -3.5), Vector3(0.7, 0.44, 0.5))
	lucky_block(Vector3(1.05, 0.0, -1.85), 0.7)
	lucky_block(Vector3(1.05, 0.6, -1.85), 0.56)
	lucky_block(Vector3(1.7, 0.0, -1.35), 0.62)
	tyres(Vector3(1.55, 0, -0.55), 4)
	tyres(Vector3(2.05, 0, 0.1), 3)
	lucky_block(Vector3(2.0, 0.0, 0.85), 0.8)
	lucky_block(Vector3(1.98, 0.7, 0.85), 0.62)
	cone_prop(Vector3(0.72, 0, -1.0))
	# Purple neon under the shelving and along the far wall base.
	for x in [-2.65, 0.36]:
		var strip := Models.box(self, Vector3(1.3, 0.03, 0.03), Vector3(x, 0.03, -3.2 if x < 0 else -3.8), Color("b356ff"))
		emissive(strip, Color("9b3cff"), 1.2)
	lamp_light(Vector3(-2.6, 0.7, -2.2), Color("b36bff"), 0.55, 3.6)
	lamp_light(Vector3(1.3, 0.7, -2.4), Color("b36bff"), 0.55, 3.6)
	light_pool(self, Vector3(0.1, -0.208, 0.5), Vector2(6.2, 5.0), Color("8f2aff"), 0.16)
	light_pool(self, Vector3(-1.0, -0.206, -2.4), Vector2(4.6, 4.2), Color("f0a95a"), 0.11)

func lucky_block(at: Vector3, block_scale: float) -> void:
	var block := LuckyEffects.model(BLOCK_TINT, BLOCK_FRAME, BLOCK_MARK)
	block.position = at
	block.scale = Vector3.ONE * block_scale
	block.rotation.y = fmod(at.x * 1.7 + at.z * 0.9, 0.5) - 0.25
	add_child(block)

func rack(at: Vector3, width: float, height: float, depth: float) -> void:
	for x in [-1.0, 1.0]:
		for z in [-1.0, 1.0]:
			Models.box(self, Vector3(0.06, height, 0.06), at + Vector3(x * width * 0.5, height * 0.5, z * depth * 0.5), Color("5b6270"))
	for y in [0.0, height * 0.42, height * 0.84]:
		Models.box(self, Vector3(width + 0.04, 0.05, depth + 0.02), at + Vector3(0, y + 0.02, 0), Color("7d8593"))

func crate(at: Vector3, dimensions: Vector3) -> void:
	Models.box(self, dimensions, at + Vector3(0, dimensions.y * 0.5, 0), Color("9a5a2a"))
	for x in [-1.0, 1.0]:
		Models.box(self, Vector3(0.06, dimensions.y, dimensions.z + 0.018), at + Vector3(x * dimensions.x * 0.38, dimensions.y * 0.5, 0), Color("d29a45"))

func plant(at: Vector3) -> void:
	Models.cylinder(self, 0.14, 0.2, at + Vector3(0, 0.1, 0), Color("b8612e"))
	for i in range(3):
		var leaf := Models.box(self, Vector3(0.09, 0.32, 0.09), at + Vector3(sin(i * 2.1) * 0.07, 0.36, cos(i * 2.1) * 0.07), Color("4fb85a"))
		leaf.rotation.z = sin(i * 2.1) * 0.35

func toolbox(at: Vector3) -> void:
	Models.box(self, Vector3(1.0, 1.05, 0.55), at + Vector3(0, 0.55, 0), Color("c8202a"))
	for i in range(4):
		Models.box(self, Vector3(0.86, 0.17, 0.04), at + Vector3(0, 0.2 + i * 0.22, 0.29), Color("e33b3f"))
		Models.box(self, Vector3(0.3, 0.035, 0.03), at + Vector3(0, 0.2 + i * 0.22, 0.315), Color("d9dde5"))
	Models.box(self, Vector3(1.04, 0.05, 0.6), at + Vector3(0, 1.1, 0), Color("2b2735"))
	for x in [-0.4, 0.4]: Models.cylinder(self, 0.07, 0.06, at + Vector3(x, 0.03, 0.2), Color("15121a"))

func tyres(at: Vector3, count: int) -> void:
	for i in range(count):
		var tyre := Models.cylinder(self, 0.34, 0.17, at + Vector3(0, 0.085 + i * 0.18, 0), Color("1c1a22"))
		(tyre.mesh as CylinderMesh).radial_segments = 20
		var rim := Models.cylinder(self, 0.17, 0.18, at + Vector3(0, 0.085 + i * 0.18, 0), Color("6f7480"))
		(rim.mesh as CylinderMesh).radial_segments = 12

func cone_prop(at: Vector3) -> void:
	Models.box(self, Vector3(0.36, 0.04, 0.36), at + Vector3(0, 0.02, 0), Color("ff6a1f"))
	var body := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.045
	cone.bottom_radius = 0.15
	cone.height = 0.5
	cone.radial_segments = 12
	body.mesh = cone
	body.material_override = Models.material(Color("ff6a1f"))
	body.position = at + Vector3(0, 0.29, 0)
	add_child(body)
	var band := Models.cylinder(self, 0.115, 0.07, at + Vector3(0, 0.3, 0), Color("f4f1ec"))
	(band.mesh as CylinderMesh).top_radius = 0.095

func radial_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.2, 0.65, 1.0])
	gradient.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0.65), Color(1, 1, 1, 0.13), Color.TRANSPARENT])
	var image := GradientTexture2D.new()
	image.width = 64
	image.height = 64
	image.gradient = gradient
	image.fill = GradientTexture2D.FILL_RADIAL
	image.fill_from = Vector2(0.5, 0.5)
	image.fill_to = Vector2(1.0, 0.5)
	return image

func light_pool(parent: Node3D, at: Vector3, dimensions: Vector2, color: Color, alpha: float) -> void:
	var pool := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = dimensions
	pool.mesh = plane
	pool.position = at
	pool.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.albedo_texture = radial_texture()
	material.albedo_color = Color(color, alpha)
	pool.material_override = material
	parent.add_child(pool)

func build_platform(parent: Node3D) -> void:
	# A continuous purple neon ring around the plinth, plus a soft pool on the floor.
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 1.52
	torus.outer_radius = 1.60
	torus.rings = 48
	torus.ring_segments = 8
	ring.mesh = torus
	ring.position = stage_center + Vector3(0, -0.02, 0)
	ring.material_override = Models.material(Color("c86bff"))
	emissive(ring, Color("a746ff"), 1.6)
	parent.add_child(ring)
	var outer := MeshInstance3D.new()
	var outer_torus := TorusMesh.new()
	outer_torus.inner_radius = 1.70
	outer_torus.outer_radius = 1.74
	outer_torus.rings = 48
	outer_torus.ring_segments = 6
	outer.mesh = outer_torus
	outer.position = stage_center + Vector3(0, -0.19, 0)
	outer.material_override = Models.material(Color("9d4cff"))
	emissive(outer, Color("8b30e0"), 1.0)
	parent.add_child(outer)
	light_pool(parent, stage_center + Vector3(0, -0.2, 0), Vector2(4.2, 4.2), Color("a34dff"), 0.11)
	var glow := OmniLight3D.new()
	glow.name = "PlatformGlow"
	glow.position = stage_center + Vector3(0, 0.35, 0)
	glow.light_color = Color("b466ff")
	glow.light_energy = 0.22
	glow.light_cull_mask = 3
	glow.omni_range = 2.6
	parent.add_child(glow)

func build_particles(parent: Node3D) -> void:
	motes = MultiMeshInstance3D.new()
	motes.name = "PlatformMotes"
	motes.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.billboard_keep_scale = true
	material.vertex_color_use_as_albedo = true
	material.albedo_texture = radial_texture()
	var sprite := QuadMesh.new()
	sprite.size = Vector2.ONE
	sprite.material = material
	var particles := MultiMesh.new()
	particles.transform_format = MultiMesh.TRANSFORM_3D
	particles.use_colors = true
	particles.mesh = sprite
	particles.instance_count = PARTICLE_COUNT
	motes.multimesh = particles
	parent.add_child(motes)

func animate(time: float) -> void:
	if not is_instance_valid(motes): return
	for i in range(PARTICLE_COUNT):
		var seed := float(i) * 2.39996
		var life := fposmod(time * (0.18 + float(i % 4) * 0.022) + float(i) / PARTICLE_COUNT, 1.0)
		var angle := seed + time * 0.13
		var radius := 0.75 + float(i % 7) * 0.11
		var at := stage_center + Vector3(sin(angle) * radius, 0.025 + life * (0.7 + float(i % 3) * 0.25), cos(angle) * radius * 0.70)
		var scale := 0.024 + float(i % 5) * 0.008
		var alpha := sin(life * PI) * (0.60 if i % 4 == 0 else 0.85)
		var color := Color("ffd9a0") if i % 5 == 0 else Color("d48cff")
		motes.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * scale), at))
		motes.multimesh.set_instance_color(i, Color(color, alpha))
