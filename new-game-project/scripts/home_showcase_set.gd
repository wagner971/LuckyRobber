class_name HomeShowcaseSet
extends Node3D

# One shared 3D set for the background, player, loot and van. The preview owns
# its update clock, so particles and rendering suspend with the menu.
const PARTICLE_COUNT := 44
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

func build_garage() -> void:
	var floor := Models.box(self, Vector3(24, 0.16, 28), Vector3(0, -0.30, -2), Color("4f1279"))
	var floor_material := ShaderMaterial.new()
	floor_material.shader = preload("res://assets/shaders/home_floor.gdshader")
	floor.material_override = floor_material
	floor.name = "GarageFloor"
	# Low-contrast structural shapes leave a quiet background behind the logo.
	Models.box(self, Vector3(18, 8, 0.25), Vector3(0, 3.6, -4.5), Color("65179c"))
	Models.box(self, Vector3(18, 0.12, 0.32), Vector3(0, 2.6, -4.3), Color("8128bf"))
	for x in [-4.5, -3.2, -1.1, 1.65]:
		Models.box(self, Vector3(0.16, 7.0, 0.3), Vector3(x, 3.0, -4.22), Color("380959"))
	# Garage shutter, warm work bay and utility cabinets echo the blocky models.
	Models.box(self, Vector3(2.35, 3.3, 0.16), Vector3(0.35, 1.40, -4.23), Color("31094c"))
	for i in range(13):
		Models.box(self, Vector3(2.22, 0.19, 0.045), Vector3(0.35, 0.12 + i * 0.23, -4.12), Color("551680"))
	for x in [-0.87, 1.57]:
		Models.box(self, Vector3(0.09, 3.6, 0.22), Vector3(x, 1.45, -4.02), Color("8136b5"))
	for x in [-2.85, -2.18]:
		Models.box(self, Vector3(0.62, 1.68, 0.43), Vector3(x, 0.62, -4.0), Color("7312b6"))
		for y in [0.38, 1.06]:
			Models.box(self, Vector3(0.51, 0.56, 0.055), Vector3(x, y, -3.76), Color("541083"))
			Models.box(self, Vector3(0.035, 0.15, 0.035), Vector3(x + 0.18, y, -3.71), Color("b67bdf"))
	for x in [-3.45, 0.65]:
		Models.box(self, Vector3(0.62, 0.20, 0.30), Vector3(x, 1.83, -3.96), Color("291139"))
		var lamp := Models.box(self, Vector3(0.46, 0.06, 0.24), Vector3(x, 1.72, -3.91), Color("ffd9a2"))
		emissive(lamp, Color("ffc477"))
		var light := OmniLight3D.new()
		light.position = Vector3(x, 1.55, -3.65)
		light.light_color = Color("ffb764")
		light.light_energy = 1.2
		light.omni_range = 3.4
		light.light_cull_mask = 2
		add_child(light)
		var haze := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0.18
		cone.bottom_radius = 0.82
		cone.height = 1.9
		cone.radial_segments = 24
		cone.cap_top = false
		cone.cap_bottom = false
		haze.mesh = cone
		haze.position = Vector3(x, 0.73, -3.68)
		haze.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var haze_material := ShaderMaterial.new()
		haze_material.shader = preload("res://assets/shaders/home_uplight.gdshader")
		haze_material.set_shader_parameter("beam_color", Color("ffc68a"))
		haze_material.set_shader_parameter("strength", 0.085)
		haze_material.set_shader_parameter("downward", true)
		haze.material_override = haze_material
		add_child(haze)
	# A few large readable props, kept to the edge of the character silhouette.
	crate(Vector3(-2.55, 0.02, -1.70), Vector3(0.65, 0.55, 0.60))
	crate(Vector3(-2.58, 0.53, -1.72), Vector3(0.54, 0.48, 0.54))
	crate(Vector3(-3.13, 0.0, -1.20), Vector3(0.48, 0.48, 0.54))
	for x in [-1.55, -1.0]:
		var trim := Models.box(self, Vector3(0.025, 1.18, 0.035), Vector3(x, 1.5, -4.05), Color("7431a2"))
		emissive(trim, Color("6b239d"), 0.6)
	light_pool(self, Vector3(0.1, -0.208, 0.5), Vector2(5.8, 4.7), Color("8118ca"), 0.17)
	light_pool(self, Vector3(2.8, -0.206, -2.3), Vector2(4.0, 5.2), Color("edaa62"), 0.10)

func crate(at: Vector3, dimensions: Vector3) -> void:
	Models.box(self, dimensions, at, Color("855024"))
	for x in [-1.0, 1.0]:
		Models.box(self, Vector3(0.07, dimensions.y, dimensions.z + 0.018), at + Vector3(x * dimensions.x * 0.37, 0, 0), Color("c18a34"))
	for y in [-1.0, 1.0]:
		Models.box(self, Vector3(dimensions.x + 0.02, 0.05, dimensions.z + 0.03), at + Vector3(0, y * dimensions.y * 0.43, 0), Color("756650"))

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
	# Short cyan inserts sit in the dark faceted plinth instead of a solid glowing slab.
	for i in range(8):
		var angle := TAU * float(i) / 8.0 + PI / 8.0
		var at := stage_center + Vector3(sin(angle) * 1.49, -0.105, cos(angle) * 1.49)
		var insert := Models.box(parent, Vector3(0.48, 0.035, 0.025), at, Color("bb65f7"))
		insert.rotation.y = angle
		emissive(insert, Color("9530db"), 1.4)
	for x in [-1.05, 1.14]:
		var at := Vector3(x, 0.014, 0.91)
		var socket := Models.cylinder(parent, 0.13, 0.035, at, Color("2e1043"))
		(socket.mesh as CylinderMesh).radial_segments = 12
		var lens := Models.cylinder(parent, 0.084, 0.008, at + Vector3(0, 0.022, 0), Color("94fff0"))
		emissive(lens, Color("a749e9"), 1.5)
		light_pool(parent, at + Vector3(0, 0.029, 0), Vector2(0.58, 0.58), Color("4ef4e0"), 0.38)
		var beam := MeshInstance3D.new()
		beam.name = "PlatformUplightLeft" if x < 0.0 else "PlatformUplightRight"
		var cone := CylinderMesh.new()
		cone.top_radius = 0.56
		cone.bottom_radius = 0.055
		cone.height = 2.9
		cone.radial_segments = 32
		cone.cap_top = false
		cone.cap_bottom = false
		beam.mesh = cone
		beam.position = at + Vector3(0, 1.46, 0)
		beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var material := ShaderMaterial.new()
		material.shader = preload("res://assets/shaders/home_uplight.gdshader")
		material.set_shader_parameter("beam_color", Color("bb59ff"))
		material.set_shader_parameter("strength", 0.22)
		beam.material_override = material
		parent.add_child(beam)
		var light := OmniLight3D.new()
		light.name = "PlatformBounce"
		light.position = at + Vector3(0, 0.15, 0)
		light.light_color = Color("b566ec")
		light.light_energy = 0.18
		light.light_cull_mask = 1
		light.omni_range = 2.0
		parent.add_child(light)

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
		var color := Color("ffd9a0") if i % 5 == 0 else Color("6cf8e5")
		motes.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * scale), at))
		motes.multimesh.set_instance_color(i, Color(color, alpha))
