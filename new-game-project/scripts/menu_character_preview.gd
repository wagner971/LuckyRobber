class_name MenuCharacterPreview
extends Control


# Same model and appearance authority as a real run, isolated from gameplay physics.
var store: SaveStore
var presentation = "home"
var viewport: SubViewport
var actor: ThiefVisual
var van: LootVan
var camera: Camera3D
var texture: TextureRect
var noise_preview_bar: ProgressBar
var stage: Node3D
var focus_loot: Node3D
var upgrade_focus := ""
var suspended = false
var accumulated = 0.0
var presentation_time = 0.0
var rendered_frames = 0
var equipped_snapshot: Dictionary = {}
var home_host: Control
var home_set: HomeShowcaseSet
var home_frame := Rect2()
var garage: GarageDecor
var garage_preview_id := ""

func configure(profile: SaveStore, kind: String, height: float) -> void:
	store = profile
	presentation = kind
	custom_minimum_size.y = height
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
	add_to_group("menu_character_previews")
	if presentation == "garage":
		build_owned_garage()
		return
	viewport = SubViewport.new()
	viewport.name = "LiveCharacterViewport"
	viewport.own_world_3d = true
	viewport.transparent_bg = presentation != "home"
	viewport.handle_input_locally = false
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	viewport.positional_shadow_atlas_size = 1024 if presentation == "home" else 0
	viewport.msaa_3d = Viewport.MSAA_2X if presentation == "home" else Viewport.MSAA_4X
	add_child(viewport)
	texture = TextureRect.new()
	texture.texture = viewport.get_texture()
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_SCALE
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if presentation == "home":
		texture.name = "HomeWarehouseBackdrop"
		var composite := ShaderMaterial.new()
		composite.shader = preload("res://assets/shaders/home_showcase_composite.gdshader")
		texture.material = composite
	else:
		var vivid := ShaderMaterial.new()
		vivid.shader = preload("res://assets/shaders/vivid_preview.gdshader")
		texture.material = vivid
	add_child(texture)
	if presentation == "upgrades":
		noise_preview_bar = ProgressBar.new()
		noise_preview_bar.show_percentage = false
		noise_preview_bar.value = 60
		noise_preview_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		noise_preview_bar.anchor_left = 0.72
		noise_preview_bar.anchor_right = 0.96
		noise_preview_bar.anchor_top = 0.76
		noise_preview_bar.anchor_bottom = 0.76
		noise_preview_bar.offset_bottom = 10
		noise_preview_bar.add_theme_stylebox_override("background", HudStyle.track(Color("2b0b42")))
		noise_preview_bar.add_theme_stylebox_override("fill", HudStyle.track(Color("daa4ff")))
		noise_preview_bar.visible = false
		add_child(noise_preview_bar)
	var environment = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("1b0828") if presentation == "home" else Color.TRANSPARENT
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c9cedf") if presentation == "home" else Color("e5f0ff")
	env.ambient_light_energy = 0.50
	environment.environment = env
	viewport.add_child(environment)
	var key = DirectionalLight3D.new()
	key.name = "StreetLampKey"
	key.rotation_degrees = Vector3(-55,-35,0) if presentation == "home" else Vector3(-38,-25,0)
	key.light_color = Color("fff2dd") if presentation == "home" else Color("fff4e5")
	key.light_energy = 0.85 if presentation == "home" else 0.9
	key.shadow_enabled = presentation == "home"
	if presentation == "home":
		key.light_cull_mask = 1
		key.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		key.directional_shadow_max_distance = 16.0
	viewport.add_child(key)
	if presentation == "home":
		var rim = DirectionalLight3D.new()
		rim.name = "NightRim"
		rim.rotation_degrees = Vector3(-35, 145, 0)
		rim.light_color = Color("a848eb")
		rim.light_energy = 0.60
		rim.light_cull_mask = 1
		viewport.add_child(rim)
		var cyan_edge = OmniLight3D.new()
		cyan_edge.name = "CyanEdge"
		cyan_edge.position = Vector3(-0.7, 1.8, -1.2)
		cyan_edge.light_color = Color("b255f2")
		cyan_edge.light_energy = 0.25
		cyan_edge.light_cull_mask = 1
		cyan_edge.omni_range = 3.4
		viewport.add_child(cyan_edge)
		var garage_light = OmniLight3D.new()
		garage_light.name = "GarageBounce"
		garage_light.position = Vector3(2.2, 2.7, -1.7)
		garage_light.light_color = Color("ffb66e")
		garage_light.light_energy = 0.60
		garage_light.light_cull_mask = 1
		garage_light.omni_range = 4.5
		viewport.add_child(garage_light)
	stage = Node3D.new()
	viewport.add_child(stage)
	var stage_radius = 1.60 if presentation == "home" else 1.0
	var stage_x = 0.18 if presentation == "home" else -0.35
	var stage_base = Models.cylinder(stage,stage_radius,0.16,Vector3(stage_x,-0.10,0.38),Color("500782"))
	var stage_top = Models.cylinder(stage,stage_radius - 0.06,0.025,Vector3(stage_x,-0.01,0.38),Color("60089e"))
	if presentation == "home":
		(stage_base.mesh as CylinderMesh).radial_segments = 8
		(stage_top.mesh as CylinderMesh).radial_segments = 8
		var stage_edge := Models.cylinder(stage, stage_radius - 0.025, 0.014, Vector3(stage_x, -0.028, 0.38), Color("ae58ea"))
		(stage_edge.mesh as CylinderMesh).radial_segments = 8
		var edge_material := stage_edge.material_override as StandardMaterial3D
		edge_material.emission_enabled = true
		edge_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		edge_material.emission = Color("8b30cb")
		edge_material.emission_energy_multiplier = 0.8
	Models.set_toon_profile(stage_base, ToonMaterial.Profile.GROUND)
	Models.set_toon_profile(stage_top, ToonMaterial.Profile.GROUND)
	if presentation == "home":
		var van_shadow := Models.cylinder(stage, 1.0, 0.006, Vector3(0.43, -0.205, -1.12), Color("13071ca0"))
		van_shadow.scale = Vector3(1.38, 1.0, 0.65)
		var van_shadow_material := van_shadow.material_override as StandardMaterial3D
		van_shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		van_shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		Models.set_toon_profile(van_shadow, ToonMaterial.Profile.GROUND)
	actor = Models.thief()
	actor.position = Vector3(0.12 if presentation == "home" else -0.35,0,0.40)
	if presentation == "home": actor.scale = Vector3.ONE * 1.20
	stage.add_child(actor)
	if presentation == "home":
		var foot_shadow := Models.cylinder(stage, 0.48, 0.006, Vector3(0.12, 0.009, 0.40), Color("1c072b9c"))
		foot_shadow.name = "FootContactShadow"
		foot_shadow.scale.z = 0.70
		var shadow_material := foot_shadow.material_override as StandardMaterial3D
		shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	van = LootVan.new()
	stage.add_child(van)
	van.setup(1)
	Models.set_toon_profile(van.model, ToonMaterial.Profile.CHARACTER)
	van.model.position = Vector3(0.54,0,-1.12) if presentation == "home" else Vector3(1.05,0,-0.8)
	if presentation == "home": van.model.position.y = -0.20
	van.model.scale = Vector3.ONE * (0.42 if presentation == "home" else 0.52)
	van.zone.hide()
	for child in van.get_children():
		if child is Label3D: child.hide()
	if presentation == "home":
		var fridge = Models.loot("fridge")
		stage.add_child(fridge)
		fridge.position = Vector3(-1.02,0,-0.35)
		fridge.scale = Vector3.ONE * 0.52
		fridge.rotation.y = 0.2
		home_set = HomeShowcaseSet.new()
		viewport.add_child(home_set)
		home_set.build(stage)
	camera = Camera3D.new()
	viewport.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.45 if presentation != "upgrades" else 2.55
	camera.position = Vector3(2.4,2.0 if presentation == "home" else 1.95,6)
	camera.look_at(Vector3(0,0.62 if presentation == "home" else 0.92,0))
	camera.current = true
	store.appearance_changed.connect(refresh_appearance)
	refresh_appearance()
	resized.connect(resize_viewport)
	resize_viewport()
	if presentation == "upgrades": set_upgrade_focus("strength")

