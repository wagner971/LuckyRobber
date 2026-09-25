extends RefCounted

const OUTLINE = [Vector2(-1.9,3.2),Vector2(-4.7,2.8),Vector2(-6.4,0.5),Vector2(-6.5,-4),Vector2(-5.3,-8),Vector2(-2.8,-10),Vector2(1,-10.7),Vector2(4.8,-9),Vector2(6.3,-5),Vector2(5.9,-1),Vector2(4.4,2.8),Vector2(1.9,3.2)]
const STONE = Color("737e6e")
const MOSS = Color("61765a")
const EARTH = Color("9d855d")

static func walkable(point: Vector3, radius: float) -> bool:
	if point.z >= 3.2: return absf(point.x) < 7.9-radius and point.z < 16.7-radius
	var polygon = PackedVector2Array(OUTLINE)
	for i in range(9):
		var sample = Vector2(point.x,point.z)
		if i < 8: sample += Vector2.from_angle(i*TAU/8)*radius
		if not Geometry2D.is_point_in_polygon(sample,polygon): return false
	return true

static func fern(level: Node3D, at: Vector3, scale_factor: float) -> void:
	for i in range(6):
		var angle = i*TAU/6
		var leaf = Models.box(level,Vector3(0.25,0.055,0.85)*scale_factor,at+Vector3(sin(angle)*0.25,0.18,cos(angle)*0.25)*scale_factor,Color("4a8061").lightened(float(i%2)*0.07))
		leaf.rotation = Vector3(-0.3,angle,0)

static func tree(level: HeistLevel, at: Vector3, height: float) -> void:
	Models.cylinder(level,0.21,height*0.73,at+Vector3.UP*height*0.35,Color("5b5141"))
	for side in [-1,1]:
		PrehistoricModels.beam(level,at+Vector3(0,height*0.4,0),at+Vector3(side*0.75,height*0.72,0),0.16,Color("5b5141"))
		Models.ball(level,Vector3(2.2,1.35,2.0),at+Vector3(side*0.62,height*0.80,0),Color("325c4a"))
	Models.ball(level,Vector3(1.8,1.25,1.9),at+Vector3(0,height,0),Color("427557"))

static func rock_edge(level: HeistLevel, a: Vector2, b: Vector2, index: int) -> void:
	var count = ceili(a.distance_to(b)/1.1)
	for i in range(count+1):
		var p = a.lerp(b,float(i)/maxi(count,1))
		var height = (1.55 if p.y < -5 else 0.88)+(i%2)*0.23
		var stone = Models.ball(level,Vector3(1.85,height,1.6),Vector3(p.x,height*0.42,p.y),STONE.lightened(float((i+index)%3)*0.04))
		stone.rotation.y = i*0.61+index
		Models.ball(level,Vector3(1.25,0.12,0.98),Vector3(p.x,height*0.85,p.y),MOSS)
	var body = StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	level.add_child(body)
	body.position = Vector3((a.x+b.x)*0.5,1,(a.y+b.y)*0.5)
	body.rotation.y = -atan2(b.y-a.y,b.x-a.x)
	var collider = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(a.distance_to(b)+0.22,3,0.9)
	collider.shape = shape
	body.add_child(collider)

