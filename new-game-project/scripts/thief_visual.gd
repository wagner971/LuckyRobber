class_name ThiefVisual
extends Node3D

# Rigid pieces around named pivots; no skeleton, skinning or root motion.
const SKIN = Color("efad76")
const BLACK = Color("242528")
const WHITE = Color("fffdf7")
const PANTS = Color("252d36")
const CARRY_HEIGHT = 1.80
var body: Node3D
var head: Node3D
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var carry_anchor: Node3D
var tint_parts: Array[MeshInstance3D] = []
var original_tints: Array[Color] = []
var clock = 0.0
var gait = 0.0
var motion = 0.0
var carrying = false
var heavy = false
var panic = false
var paused = false
var pickup_amount = 0.0
var loading = false
var pickup_release = 0.0
var load_release = 0.0
var squash_tween: Tween
var carry_blend = 0.0
var heavy_blend = 0.0
var animation_state = "IDLE"
var cadence = 12.0

func _init() -> void:
	name = "ThiefVisual"
	body = pivot(self, "Body", Vector3(0, 0.60, 0))
	# Broad striped shirt, uninterrupted on front, back and sleeves.
	piece(body, Vector3(0.55, 0.47, 0.34), Vector3(0, 0.23, 0), BLACK, true)
	for y in [0.115, 0.295]:
		piece(body, Vector3(0.558, 0.085, 0.348), Vector3(0, y, 0), WHITE)
	piece(body, Vector3(0.51, 0.065, 0.34), Vector3(0, -0.005, 0), BLACK, true)
	piece(body, Vector3(0.25, 0.08, 0.24), Vector3(0, 0.50, 0), SKIN)
	head = pivot(body, "Head", Vector3(0, 0.57, 0))
	piece(head, Vector3(0.73, 0.49, 0.59), Vector3(0, 0.16, 0), SKIN)
	piece(head, Vector3(0.748, 0.195, 0.615), Vector3(0, 0.195, 0), Color("191b1d"))
	for side in [-1, 1]:
		piece(head, Vector3(0.09, 0.18, 0.16), Vector3(side * 0.397, 0.16, -0.015), SKIN)
		piece(head, Vector3(0.132, 0.108, 0.022), Vector3(side * 0.18, 0.201, 0.322), WHITE, false, 0.002)
		piece(head, Vector3(0.053, 0.101, 0.026), Vector3(side * 0.18 + 0.033, 0.199, 0.339), Color("101314"), false, 0.001)
	# Asymmetrical little grin, readable even from the game camera.
	for i in range(3):
		var grin = piece(head, Vector3(0.064, 0.032, 0.024), Vector3(0.06 + i * 0.044, 0.015 + i * i * 0.01, 0.302), Color("191b1d"), false, 0.004)
		grin.rotation.z = i * 0.27
	piece(head, Vector3(0.83, 0.155, 0.70), Vector3(0, 0.405, -0.008), BLACK, true)
	piece(head, Vector3(0.73, 0.22, 0.61), Vector3(0, 0.535, -0.015), Color("29292c"), true, 0.075)
	left_arm = arm(-1)
	right_arm = arm(1)
	left_leg = leg(-1)
	right_leg = leg(1)
	carry_anchor = pivot(self, "CarryAnchor", Vector3(0, CARRY_HEIGHT, 0.12))
	animate(0, 0)

func pivot(parent: Node3D, label: String, at: Vector3) -> Node3D:
	var node = Node3D.new()
	node.name = label
	node.position = at
	parent.add_child(node)
	return node

func arm(side: int) -> Node3D:
	var joint = pivot(body, "LeftArm" if side < 0 else "RightArm", Vector3(side * 0.35, 0.405, 0))
	piece(joint, Vector3(0.205, 0.355, 0.235), Vector3(0, -0.135, 0), BLACK, true)
	for y in [-0.055, -0.235]:
		piece(joint, Vector3(0.21, 0.075, 0.24), Vector3(0, y, 0), WHITE)
	piece(joint, Vector3(0.22, 0.20, 0.235), Vector3(0, -0.401, 0.014), SKIN, false, 0.028)
	piece(joint, Vector3(0.07, 0.09, 0.12), Vector3(-side * 0.10, -0.37, 0.10), SKIN, false, 0.015)
	return joint

func leg(side: int) -> Node3D:
	var joint = pivot(body, "LeftLeg" if side < 0 else "RightLeg", Vector3(side * 0.15, -0.035, 0))
	piece(joint, Vector3(0.235, 0.385, 0.25), Vector3(0, -0.16, 0), PANTS, true, 0.025)
	piece(joint, Vector3(0.255, 0.16, 0.375), Vector3(0, -0.405, 0.055), Color("25282b"), false, 0.02)
	piece(joint, Vector3(0.263, 0.075, 0.385), Vector3(0, -0.487, 0.055), WHITE, false, 0.008)
	piece(joint, Vector3(0.16, 0.026, 0.09), Vector3(0, -0.33, 0.13), WHITE, false, 0.005)
	return joint

func piece(parent: Node3D, size: Vector3, at: Vector3, color: Color, tint: bool = false, bevel: float = 0.015) -> MeshInstance3D:
	var node = MeshInstance3D.new()
	node.mesh = bevel_box(size, bevel)
	var mat = Models.material(color)
	if color == WHITE: mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	node.material_override = mat
	node.position = at
	parent.add_child(node)
	if tint:
		tint_parts.append(node)
		original_tints.append(color)
	return node

