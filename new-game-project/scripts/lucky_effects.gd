class_name LuckyEffects
extends RefCounted

const CHANCE := 0.30
const CATALOG := {
"magnet":["LOOT MAGNET","Auto-pickup within 2 m. Walls and Strength still matter.",true],
"silent":["SILENT HEIST","Loot and movement generate no noise.",true],
"speed":["SPEED DEMON","Move 30% faster, including while carrying.",true],
"instant":["INSTANT GRAB","Pick up loot instantly.",true],
"bottomless":["BOTTOMLESS VAN","Unlimited cargo for one heist.",true],
"time":["EXTRA TIME","Start with 20 extra seconds.",true],
"double_cash":["DOUBLE CASH","All stolen loot is worth twice as much.",true],
"golden":["GOLDEN RUN","One guaranteed Rare or Epic replacement.",true],
"strength":["SUPER STRENGTH","Lift any object, regardless of Strength.",true],
"feather":["FEATHERWEIGHT","Carry every object as if it were LIGHT.",true],
"delay":["ALARM DELAY","Eight extra seconds in the alarm escape window.",true],
"quick_load":["QUICK LOAD","Instant loading with a faster delivery arc.",true],
"cash_rain":["CASH RAIN","Loaded loot is worth 25% more.",true],
"lucky_house":["LUCKY HOUSE","Five times the rare-loot spawn chance.",true],
"second":["SECOND CHANCE","At zero time, get seven seconds once.",true],
"ghost":["GHOST MODE","Smaller collision radius for tight corners.",true],
"vacuum":["VACUUM VAN","Auto-load carried loot within 2 m of the van.",true],
"haul":["BIG HAUL BONUS","Escape with over 75% of standard loot for +50% loot cash.",true],
"vision":["TREASURE VISION","Rare loot gets a bright marker visible through walls.",true],
"jackpot":["JACKPOT RUN","One marked normal object is worth five times as much.",true],
"noise":["DOUBLE NOISE","Loot noise is doubled.",false],
"slow":["SLOW MOTION","Movement speed is reduced by 30%.",false],
"hands":["HEAVY HANDS","Carry speed is reduced by an extra 20%.",false],
"tiny":["TINY VAN","30% less cargo, including Final Jobs.",false],
"short":["SHORT CLOCK","Start with 15 fewer seconds.",false],
"butter":["BUTTER FINGERS","Pickups take 50% longer.",false],
"loud_load":["LOUD LOAD","Each delivery adds 4 noise.",false],
"cheap":["CHEAP LOOT","Stolen loot pays 25% less.",false],
"weak":["WEAK THIEF","One less Strength level, including Final Jobs.",false],
"panic":["PANIC MODE","After the alarm, carrying is 20% slower.",false],
"sticky":["STICKY FLOOR","A half-second slowdown every five seconds.",false],
"route":["BAD ROUTE","A valuable floor item moves to a farther reachable spot.",false],
"shoes":["NOISY SHOES","Moving with heavy loot adds 2 noise every 3 seconds.",false],
"rush":["ALARM RUSH","Four fewer seconds to escape after the alarm.",false],
"world":["HEAVY WORLD","Carry every object one weight class higher.",false],
"bad_luck":["BAD LUCK","No rare-loot replacement this run.",false],
"slippery":["SLIPPERY LOOT","After 8 seconds carrying on the move, drop your loot once.",false],
"door":["BROKEN VAN DOOR","Every delivery takes one extra second.",false],
"dark":["DARK HEIST","Slightly dimmer lighting and no normal-loot highlight.",false],
"curse":["CURSED OBJECT","One clearly marked object adds 35 pickup noise.",false],
}

static func roll() -> String: return CATALOG.keys()[randi_range(0,CATALOG.size()-1)]
static func spawns(draw: float) -> bool: return draw < CHANCE
static func positive(id: String) -> bool: return CATALOG.get(id,["","",true])[2]

