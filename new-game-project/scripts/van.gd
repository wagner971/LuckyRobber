class_name LootVan
extends Node3D

signal cargo_landed
var visual_tweens: Array[Tween] = []
var impact_tween: Tween
var last_impact_weight := "MEDIUM"
var last_impact_value := 0

var model: Node3D
var cargo_anchor: Node3D
var money_burst_origin: Node3D
var zone: MeshInstance3D
var label: Label3D
var load_position = Vector3(0, 0, 4.35)
var pulse = 0.0
var appearance_level := 1
var vehicle_style := ""

func setup(level: int) -> void:
	appearance_level = level
	model = Node3D.new()
	add_child(model)
	model.position = Vector3(2.55, 0, 4.65)
	build_van_body(level)
	cargo_anchor = Node3D.new()
	model.add_child(cargo_anchor)
	money_burst_origin = Node3D.new()
	money_burst_origin.name = "MoneyBurstOrigin"
	money_burst_origin.position = load_position + Vector3(1.0, 1.2, 0)
	add_child(money_burst_origin)
	zone = Models.cylinder(self, 1.0, 0.035, load_position + Vector3.UP * 0.02, Color("61c6ac"))
	Models.set_toon_profile(zone, ToonMaterial.Profile.MARKER)
	label = Label3D.new()
	label.text = "LOAD / ESCAPE"
	label.font_size = 32
	label.pixel_size = 0.009
	label.position = load_position + Vector3(0, 0.05, 0.5)
	label.rotation_degrees.x = -90
	add_child(label)


func set_vehicle(style: String) -> void:
	if style == vehicle_style: return
	vehicle_style = style
	for child in model.get_children():
		if child == cargo_anchor: continue
		model.remove_child(child)
		child.free()
	build_van_body(appearance_level)
	if style != "": VehicleModels.customize(model, style, 3.3 + float(clampi(appearance_level,1,20)-1)/19.0*0.8)
	model.set_meta("vehicle_style", style)

func build_van_body(level: int) -> void:
	# +X is the cab; -X is the loading end facing the building on every map.
	var length := 3.3 + float(clampi(level, 1, 20) - 1) / 19.0 * 0.8
	var rear := -length * 0.5
	var front := length * 0.5
	var cargo_front := front - 1.05
	var cargo_length := cargo_front - rear
	var cargo_mid := (rear + cargo_front) * 0.5
	var paint := Color("ffab05")
	var highlight := Color("ffd141")
	var trim := Color("244354")
	var glass := Color("284e68")

	# The first two children remain chassis and tintable body for saved van cosmetics.
	van_box("Chassis", Vector3(length, 0.24, 1.46), Vector3(0, 0.48, 0), trim)
	van_box("CargoRoof", Vector3(cargo_length, 0.16, 1.58), Vector3(cargo_mid, 1.94, 0), paint)
	van_box("CargoFloor", Vector3(cargo_length, 0.13, 1.34), Vector3(cargo_mid, 0.69, 0), trim)
	for side in [-1.0, 1.0]:
		var z: float = side * 0.76
		van_box("CargoSide", Vector3(cargo_length, 1.25, 0.11), Vector3(cargo_mid, 1.31, z), paint)
		van_box("SideBelt", Vector3(cargo_length - 0.1, 0.09, 0.035), Vector3(cargo_mid, 0.83, z + side * 0.075), trim)
		van_box("SideStripe", Vector3(cargo_length - 0.16, 0.1, 0.025), Vector3(cargo_mid, 1.13, z + side * 0.075), highlight)
		van_box("SlidingDoorSeam", Vector3(0.035, 0.73, 0.025), Vector3(cargo_mid + 0.18, 1.42, z + side * 0.083), trim)
		van_box("SlidingDoorHandle", Vector3(0.18, 0.06, 0.04), Vector3(cargo_mid + 0.29, 1.43, z + side * 0.103), trim)
		van_box("RoofRail", Vector3(cargo_length - 0.2, 0.055, 0.075), Vector3(cargo_mid, 2.05, side * 0.59), highlight)

	# Short bonnet and upright cabin give the roof a recognizable van profile.
	van_box("CabLower", Vector3(1.05, 0.88, 1.52), Vector3(front - 0.53, 0.98, 0), paint)
	van_box("CabUpper", Vector3(0.77, 0.54, 1.48), Vector3(front - 0.68, 1.69, 0), paint)
	van_box("CabRoof", Vector3(0.84, 0.13, 1.57), Vector3(front - 0.71, 2.01, 0), highlight)
	van_box("Bonnet", Vector3(0.34, 0.23, 1.42), Vector3(front - 0.18, 1.37, 0), highlight)
	var windscreen := van_box("Windscreen", Vector3(0.045, 0.49, 1.28), Vector3(front - 0.27, 1.7, 0), glass)
	windscreen.rotation_degrees.z = -17
	van_box("WindscreenDivider", Vector3(0.07, 0.5, 0.045), Vector3(front - 0.27, 1.7, 0), trim).rotation_degrees.z = -17
	for side in [-1.0, 1.0]:
		var z: float = side * 0.775
		van_box("CabSideWindow", Vector3(0.49, 0.36, 0.03), Vector3(front - 0.75, 1.69, z), glass)
		van_box("CabDoorSeam", Vector3(0.035, 0.55, 0.03), Vector3(front - 0.96, 1.02, z + side * 0.015), trim)
		van_box("CabDoorHandle", Vector3(0.13, 0.045, 0.04), Vector3(front - 0.62, 1.22, z + side * 0.04), trim)
		van_box("MirrorStem", Vector3(0.13, 0.045, 0.1), Vector3(front - 0.27, 1.58, side * 0.82), trim)
		van_box("Mirror", Vector3(0.13, 0.19, 0.1), Vector3(front - 0.23, 1.59, side * 0.9), trim)
		van_box("Headlight", Vector3(0.045, 0.18, 0.24), Vector3(front + 0.025, 1.15, side * 0.53), Color("fff5ca"))
		van_box("TailLight", Vector3(0.05, 0.35, 0.15), Vector3(rear - 0.015, 1.13, side * 0.7), Color("ff514c"))
	van_box("Grille", Vector3(0.045, 0.18, 0.67), Vector3(front + 0.03, 0.96, 0), trim)
	van_box("FrontBumper", Vector3(0.14, 0.16, 1.6), Vector3(front + 0.065, 0.6, 0), trim)
	van_box("RearBumper", Vector3(0.14, 0.16, 1.6), Vector3(rear - 0.065, 0.6, 0), trim)

	# Two rear doors are swung outward, leaving a clear loading opening.
	for side in [-1.0, 1.0]:
		var hinge := Node3D.new()
		hinge.name = "RearDoorHingeLeft" if side < 0 else "RearDoorHingeRight"
		hinge.position = Vector3(rear - 0.02, 1.36, side * 0.7)
		model.add_child(hinge)
		hinge.rotation.y = side * 0.7
		var door := Models.box(hinge, Vector3(0.095, 1.28, 0.68), Vector3(-0.06, 0, -side * 0.34), paint)
		door.name = "RearDoor"
		var recess := Models.box(hinge, Vector3(0.018, 0.58, 0.43), Vector3(-0.115, 0.18, -side * 0.34), highlight)
		recess.name = "RearDoorPanel"
		var handle := Models.box(hinge, Vector3(0.04, 0.06, 0.1), Vector3(-0.135, -0.15, -side * 0.13), trim)
		handle.name = "RearDoorHandle"

	for x in [rear + 0.56, front - 0.44]:
		for side in [-1.0, 1.0]:
			var z: float = side * 0.78
			var wheel := Models.cylinder(model, 0.31, 0.18, Vector3(x, 0.36, z), Color("172634"))
			wheel.name = "Wheel"
			wheel.rotation_degrees.x = 90
			var hub := Models.cylinder(model, 0.15, 0.19, Vector3(x, 0.36, z + side * 0.06), Color("8da4b1"))
			hub.name = "Hubcap"
			hub.rotation_degrees.x = 90


