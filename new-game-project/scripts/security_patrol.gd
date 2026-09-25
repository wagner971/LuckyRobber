class_name SecurityPatrol
extends Node3D

# Small, readable obstacles, not a second fail condition. One shared exposure
# meter prevents overlapping sensors from multiplying the detection speed.
const LOCATIONS = ["electronics", "mansion", "laboratory", "museum"]
const NOTICE_TIME := 1.8
const COOLDOWN := 9.0
const PENALTY := 2.0
const SAFE_Z := 1.8
const CONE_STEPS := 16
var world: Node3D
var sensors: Array[Dictionary] = []
var suspicion := 0.0
var cooldown := 0.0
var detections := 0
var time_lost := 0.0
var clock := 0.0
var visual_elapsed := 0.0
var status: Label3D

func setup(level: Node3D) -> void:
	world = level
	name = "SecurityPatrol"
	# Side aisles have short loops; entrances and the van are never patrolled.
	match world.location_id:
		"electronics":
			camera_at(Vector3(-1.35, 1.65, -4.92), 0.0, 0.3)
			guard_between(Vector3(1.0, 0, 0.1), Vector3(1.0, 0, -2.0), 0.0)
		"mansion":
			camera_at(Vector3(-2.05, 1.65, -10.35), 0.1, 0.6)
			camera_at(Vector3(6.95, 1.55, -5.6), -PI / 2, 2.2)
			guard_between(Vector3(-0.85, 0, -1.1), Vector3(-0.85, 0, -5.1), 0.0)
		"laboratory":
			camera_at(Vector3(-7.40, 1.55, -5.05), PI / 2, 0.0)
			camera_at(Vector3(7.40, 1.55, -8.85), -PI / 2, 2.7)
			guard_between(Vector3(0.90, 0, -2.8), Vector3(0.90, 0, -7.3), 1.2)
		"museum":
			camera_at(Vector3(-7.85, 1.6, -6.1), PI / 2, 0.5)
			camera_at(Vector3(1.45, 1.6, -11.8), 0, 2.8)
			guard_between(Vector3(-1.45, 0, -1.0), Vector3(-1.45, 0, -6.8), 0.0)
			guard_between(Vector3(3.90, 0, -2.8), Vector3(3.90, 0, -6.8), 3.0)
	status = Label3D.new()
	status.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	status.no_depth_test = true
	status.font_size = 42
	status.outline_size = 9
	status.pixel_size = 0.009
	status.modulate = Color("ffdc75")
	status.outline_modulate = Color("172a3f")
	status.hide()
	add_child(status)
	move_sensors(0.0)
	call_deferred("refresh_cones", false)

func sensor_node(at: Vector3, yaw: float, reach: float, angle: float) -> Dictionary:
	var pivot := Node3D.new()
	pivot.position = at
	pivot.rotation.y = yaw
	add_child(pivot)
	var mesh := MeshInstance3D.new()
	mesh.mesh = ImmediateMesh.new()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(1.0, 0.75, 0.25, 0.16)
	mesh.material_override = material
	add_child(mesh)
	var sensor := {"pivot":pivot, "cone":mesh, "material":material, "reach":reach, "angle":angle, "base_yaw":yaw, "guard":false, "legs":[], "arms":[]}
	sensors.append(sensor)
	return sensor

func camera_at(at: Vector3, yaw: float, offset: float) -> void:
	var mount := Node3D.new()
	mount.position = at
	mount.rotation.y = yaw
	add_child(mount)
	Models.box(mount, Vector3(0.25,0.30,0.08), Vector3(0,0,-0.16), Color("40596a"))
	Models.box(mount, Vector3(0.10,0.09,0.28), Vector3(0,-0.08,0), Color("718797"))
	var sensor := sensor_node(at + Vector3(0,0,0.08), yaw, 3.8, deg_to_rad(27))
	sensor["offset"] = offset
	var pivot: Node3D = sensor.pivot
	pivot.name = "SurveillanceCamera"
	var housing := Models.box(pivot, Vector3(0.36,0.27,0.60), Vector3(0,0.05,0.20), Color("d4e4e5"))
	housing.rotation.x = 0.18
	Models.box(pivot, Vector3(0.29,0.19,0.055), Vector3(0,0.00,0.52), Color("24394b"))
	Models.box(pivot, Vector3(0.11,0.11,0.025), Vector3(0,0.00,0.56), Color("69e6e0"))
	Models.box(pivot, Vector3(0.04,0.04,0.035), Vector3(0.13,0.10,0.53), Color("ffd16b"))