func attach_home_backdrop(host: Control) -> void:
	if presentation != "home": return
	home_host = host
	texture.reparent(host)
	texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.move_child(texture, 1)
	host.resized.connect(resize_viewport)
	item_rect_changed.connect(resize_viewport)
	resize_viewport()

func set_upgrade_focus(key: String) -> void:
	if presentation != "upgrades" or not is_instance_valid(actor): return
	upgrade_focus = key
	if is_instance_valid(focus_loot): focus_loot.queue_free()
	actor.carrying = key in ["strength", "carry"]
	actor.heavy = key == "strength"
	if is_instance_valid(noise_preview_bar): noise_preview_bar.visible = key == "noise"
	if key in ["strength", "carry"]:
		focus_loot = Models.loot("fridge" if key == "strength" else "small_tv")
		actor.carry_anchor.add_child(focus_loot)
		focus_loot.position = Vector3(0, -0.38 if key == "strength" else -0.20, 0.50)
		focus_loot.scale = Vector3.ONE * (0.43 if key == "strength" else 0.52)
	elif key == "grip": actor.picked_up()
	if is_instance_valid(van): van.model.scale = Vector3.ONE * 0.52
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func resize_viewport() -> void:
	if viewport == null: return
	if presentation == "home" and is_instance_valid(home_host):
		var full_size := home_host.size
		if full_size.x < 1.0 or full_size.y < 1.0 or size.x < 1.0: return
		var render_scale := minf(1.0, minf(576.0 / full_size.x, 1152.0 / full_size.y))
		viewport.size = Vector2i(maxi(1, roundi(full_size.x * render_scale)), maxi(1, roundi(full_size.y * render_scale)))
		if camera != null:
			var world_width := 3.75 * full_size.x / size.x
			camera.size = world_width * full_size.y / full_size.x
			var hero_center := get_global_rect().get_center() - home_host.global_position
			camera.v_offset = (hero_center.y + 22.0 - full_size.y * 0.5) * camera.size / full_size.y
		home_frame = get_global_rect()
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		return
	var ratio = minf(1.0,minf(640.0/maxf(1,size.x),480.0/maxf(1,size.y)))
	viewport.size = Vector2i(maxi(1,roundi(size.x*ratio)),maxi(1,roundi(size.y*ratio)))
	if camera != null: camera.size = maxf(6.8 if presentation == "garage" else 2.45,(10.4 if presentation == "garage" else 3.7) / maxf(0.2,float(viewport.size.x)/viewport.size.y))
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func refresh_appearance() -> void:
	if not is_instance_valid(actor): return
	Models.apply_appearance(actor,van.model,store.data.cosmetics.equipped)
	if is_instance_valid(garage): garage.build(store.data.garage_owned, garage_preview_id)
	equipped_snapshot = store.data.cosmetics.equipped.duplicate(true)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func suspend(value: bool) -> void:
	suspended = value
	if viewport != null: viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func stop() -> void:
	suspend(true)
	set_process(false)