func van_box(part_name: String, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var part := Models.box(model, size, at, color)
	part.name = part_name
	return part

func in_zone(point: Vector3) -> bool:
	return Vector2(point.x - load_position.x, point.z - load_position.z).length() <= 1.02


func display_cargo(item: LootItem, index: int, flight_duration: float = 0.26) -> void:
	item.reparent(cargo_anchor, true)
	item.highlight(false)
	var destination = Vector3(-0.8 + (index % 3) * 0.45, 0.67 + floorf(index / 6.0) * 0.38, -0.35 + (index / 3 % 2) * 0.62)
	var origin = item.position
	var orientation = item.quaternion
	var original_scale = item.scale
	var flight = create_tween()
	visual_tweens.append(flight)
	flight.tween_method(func(t: float):
		if not is_instance_valid(item): return
		item.position = arc_position(origin, destination, t)
		item.quaternion = orientation.slerp(Quaternion.IDENTITY, t)
		item.scale = original_scale.lerp(Vector3.ONE * 0.38, t)
	, 0.0, 1.0, flight_duration)
	flight.tween_callback(land_impact.bind(str(item.data.weight_class), int(item.data.cash_value)))
	flight.finished.connect(func(): visual_tweens.erase(flight))

static func arc_position(origin: Vector3, destination: Vector3, t: float) -> Vector3:
	return origin.lerp(destination, t) + Vector3.UP * sin(t * PI) * 0.75

static func impact_scale(weight_class: String) -> float:
	match weight_class:
		"LIGHT": return 0.6
		"HEAVY": return 1.45
		"VERY_HEAVY": return 1.8
		_: return 1.0

func land_impact(weight_class: String = "MEDIUM", cash_value: int = 0) -> void:
	last_impact_weight = weight_class
	last_impact_value = cash_value
	if is_instance_valid(impact_tween): impact_tween.kill()
	var scale_factor := impact_scale(weight_class)
	model.position.y = -0.065 * scale_factor
	impact_tween = create_tween()
	impact_tween.tween_property(model, "position:y", 0.075 * scale_factor, 0.07 + 0.015 * scale_factor)
	impact_tween.tween_property(model, "position:y", 0.0, 0.12 + 0.02 * scale_factor)
	cargo_landed.emit()

func pause_visuals(value: bool) -> void:
	for tween in visual_tweens:
		if value: tween.pause()
		else: tween.play()
	if is_instance_valid(impact_tween) and impact_tween.is_valid():
		if value: impact_tween.pause()
		else: impact_tween.play()