static func build(level: HeistLevel) -> void:
	Models.box(level,Vector3(80,0.24,80),Vector3(0,-0.21,0),Color("526952"))
	# Irregular cave floor, with the near edge left open for the camera and exit.
	var polygon = PackedVector2Array(OUTLINE)
	var indices = Geometry2D.triangulate_polygon(polygon)
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in indices:
		surface.set_normal(Vector3.UP)
		surface.add_vertex(Vector3(polygon[index].x,0.035,polygon[index].y))
	var floor_mesh = MeshInstance3D.new()
	floor_mesh.mesh = surface.commit()
	floor_mesh.material_override = Models.material(EARTH)
	floor_mesh.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	level.add_child(floor_mesh)
	for i in range(OUTLINE.size()-1): rock_edge(level,OUTLINE[i],OUTLINE[i+1],i)
	# Tall stone stacks at the back suggest the cave roof without obscuring loot.
	for at in [Vector3(-3.3,1.75,-10.4),Vector3(0,2.0,-11.0),Vector3(3.3,1.75,-10.25)]:
		Models.ball(level,Vector3(3.8,2.5,2.7),at,STONE.darkened(0.10))
		Models.ball(level,Vector3(2.9,0.25,2.5),at+Vector3.UP*1.17,MOSS)
	# Side terrain and forest continue beyond the follow-camera frustum.
	for side in [-1,1]:
		for i in range(7):
			tree(level,Vector3(side*(10.0+i%3),0,-15+i*5),3.0+i%3*0.35)
			fern(level,Vector3(side*(7.8+i%2),0,-9+i*4),1.2)
		level.barrier(Vector3(0.2,3,30),Vector3(side*8.3,1,2))
		for z in [7.5,13.0]:
			tree(level,Vector3(side*6.1,0,z),2.75)
			level.barrier(Vector3(0.46,3,0.46),Vector3(side*6.1,1,z))
			level.walls.append(Rect2(side*6.1-0.23,z-0.23,0.46,0.46))
			fern(level,Vector3(side*4.6,0,z+1.8),1.3)
	level.barrier(Vector3(16.6,3,0.2),Vector3(0,1,-13.0))
	# Dry work areas make the tool, hide and sleeping spots read as a camp.
	Models.cylinder(level,1.2,0.023,Vector3(-4.2,0.052,-3.8),Color("aa946d"))
	Models.cylinder(level,1.1,0.023,Vector3(3.7,0.052,-3.7),Color("aa946d"))
	Models.box(level,Vector3(1.9,0.028,1.25),Vector3(2.5,0.065,-1.4),Color("8b7052"))
	# Low hearth: its collision stays between the two 1.15m travel lanes.
	level.house_solid(level,Vector3(0.85,0.12,1.0),Vector3(0,0.09,-1.4),Color("6e6a57"))
	for i in range(8):
		var angle = i*TAU/8
		Models.ball(level,Vector3(0.23,0.21,0.22),Vector3(sin(angle)*0.34,0.15,-1.4+cos(angle)*0.4),STONE)
	for angle in [-0.7,0.7]: Models.box(level,Vector3(0.65,0.13,0.13),Vector3(0,0.21,-1.4),Color("66412d")).rotation.y = angle
	for x in [-0.17,0.0,0.17]:
		var fire = Models.box(level,Vector3(0.10,0.32,0.12),Vector3(x,0.39,-1.4),Color("ffbd64"))
		fire.material_override.emission_enabled = true
		fire.material_override.emission = Color("e78642")
	var glow = OmniLight3D.new()
	glow.position = Vector3(0,1.1,-1.4)
	glow.light_color = Color("ffc489")
	glow.light_energy = 0.85
	glow.omni_range = 5.0
	level.add_child(glow)
	# Small collectables sit on flat working stones; supports remain after pickup.
	for at in [Vector3(4.5,0.25,-1.8),Vector3(-3.3,0.25,1.15)]:
		level.house_solid(level,Vector3(0.95,0.50,0.70),at,STONE)
		Models.box(level,Vector3(1.04,0.10,0.78),at+Vector3.UP*0.28,Color("a4aa90"))
	# A sheltered fur nook has fixed branch ribs, with an open side to the path.
	for z in [-2.35,-0.55]:
		PrehistoricModels.beam(level,Vector3(4.8,0.02,z),Vector3(4.2,1.25,z),0.07,Color("76573d"))
	PrehistoricModels.beam(level,Vector3(4.2,1.25,-2.35),Vector3(4.2,1.25,-0.55),0.07,Color("76573d"))
	# Approach is packed soil and scattered stepping stones, with no floating square edge.
	for i in range(13):
		Models.cylinder(level,1.4,0.023,Vector3(sin(i*0.4)*0.12,0.026,3.35+i*0.92),Color("877959"))
		for side in [-1,1]:
			Models.ball(level,Vector3(0.45,0.13,0.38),Vector3(side*(1.7+i%2*0.32),0.06,3.7+i*0.92),STONE)
	for at in [Vector3(-5.2,0,2.7),Vector3(4.6,0,3.4),Vector3(-5.5,0,-5.8),Vector3(5.1,0,-6.0)]: fern(level,at,1.0)
