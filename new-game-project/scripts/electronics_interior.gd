extends RefCounted

# Fixtures stay in the store after their merchandise is stolen. All counters
# use the same collision footprint as their visible cabinet, leaving a central aisle.
static func part(parent: Node3D, label: String, size: Vector3, at: Vector3, color: String) -> MeshInstance3D:
	var mesh = Models.box(parent,size,at,Color(color))
	mesh.name = label
	return mesh

static func solid(level: Node3D, size: Vector3, at: Vector3) -> void:
	level.barrier(size,at)
	level.walls.append(Rect2(at.x-size.x/2,at.z-size.z/2,size.x,size.z))

static func counter(art: Node3D, level: Node3D, label: String, x: float, z: float, width: float, depth: float, top: float) -> void:
	part(art,label,Vector3(width,top-0.13,depth),Vector3(x,(top+0.03)/2,z),"425968")
	part(art,label+"Top",Vector3(width+0.07,0.06,depth+0.06),Vector3(x,top-0.03,z),"c6d0cc")
	part(art,label+"Plinth",Vector3(width-0.12,0.10,depth-0.08),Vector3(x,0.12,z),"273c4a")
	solid(level,Vector3(width,top-0.08,depth),Vector3(x,(top+0.08)/2,z))

static func price_tag(art: Node3D, x: float, y: float, z: float) -> void:
	part(art,"PriceTicket",Vector3(0.26,0.10,0.028),Vector3(x,y,z),"e1d8b1")
	part(art,"TicketPrint",Vector3(0.15,0.018,0.032),Vector3(x,y,z+0.018),"435965")