static func model(tint: Color = Color("9822ed")) -> Node3D:
	var root := Node3D.new()
	Models.box(root,Vector3.ONE*0.78,Vector3(0,0.4,0),tint)
	for y in [0.07,0.75]: Models.box(root,Vector3(0.85,0.075,0.85),Vector3(0,y,0),tint.lightened(0.28))
	for x in [-0.39,0.39]:
		for z in [-0.39,0.39]: Models.box(root,Vector3(0.065,0.76,0.065),Vector3(x,0.4,z),tint.darkened(0.45))
	# Pixel question mark, on all four faces and the top, with a darker offset.
	var pixels := [Vector2(1,0),Vector2(2,0),Vector2(3,0),Vector2(0,1),Vector2(4,1),Vector2(4,2),Vector2(3,3),Vector2(2,3),Vector2(2,4),Vector2(2,6)]
	for side in range(5):
		var face := Node3D.new()
		root.add_child(face)
		if side == 4: face.position.y = 0.81; face.rotation.x = -PI/2
		else: face.rotation.y = side*PI/2; face.position = Vector3(sin(side*PI/2)*0.40,0.40,cos(side*PI/2)*0.40)
		for pixel in pixels:
			var at := Vector3((pixel.x-2)*0.075,(3-pixel.y)*0.075,0)
			Models.box(face,Vector3(0.083,0.083,0.023),at+Vector3(0.018,-0.018,0),tint.darkened(0.4))
			Models.box(face,Vector3(0.071,0.071,0.025),at+Vector3(0,0,0.015),Color("f9efff"))
	# Bake the pixel details into shared-color surfaces, rather than 100 draw calls.
	var surfaces := {}
	collect_surfaces(root,Transform3D.IDENTITY,surfaces)
	var baked := ArrayMesh.new()
	for surface in surfaces.values(): surface.commit(baked)
	for child in root.get_children(): child.free()
	var combined := MeshInstance3D.new()
	combined.mesh = baked
	root.add_child(combined)
	return root

static func collect_surfaces(node: Node3D, parent_transform: Transform3D, surfaces: Dictionary) -> void:
	var pose := parent_transform*node.transform
	if node is MeshInstance3D:
		var material: StandardMaterial3D = node.material_override
		var key := material.albedo_color.to_html()
		if not surfaces.has(key):
			var surface := SurfaceTool.new()
			surface.begin(Mesh.PRIMITIVE_TRIANGLES)
			surface.set_material(material)
			surfaces[key] = surface
		surfaces[key].append_from(node.mesh,0,pose)
	for child in node.get_children(): collect_surfaces(child,pose,surfaces)

static func fits(world: HeistLevel, point: Vector3, radius: float) -> bool:
	if not world.valid_drop(point,radius): return false
	var shape := BoxShape3D.new()
	shape.size = Vector3(radius*2,0.4,radius*2)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.collision_mask = 1
	query.transform = Transform3D(Basis.IDENTITY,point+Vector3.UP*0.6)
	return world.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty()

static func spawn(world: HeistLevel, point: Vector3, tint: Color = Color("9822ed")) -> LootItem:
	var item := LootItem.new()
	world.add_child(item)
	item.setup("chair",world.location_id+".lucky_block")
	item.data = item.data.duplicate(true)
	item.data.merge({"type_id":"lucky_block","display_name":"LUCKY BLOCK · NEXT-RUN SURPRISE","cash_value":0,"cargo_space":0,"required_strength":1,"pickup_duration":0.35,"weight_class":"LIGHT","radius":0.4},true)
	item.model.free()
	item.model = model(tint)
	item.add_child(item.model)
	item.position = point
	# Rare enough to be an event: a glow light and a slow pulse make it read across the map.
	var glow := OmniLight3D.new()
	glow.name = "LuckyGlow"
	glow.light_color = tint.lightened(0.35)
	glow.light_energy = 1.6
	glow.omni_range = 2.6
	glow.shadow_enabled = false
	glow.position.y = 0.9
	item.model.add_child(glow)
	var pulse := item.model.create_tween().set_loops()
	pulse.tween_property(item.model, "scale", Vector3.ONE * 1.09, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse.parallel().tween_property(glow, "light_energy", 2.6, 0.55).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(item.model, "scale", Vector3.ONE, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse.parallel().tween_property(glow, "light_energy", 1.6, 0.55).set_trans(Tween.TRANS_SINE)
	world.items.append(item)
	return item

static func floor_points(world: HeistLevel) -> Array[Vector3]:
	# Flood-fill from the entrance. Tests use the same collision and floor checks.
	var result: Array[Vector3] = []
	var origin := world.player.global_position
	var queue: Array[Vector2i] = [Vector2i.ZERO]
	var visited := {Vector2i.ZERO:true}
	var shape := SphereShape3D.new()
	shape.radius = 0.29
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.collision_mask = 1
	var index := 0
	while index < queue.size() and index < 4200:
		var cell := queue[index]
		index += 1
		var point := origin+Vector3(cell.x*0.55,0,cell.y*0.55)
		point.y = 0.04
		if cell != Vector2i.ZERO:
			if not world.valid_drop(point,0.32): continue
			query.transform = Transform3D(Basis.IDENTITY,point+Vector3.UP*0.55)
			if not world.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty(): continue
		var clear := true
		for item in world.items:
			if item.edge_distance(point) < 0.6: clear = false; break
		if clear: result.append(point)
		for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+offset
			if absi(next.x)>32 or absi(next.y)>56 or visited.has(next): continue
			visited[next] = true
			queue.append(next)
	return result