func guard_between(a: Vector3, b: Vector3, offset: float) -> void:
	var yaw := atan2(b.x-a.x,b.z-a.z)
	var sensor := sensor_node(a, yaw, 2.8, deg_to_rad(37))
	sensor.guard = true
	sensor["a"] = a
	sensor["b"] = b
	sensor["offset"] = offset
	var pivot: Node3D = sensor.pivot
	pivot.name = "SecurityGuard"
	var navy := Color("29465e")
	var skin := Color("dca877")
	Models.box(pivot,Vector3(0.52,0.53,0.32),Vector3(0,0.86,0),navy)
	Models.box(pivot,Vector3(0.54,0.07,0.34),Vector3(0,0.64,0),Color("142839"))
	Models.box(pivot,Vector3(0.14,0.09,0.025),Vector3(0,0.66,0.18),Color("d4b16a"))
	Models.box(pivot,Vector3(0.09,0.13,0.025),Vector3(-0.15,1.00,0.18),Color("ffcf59"))
	Models.box(pivot,Vector3(0.64,0.43,0.52),Vector3(0,1.37,0),skin)
	Models.box(pivot,Vector3(0.71,0.16,0.59),Vector3(0,1.62,0),navy)
	Models.box(pivot,Vector3(0.71,0.05,0.33),Vector3(0,1.54,0.28),Color("122b42"))
	Models.box(pivot,Vector3(0.12,0.12,0.025),Vector3(0,1.65,0.31),Color("ffcf59"))
	for side in [-1,1]:
		Models.box(pivot,Vector3(0.07,0.06,0.025),Vector3(side*0.15,1.40,0.275),Color("172535"))
		var leg := Node3D.new()
		leg.position = Vector3(side*0.15,0.61,0)
		pivot.add_child(leg)
		Models.box(leg,Vector3(0.22,0.40,0.25),Vector3(0,-0.20,0),Color("243746"))
		Models.box(leg,Vector3(0.26,0.16,0.36),Vector3(0,-0.48,0.05),Color("192631"))
		sensor.legs.append(leg)
		var arm := Node3D.new()
		arm.position = Vector3(side*0.35,1.10,0)
		pivot.add_child(arm)
		Models.box(arm,Vector3(0.19,0.35,0.23),Vector3(0,-0.17,0),navy)
		Models.box(arm,Vector3(0.19,0.15,0.23),Vector3(0,-0.41,0),skin)
		sensor.arms.append(arm)
	Models.box(pivot,Vector3(0.09,0.22,0.08),Vector3(0.25,0.84,0.20),Color("172d3f"))
	world.contact_blob(Vector2(0.65,0.50),a+Vector3(0,0.09,0)).reparent(pivot,true)

func limit_for(mode: String) -> int:
	if mode not in ["normal","FINAL_JOB"]: return 1
	return 2 if world.location_id == "electronics" else 3

func tick(delta: float, run: Node) -> void:
	if run.phase in [RunManager.Phase.PAUSED, RunManager.Phase.FINISHED]: return
	var active: bool = run.phase == RunManager.Phase.ACTIVE
	if active:
		clock += delta
		cooldown = maxf(0.0,cooldown-delta)
		move_sensors(delta)
	var disabled: bool = not active or run.alarm_active or run.remaining <= 10.0 or detections >= limit_for(run.mode)
	var seen := false
	var point: Vector3 = world.player.global_position
	if not disabled and cooldown <= 0 and clock >= 3.0 and point.z < SAFE_Z:
		for sensor in sensors:
			if sees(sensor,point): seen = true; break
	if seen: suspicion = minf(NOTICE_TIME,suspicion+delta)
	else: suspicion = maxf(0.0,suspicion-delta*2.4)
	if suspicion >= NOTICE_TIME:
		detections += 1
		time_lost += PENALTY
		run.remaining = maxf(8.0,run.remaining-PENALTY)
		suspicion = 0
		cooldown = COOLDOWN
		run.feedback.emit("security_spotted","SPOTTED · -2s · KEEP MOVING!")
	status.visible = active and suspicion > 0.04 and not disabled
	status.position = point + Vector3(0,2.15,0)
	status.text = "! SEEN · " + str(ceili(100.0*suspicion/NOTICE_TIME)) + "%" if status.visible else ""
	visual_elapsed += delta
	if visual_elapsed >= 0.1:
		visual_elapsed = 0
		refresh_cones(disabled or cooldown > 0)