static func build(level: Node3D) -> void:
	var art = Node3D.new()
	art.name = "ElectronicsInterior"
	level.add_child(art)
	# Large, quiet porcelain tiles; carpet separates demo machines from retail.
	for z in [-2.3,-1.1,0.1,1.3,2.5]:
		part(art,"TileJoint",Vector3(8.4,0.005,0.016),Vector3(2.05,0.070,z),"b1c1c1")
	for x in [-1.4,-0.2,1.0,2.2,3.4,4.6,5.8]:
		part(art,"TileJoint",Vector3(0.016,0.005,5.7),Vector3(x,0.070,-0.05),"b1c1c1")
	for x in [-6.43,6.43]:
		part(art,"WallSkirting",Vector3(0.055,0.14,8.1),Vector3(x,0.16,-0.95),"4b6270")
	part(art,"EntryMat",Vector3(2.66,0.015,0.60),Vector3(0,0.081,2.73),"304b5c")
	for x in [-0.85,-0.43,0.0,0.43,0.85]:
		part(art,"EntryMatRib",Vector3(0.02,0.006,0.46),Vector3(x,0.091,2.73),"5d7883")

	# One continuous TV wall; screens line up at real furniture height.
	counter(art,level,"TelevisionConsole",4.0,-2.10,4.8,0.70,0.65)
	for x in [2.35,3.95,5.55]:
		part(art,"TVBayDivider",Vector3(0.02,0.39,0.026),Vector3(x+0.76,0.37,-1.735),"91a9ad")
		price_tag(art,x,0.48,-1.72)
	part(art,"TelevisionWallPanel",Vector3(4.91,0.91,0.055),Vector3(4.0,1.07,-2.54),"344f62")
	part(art,"TelevisionWallLight",Vector3(4.75,0.035,0.06),Vector3(4.0,1.54,-2.49),"6fbdc4")

	# A paired desktop demo table, with keyboards and cable trays, not monitors on the floor.
	counter(art,level,"DemoDesk",4.15,0.57,3.30,0.92,0.77)
	for x in [3.15,5.15]:
		part(art,"DemoDeskMat",Vector3(0.90,0.008,0.76),Vector3(x,0.778,0.56),"314b5b")
		part(art,"DemoKeyboard",Vector3(0.51,0.03,0.19),Vector3(x,0.80,0.88),"708994")
		for z in [0.83,0.89,0.95]: part(art,"KeyboardKeys",Vector3(0.42,0.006,0.02),Vector3(x,0.819,z),"c0ccca")
		price_tag(art,x,0.56,1.049)
	part(art,"DeskCableTray",Vector3(2.8,0.12,0.17),Vector3(4.15,0.53,0.16),"263f50")

	# Two demo cabinets share a single arcade bay. The drinks machine belongs here.
	part(art,"ArcadeCarpet",Vector3(3.84,0.016,3.76),Vector3(-4.30,0.080,-0.44),"4a506b")
	part(art,"ArcadeAccent",Vector3(3.84,0.008,0.045),Vector3(-4.30,0.091,1.42),"7f92b2")
	for x in [-5.30,-3.35]:
		part(art,"ArcadeFootMat",Vector3(1.34,0.011,0.71),Vector3(x,0.094,-0.15),"303f59")
		price_tag(art,x,0.62,-2.53)
	part(art,"ArcadeBackPanel",Vector3(3.93,0.77,0.055),Vector3(-4.35,0.96,-2.54),"303f59")
	part(art,"ArcadeBackStripe",Vector3(3.78,0.07,0.058),Vector3(-4.35,1.29,-2.50),"a58dc4")

	# Rear service bench: aligned PCs ready for collection, packaging kept on racks.
	for bench in [[-3.85,4.4],[4.75,2.25]]:
		counter(art,level,"ServiceBench",bench[0],-4.50,bench[1],0.91,0.65)
		part(art,"ServicePegboard",Vector3(bench[1],0.69,0.047),Vector3(bench[0],1.22,-5.04),"5e7680")
		part(art,"BenchTaskLight",Vector3(bench[1]-0.16,0.045,0.08),Vector3(bench[0],1.60,-4.98),"cee4df")
	for x in [-4.90,-2.80,4.75]:
		price_tag(art,x,0.47,-4.02)
		part(art,"ServiceTray",Vector3(0.36,0.045,0.39),Vector3(x+0.55,0.675,-4.47),"233f50")
	for z in [-4.75,-4.30]:
		part(art,"CartonRackShelf",Vector3(0.94,0.06,0.43),Vector3(2.42,0.59,z),"7b9397")
		part(art,"BoxedAccessories",Vector3(0.66,0.34,0.34),Vector3(2.42,0.80,z),"bda27b")
		part(art,"ShippingLabel",Vector3(0.24,0.13,0.014),Vector3(2.42,0.80,z+0.177),"e4d8ba")
	for x in [1.98,2.86]: part(art,"CartonRackPost",Vector3(0.055,1.02,0.92),Vector3(x,0.59,-4.52),"455e6e")
	solid(level,Vector3(0.99,0.97,0.95),Vector3(2.42,0.565,-4.52))

	# One checkout by the exit. Open central entrance, no header across the player's face.
	counter(art,level,"Checkout",5.02,2.39,2.10,0.60,0.82)
	part(art,"CheckoutAccent",Vector3(1.94,0.09,0.026),Vector3(5.02,0.65,2.71),"c4a773")
	part(art,"TillBase",Vector3(0.37,0.12,0.29),Vector3(5.45,0.88,2.37),"233f50")
	part(art,"TillScreen",Vector3(0.32,0.25,0.075),Vector3(5.45,1.035,2.43),"233f50")
	part(art,"TillDisplay",Vector3(0.25,0.16,0.015),Vector3(5.45,1.055,2.475),"86c2bc")
	part(art,"CardReader",Vector3(0.17,0.08,0.24),Vector3(4.41,0.865,2.49),"334c5a")
	light(art,Vector3(3.8,2.8,-0.3),Color("e0efe7"),0.62,5.4)
	light(art,Vector3(-4.35,2.7,-0.9),Color("bcbddd"),0.45,3.8)
	light(art,Vector3(0,2.7,-4.3),Color("dce4d7"),0.45,6.2)

static func light(art: Node3D, at: Vector3, color: Color, energy: float, reach: float) -> void:
	var lamp = OmniLight3D.new()
	lamp.position = at
	lamp.light_color = color
	lamp.light_energy = energy
	lamp.omni_range = reach
	lamp.shadow_enabled = false
	art.add_child(lamp)
