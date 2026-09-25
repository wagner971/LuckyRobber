extends RefCounted

const OUTLINE = [Vector2(-3.9,3),Vector2(-5.2,1.2),Vector2(-5.2,-4.9),Vector2(-4.2,-7.4),Vector2(-2.3,-9.4),Vector2(0,-10.8),Vector2(2.3,-9.4),Vector2(4.2,-7.4),Vector2(5.2,-4.9),Vector2(5.2,1.2),Vector2(3.9,3)]
const WOOD = Color("87603c")
const NAVY = Color("233e4e")
const GOLD = Color("ba9250")

static func half_width(z: float) -> float:
	if z < -9.4: return lerpf(0,2.3,(z+10.8)/1.4)
	if z < -7.4: return lerpf(2.3,4.2,(z+9.4)/2.0)
	if z < -4.9: return lerpf(4.2,5.2,(z+7.4)/2.5)
	if z <= 1.2: return 5.2
	return lerpf(5.2,3.9,(z-1.2)/1.8)

static func walkable(point: Vector3, radius: float) -> bool:
	if point.z >= 4.5: return absf(point.x) < 4.4-radius and point.z < 16.7-radius
	if point.z >= 2.7: return absf(point.x) < 1.52-radius
	return point.z > -10.6+radius and absf(point.x) < half_width(point.z)-0.18-radius

static func rail(level: HeistLevel, a: Vector2, b: Vector2) -> void:
	var start = Vector3(a.x,0.43,a.y)
	var end = Vector3(b.x,0.43,b.y)
	PirateModels.beam(level,start,end,0.16,GOLD)
	PirateModels.beam(level,start-Vector3.UP*0.34,end-Vector3.UP*0.34,0.22,NAVY)
	var count = ceili(a.distance_to(b)/0.9)
	for i in range(count+1):
		var p = a.lerp(b,float(i)/maxi(1,count))
		Models.box(level,Vector3(0.12,0.5,0.12),Vector3(p.x,0.22,p.y),NAVY)
	var body = StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	level.add_child(body)
	body.position = (start+end)*0.5
	body.rotation.y = -atan2(b.y-a.y,b.x-a.x)
	var collider = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(a.distance_to(b)+0.1,3,0.18)
	collider.shape = shape
	body.add_child(collider)

static func lamp(level: HeistLevel, at: Vector3) -> void:
	Models.box(level,Vector3(0.13,1.1,0.13),at+Vector3.UP*0.55,NAVY)
	Models.box(level,Vector3(0.32,0.1,0.32),at+Vector3.UP*1.4,NAVY)
	var glass = Models.box(level,Vector3(0.23,0.3,0.23),at+Vector3.UP*1.2,Color("ffc674"))
	glass.material_override.emission_enabled = true
	glass.material_override.emission = Color("e19c3f")
	var glow = OmniLight3D.new()
	glow.position = at+Vector3.UP*1.4
	glow.light_color = Color("ffc781")
	glow.light_energy = 0.75
	glow.omni_range = 3.6
	level.add_child(glow)