func move_sensors(delta: float) -> void:
	for sensor in sensors:
		var pivot: Node3D = sensor.pivot
		if not sensor.guard:
			pivot.rotation.y = sensor.base_yaw + sin(clock*0.55+sensor.offset)*0.62
			continue
		var a: Vector3 = sensor.a
		var b: Vector3 = sensor.b
		var duration := a.distance_to(b)/0.7
		var cycle := fposmod(clock+sensor.offset,2.0*(duration+1.1))
		var returning := cycle > duration+1.1
		var phase_time: float = cycle-duration-1.1 if returning else cycle
		var progress := clampf(phase_time/duration,0,1)
		pivot.position = b.lerp(a,progress) if returning else a.lerp(b,progress)
		var face_back := not returning if phase_time >= duration+0.25 else returning
		pivot.rotation.y = lerp_angle(pivot.rotation.y,float(sensor.base_yaw)+(PI if face_back else 0.0),minf(1,delta*3.5))
		var gait := sin(clock*6.5)*0.24 if phase_time < duration else 0.0
		for index in range(2):
			sensor.legs[index].rotation.x = gait*(1 if index==0 else -1)
			sensor.arms[index].rotation.x = -gait*(1 if index==0 else -1)

func sees(sensor: Dictionary, point: Vector3) -> bool:
	if point.z >= SAFE_Z: return false
	var pivot: Node3D = sensor.pivot
	var difference := Vector2(point.x-pivot.position.x,point.z-pivot.position.z)
	if difference.length() > float(sensor.reach) or difference.length() < 0.05: return false
	var angle := wrapf(atan2(difference.x,difference.y)-pivot.rotation.y,-PI,PI)
	if absf(angle) > float(sensor.angle): return false
	return ray_end(pivot.position,point).distance_to(Vector3(point.x,0.75,point.z)) < 0.08

func ray_end(from: Vector3, to: Vector3) -> Vector3:
	var origin := Vector3(from.x,0.75,from.z)
	var destination := Vector3(to.x,0.75,to.z)
	var query := PhysicsRayQueryParameters3D.create(origin,destination,1)
	var hit := world.get_world_3d().direct_space_state.intersect_ray(query)
	return destination if hit.is_empty() else hit.position

func refresh_cones(disabled: bool) -> void:
	for sensor in sensors:
		var pivot: Node3D = sensor.pivot
		var mesh: ImmediateMesh = sensor.cone.mesh
		mesh.clear_surfaces()
		var color := Color(0.49,0.67,0.73,0.055) if disabled else Color(1,0.75,0.25,0.16)
		if suspicion > 0.05 and not disabled: color = Color(1,0.52,0.12,0.22)
		sensor.material.albedo_color = color
		var origin := Vector3(pivot.position.x,0.135,pivot.position.z)
		var edge: Array[Vector3] = []
		for i in range(CONE_STEPS+1):
			var yaw: float = pivot.rotation.y + lerpf(-float(sensor.angle),float(sensor.angle),float(i)/CONE_STEPS)
			var far := origin+Vector3(sin(yaw),0,cos(yaw))*float(sensor.reach)
			# Clip the displayed cone exactly where detection rays stop.
			far = ray_end(origin,far)
			far.y = origin.y
			if far.z > SAFE_Z:
				far = origin.lerp(far,(SAFE_Z-origin.z)/(far.z-origin.z))
			edge.append(far)
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in range(CONE_STEPS):
			mesh.surface_add_vertex(origin)
			mesh.surface_add_vertex(edge[i])
			mesh.surface_add_vertex(edge[i+1])
		mesh.surface_end()