static func bevel_box(size: Vector3, amount: float) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var b = minf(amount, minf(size.x, minf(size.y, size.z)) * 0.24)
	var rings: Array = []
	for band in range(4):
		var inset = b if band in [0, 3] else 0.0
		var x = size.x / 2 - inset
		var z = size.z / 2 - inset
		var c = minf(b, minf(x, z) * 0.4)
		var y = [-size.y / 2, -size.y / 2 + b, size.y / 2 - b, size.y / 2][band]
		var ring: Array[Vector3] = []
		for p in [Vector2(-x+c,-z),Vector2(x-c,-z),Vector2(x,-z+c),Vector2(x,z-c),Vector2(x-c,z),Vector2(-x+c,z),Vector2(-x,z-c),Vector2(-x,-z+c)]:
			ring.append(Vector3(p.x,y,p.y))
		rings.append(ring)
	for band in range(3):
		for i in range(8):
			var j = (i + 1) % 8
			triangle(st, rings[band][i], rings[band+1][i], rings[band+1][j])
			triangle(st, rings[band][i], rings[band+1][j], rings[band][j])
	for i in range(8):
		triangle(st, Vector3(0,-size.y/2,0), rings[0][i], rings[0][(i+1)%8])
		triangle(st, Vector3(0,size.y/2,0), rings[3][(i+1)%8], rings[3][i])
	return st.commit()

static func triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var normal = (b-a).cross(c-a).normalized()
	# Godot front faces use clockwise winding.
	for p in [a,c,b]:
		st.set_normal(normal)
		st.add_vertex(p)

func set_suit_color(color: Color) -> void:
	for part in tint_parts: part.material_override.albedo_color = color

func reset_suit() -> void:
	for i in range(tint_parts.size()): tint_parts[i].material_override.albedo_color = original_tints[i]

func picked_up() -> void:
	pickup_release = 0.18
	squash(0.86, 1.10)

func loaded() -> void:
	load_release = 0.24
	squash(1.12, 0.92)

# Quick squash-and-stretch on the whole figure; the pose animation keeps running underneath.
func squash(vertical: float, horizontal: float) -> void:
	if not is_instance_valid(body): return
	if is_instance_valid(squash_tween) and squash_tween.is_valid(): squash_tween.kill()
	body.scale = Vector3(horizontal, vertical, horizontal)
	squash_tween = body.create_tween()
	squash_tween.tween_property(body, "scale", Vector3.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func animate(delta: float, speed: float) -> void:
	if paused: return
	clock += delta
	var moving = speed > 0.08
	motion = move_toward(motion, 1.0 if moving else 0.0, delta * 12)
	carry_blend = move_toward(carry_blend, 1.0 if carrying else 0.0, delta * 9)
	heavy_blend = move_toward(heavy_blend, 1.0 if heavy and carrying else 0.0, delta * 7)
	cadence = lerpf(12.0, 8.4, heavy_blend) * (1.13 if panic else 1.0)
	gait += delta * cadence * motion
	pickup_release = maxf(0, pickup_release - delta)
	load_release = maxf(0, load_release - delta)
	var stride = sin(gait) * motion
	var bounce = (1.0 - cos(gait * 2)) * 0.5 * motion
	var bend = maxf(pickup_amount, pickup_release / 0.18)
	var toss = maxf(1.0 if loading else 0.0, load_release / 0.24)
	animation_state = "LOAD" if toss > 0 else ("PICKUP" if bend > 0 else ("HEAVY CARRY" if heavy and carrying else ("CARRY" if carrying else ("RUN" if moving else "IDLE"))))
	body.position.y = 0.60 + sin(clock * 2.3) * 0.008 * (1-motion) + bounce * lerpf(0.042,0.065,heavy_blend) - bend * 0.105
	body.rotation = Vector3(deg_to_rad(lerpf(5,-10,heavy_blend)) * motion - deg_to_rad(9) * heavy_blend + bend * 0.24, stride * 0.045 * (1-carry_blend), stride * lerpf(0.04,0.095,heavy_blend))
	head.rotation = Vector3(-body.rotation.x * 0.45, sin(clock * 1.2) * 0.07 * (1-motion), -body.rotation.z * 0.35)
	var leg_angle = deg_to_rad(lerpf(25,34,heavy_blend)) * stride
	left_leg.rotation = Vector3(leg_angle + 0.04 * (1-motion), 0, -0.07)
	right_leg.rotation = Vector3(-leg_angle - 0.04 * (1-motion), 0, 0.07)
	var arm_angle = -deg_to_rad(36) * stride
	var raised = lerpf(arm_angle, -deg_to_rad(158), carry_blend)
	var raised_right = lerpf(-arm_angle, -deg_to_rad(158), carry_blend)
	raised = lerpf(raised, -0.5, bend * (1-carry_blend))
	raised_right = lerpf(raised_right, -0.5, bend * (1-carry_blend))
	left_arm.rotation = Vector3(lerpf(raised, -PI/2, toss), 0, lerpf(-0.16,0.18,carry_blend))
	right_arm.rotation = Vector3(lerpf(raised_right, -PI/2, toss), 0, lerpf(0.16,-0.18,carry_blend))
	left_arm.position.y = 0.405 + 0.12 * carry_blend
	right_arm.position.y = left_arm.position.y
	left_arm.scale.y = lerpf(1,1.48,carry_blend)
	right_arm.scale.y = left_arm.scale.y
	carry_anchor.position = Vector3(stride * 0.025 * heavy_blend, CARRY_HEIGHT + bounce * lerpf(0.04,0.075,heavy_blend) - bend * 0.12, 0.12 + toss * 0.18)
	carry_anchor.rotation = Vector3(stride * 0.025 * heavy_blend, 0, stride * lerpf(0.025,0.065,heavy_blend))