static func build(level: HeistLevel) -> void:
	var sea = Models.box(level,Vector3(90,0.1,90),Vector3(0,-1.03,0),Color("164e63"))
	var water = ShaderMaterial.new()
	water.shader = preload("res://assets/shaders/pirate_water.gdshader")
	sea.material_override = water
	# Planked tapered hull: the silhouette remains a ship from the gameplay angle.
	for i in range(32):
		var z = -10.55+i*0.43
		var width = half_width(z)*2-0.11
		Models.box(level,Vector3(width,0.13,0.411),Vector3(0,-0.045,z),WOOD.lightened(float(i%3)*0.035))
	for i in range(OUTLINE.size()-1):
		var a: Vector2 = OUTLINE[i]
		var b: Vector2 = OUTLINE[i+1]
		var side = Models.box(level,Vector3(a.distance_to(b)+0.12,1.2,0.25),Vector3((a.x+b.x)*0.5,-0.55,(a.y+b.y)*0.5),NAVY)
		side.rotation.y = -atan2(b.y-a.y,b.x-a.x)
		rail(level,a,b)
	rail(level,OUTLINE[-1],Vector2(1.55,3))
	rail(level,Vector2(-1.55,3),OUTLINE[0])
	Models.box(level,Vector3(7.8,1.1,0.23),Vector3(0,-0.6,3),NAVY)
	# A single boarding route joins a real pier. The van stays on land.
	Models.box(level,Vector3(3.05,0.15,2.0),Vector3(0,-0.035,3.9),WOOD)
	rail(level,Vector2(-1.6,3),Vector2(-1.6,4.7))
	rail(level,Vector2(1.6,3),Vector2(1.6,4.7))
	Models.box(level,Vector3(9,0.95,13),Vector3(0,-0.5,10.8),Color("465c62"))
	rail(level,Vector2(-4.5,4.5),Vector2(-1.6,4.5))
	rail(level,Vector2(1.6,4.5),Vector2(4.5,4.5))
	for i in range(23):
		Models.box(level,Vector3(8.9,0.08,0.52),Vector3(0,0.015,4.8+i*0.54),Color("738181").darkened(float(i%3)*0.025))
	for x in [-4.5,4.5]:
		level.barrier(Vector3(0.2,3,12.5),Vector3(x,1,10.9))
		for z in [5.3,9.8,14.3]:
			Models.cylinder(level,0.20,1.4,Vector3(x,-0.35,z),WOOD)
			PirateModels.ring(level,0.24,Vector3(x,0.27,z),Color("cfb98a"))
		lamp(level,Vector3(x*0.88,0,9.0))
	# Captain's cabin: open roof, wide side door, all desk instruments supported.
	Models.box(level,Vector3(2.9,0.035,3.0),Vector3(3.2,0.035,0.85),Color("42656a"))
	level.wall(Vector3(0.16,1.2,0.6),Vector3(1.85,0.6,-0.35),WOOD)
	level.wall(Vector3(0.16,1.2,0.65),Vector3(1.85,0.6,2.1),WOOD)
	level.wall(Vector3(2.85,1.2,0.16),Vector3(3.22,0.6,-0.7),WOOD)
	level.wall(Vector3(2.45,0.6,0.16),Vector3(3.12,0.3,2.45),WOOD)
	level.house_solid(level,Vector3(1.9,0.64,0.65),Vector3(3.4,0.32,1.55),Color("69472e"))
	Models.box(level,Vector3(1.1,0.014,0.45),Vector3(3.35,0.653,1.55),Color("d9c391"))
	lamp(level,Vector3(4.5,0,0.3))
	# Mainmast and furled sails: nautical identity without hiding the walkable deck.
	Models.box(level,Vector3(1.2,0.025,1.4),Vector3(0,0.055,-0.9),NAVY)
	for i in range(7): Models.box(level,Vector3(1.12,0.03,0.05),Vector3(0,0.075,-1.50+i*0.20),WOOD)
	for x in [-0.55,0.0,0.55]: Models.box(level,Vector3(0.055,0.03,1.4),Vector3(x,0.08,-0.9),GOLD)
	for z in [-3.2,-7.25]:
		Models.cylinder(level,0.19,4.2,Vector3(0,2.1,z),WOOD)
		level.barrier(Vector3(0.42,3,0.42),Vector3(0,1,z))
		level.walls.append(Rect2(-0.21,z-0.21,0.42,0.42))
		PirateModels.beam(level,Vector3(-2.25,3.4,z),Vector3(2.25,3.4,z),0.13,WOOD)
		Models.box(level,Vector3(3.9,0.23,0.28),Vector3(0,3.35,z+0.05),Color("c6c6af"))
		for x in [-1.7,-0.6,0.6,1.7]: Models.box(level,Vector3(0.065,0.27,0.31),Vector3(x,3.35,z+0.05),NAVY)
		for x in [-4.5,4.5]: PirateModels.beam(level,Vector3(x,0.45,z),Vector3(x*0.5,3.4,z),0.025,Color("b5a581"))
	var flag = Models.box(level,Vector3(1.1,0.65,0.035),Vector3(0.56,4.04,-7.25),Color("182835"))
	Models.box(flag,Vector3(0.25,0.23,0.02),Vector3(0,0.06,0.03),Color("e3d9bf"))
	Models.box(flag,Vector3(0.17,0.08,0.02),Vector3(0,-0.10,0.03),Color("e3d9bf"))
	for x in [-0.065,0.065]: Models.box(flag,Vector3(0.065,0.07,0.02),Vector3(x,0.07,0.05),NAVY)
	for angle in [-0.6,0.6]: Models.box(flag,Vector3(0.5,0.045,0.02),Vector3(0,-0.23,0.03),Color("e3d9bf")).rotation.z = angle
	# Cargo stays along the port rail, with a clear central lane on both sides.
	for z in [0.6,1.7]:
		level.house_solid(level,Vector3(0.7,0.6,0.7),Vector3(-4.45,0.3,z),Color("695238"))
		Models.box(level,Vector3(0.74,0.07,0.73),Vector3(-4.45,0.62,z),GOLD)
	for x in [-4.5,4.5]: lamp(level,Vector3(x,0,-5.4))
	# Distant rocks and mooring ropes fill the whole moving camera view.
	for side in [-1,1]:
		for i in range(7):
			var rock = Models.ball(level,Vector3(2.5+i%2,2.0,3.2),Vector3(side*(10.0+i%3*2),-0.75,-14+i*5),Color("385c65"))
			rock.rotation.y = float(i)*0.8
		PirateModels.beam(level,Vector3(side*3.8,0.25,2.8),Vector3(side*4.5,0.2,5.3),0.045,Color("bfaa77"))