func _process(delta: float) -> void:
	if suspended or not is_visible_in_tree(): return
	accumulated += delta
	if accumulated < 1.0/30.0: return
	var step = minf(accumulated,0.1)
	accumulated = 0.0
	presentation_time += step
	if presentation == "home" and is_instance_valid(home_set):
		if home_frame != get_global_rect(): resize_viewport()
		home_set.animate(presentation_time)
	actor.animate(step, 3.2 if presentation == "upgrades" and upgrade_focus == "carry" else 0.0)
	actor.rotation.y = -0.06 + sin(presentation_time*0.5)*0.08
	actor.body.rotation.z += sin(presentation_time*1.2)*0.012
	if presentation == "upgrades" and upgrade_focus == "capacity":
		van.model.scale = Vector3.ONE * (0.52 + sin(presentation_time * 4.0) * 0.035)
	if is_instance_valid(noise_preview_bar) and upgrade_focus == "noise":
		noise_preview_bar.value = 55.0 + 12.0 * absf(sin(presentation_time * 2.5))
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	rendered_frames += 1

func preview_furniture(id: String) -> void:
	garage_preview_id = id
	if is_instance_valid(garage): garage.build(store.data.garage_owned,id)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func celebrate_furniture(id: String) -> void:
	var prop := garage.props.get_node_or_null("Decor_" + id)
	if prop is Node3D:
		var final_scale: Vector3 = prop.scale
		prop.scale *= 0.1
		prop.create_tween().tween_property(prop,"scale",final_scale,0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func build_owned_garage() -> void:
	viewport = SubViewport.new()
	viewport.own_world_3d = true
	viewport.transparent_bg = false
	viewport.handle_input_locally = false
	viewport.msaa_3d = Viewport.MSAA_2X
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	texture = TextureRect.new()
	texture.texture = viewport.get_texture()
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_SCALE
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var vivid := ShaderMaterial.new()
	vivid.shader = preload("res://assets/shaders/vivid_preview.gdshader")
	texture.material = vivid
	add_child(texture)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("1f0a2d")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("bc99d5")
	env.ambient_light_energy = 0.65
	environment.environment = env
	viewport.add_child(environment)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-55,-25,0)
	key.light_color = Color("ffe4c1")
	key.light_energy = 1.0
	key.shadow_enabled = true
	viewport.add_child(key)
	stage = Node3D.new()
	viewport.add_child(stage)
	garage = GarageDecor.new()
	stage.add_child(garage)
	actor = Models.thief()
	actor.position = Vector3(-0.25,0,2)
	actor.scale = Vector3.ONE * 1.1
	stage.add_child(actor)
	van = LootVan.new()
	stage.add_child(van)
	van.setup(1)
	van.model.position = Vector3(2.3,0,1.4)
	van.model.scale = Vector3.ONE * 0.68
	van.model.rotation.y = -0.3
	van.zone.hide()
	van.label.hide()
	camera = Camera3D.new()
	viewport.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.position = Vector3(3.0,6.7,10)
	camera.look_at(Vector3(0,0.45,0))
	camera.current = true
	store.appearance_changed.connect(refresh_appearance)
	refresh_appearance()
	resized.connect(resize_viewport)
	resize_viewport()
