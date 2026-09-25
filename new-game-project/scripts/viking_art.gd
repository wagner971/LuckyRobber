extends RefCounted

const WOOD = Color("76563f")
const DARK = Color("344453")
const SNOW = Color("b9d0d8")
const STONE = Color("64767b")

static func fire(level: HeistLevel, at: Vector3, scale_factor: float = 1.0) -> void:
	Models.cylinder(level,0.36*scale_factor,0.16,at+Vector3.UP*0.08,STONE)
	for i in range(3):
		var ember = Models.box(level,Vector3(0.15,0.34+0.12*(i%2),0.15)*scale_factor,at+Vector3((i-1)*0.13,0.27,0)*scale_factor,Color("ffba52"))
		ember.rotation.z = (i-1)*0.22
		ember.material_override.emission_enabled = true
		ember.material_override.emission = Color("ec732b")
	var light = OmniLight3D.new()
	light.position = at+Vector3.UP*0.9
	light.light_color = Color("ffc185")
	light.light_energy = 0.7
	light.omni_range = 4.5*scale_factor
	level.add_child(light)

static func pine(level: HeistLevel, at: Vector3, height: float) -> void:
	Models.cylinder(level,0.15,height*0.45,at+Vector3.UP*height*0.2,WOOD)
	for i in range(3):
		var cone = Models.cylinder(level,(0.9-i*0.2)*height/3,1.3*height/3,at+Vector3.UP*(height*(0.38+i*0.23)),Color("325d67"))
		cone.mesh = cone.mesh.duplicate()
		cone.mesh.top_radius = 0.04
		var cap = Models.cylinder(level,(0.7-i*0.16)*height/3,1.02*height/3,cone.position+Vector3.UP*0.40,SNOW)
		cap.mesh = cap.mesh.duplicate()
		cap.mesh.top_radius = 0.03

static func build(level: HeistLevel) -> void:
	Models.box(level,Vector3(80,0.24,80),Vector3(0,-0.22,0),Color("849da6"))
	level.barrier(Vector3(16.5,3,0.2),Vector3(0,1,-12.9))
	# A continuous snowy settlement surrounds the follow camera, not a floating square.
	for side in [-1,1]:
		for i in range(8):
			pine(level,Vector3(side*(10.0+(i%3)*1.8),0,-17+i*5.5),3.4+(i%3)*0.5)
			Models.ball(level,Vector3(2.4,0.65,2.8),Vector3(side*(8.5+i%2),-0.02,-11+i*4),SNOW)
			var stone = Models.ball(level,Vector3(1.1,0.8,0.8),Vector3(side*8.4,0.18,-8+i*3),STONE)
			stone.rotation.y = i*0.7
		for i in range(22):
			var z = -12.3+i*1.25
			Models.box(level,Vector3(0.26,1.1,0.28),Vector3(side*8.2,0.5,z),WOOD)
			Models.box(level,Vector3(0.31,0.08,0.32),Vector3(side*8.2,1.1,z),SNOW)
		level.barrier(Vector3(0.2,3,27.5),Vector3(side*8.2,1,1.0))
	Models.box(level,Vector3(12.8,0.32,12.2),Vector3(0,-0.1,-3.0),STONE)
	for i in range(28):
		Models.box(level,Vector3(11.8,0.055,0.408),Vector3(0,0.09,2.65-i*0.42),WOOD.lightened(float(i%4)*0.028))
	# Low cutaway walls, timber ribs and snowy exterior eaves identify a longhouse.
	level.wall(Vector3(12.1,1.6,0.22),Vector3(0,0.8,-9.1),WOOD)
	for side in [-1,1]:
		level.wall(Vector3(0.23,0.85,11.9),Vector3(side*6.05,0.425,-3.0),WOOD)
		level.wall(Vector3(4.0,0.64,0.2),Vector3(side*4.1,0.32,2.9),WOOD)
		for z in [-8.8,-5.7,-2.6,0.5,2.7]:
			Models.box(level,Vector3(0.3,1.65,0.3),Vector3(side*6,0.82,z),DARK)
		var eave = Models.box(level,Vector3(1.15,0.18,12.3),Vector3(side*6.43,1.16,-3.1),DARK)
		eave.rotation.z = side*0.42
		var snow = Models.box(level,Vector3(1.11,0.09,12.25),Vector3(side*6.44,1.27,-3.1),SNOW)
		snow.rotation.z = side*0.42
		# Gate posts have carved dragon heads, but no crossbeam obscuring the thief.
		Models.box(level,Vector3(0.34,2.2,0.34),Vector3(side*2.2,1.1,3.1),WOOD)
		Models.box(level,Vector3(0.38,0.33,0.66),Vector3(side*2.2,2.18,3.3),WOOD)
		Models.box(level,Vector3(0.4,0.08,0.22),Vector3(side*2.2,2.23,3.62),Color("d0ae74"))
		Models.box(level,Vector3(0.035,0.09,0.09),Vector3(side*2.40,2.25,3.45),Color("e4c281"))
		fire(level,Vector3(side*2.8,0,3.8))
		level.barrier(Vector3(0.4,3,0.4),Vector3(side*2.2,1,3.1))
	for side in [-1,1]:
		VikingModels.beam(level,Vector3(side*6.1,1.65,-9.18),Vector3(0,3.45,-9.18),0.24,DARK)
		Models.box(level,Vector3(0.74,1.26,0.04),Vector3(side*2.6,1.0,-8.94),Color("943f3b"))
		VikingModels.beam(level,Vector3(side*2.6-0.18,0.65,-8.89),Vector3(side*2.6+0.18,1.35,-8.89),0.04,Color("dcbd80"))
	# Hearth and rugs divide the shared hall while both walking lanes remain clear.
	Models.box(level,Vector3(2.55,0.025,4.0),Vector3(0,0.128,-6.2),Color("864940"))
	for x in [-1.12,1.12]: Models.box(level,Vector3(0.05,0.01,3.85),Vector3(x,0.145,-6.2),Color("cdb880"))
	level.house_solid(level,Vector3(0.95,0.20,1.8),Vector3(0,0.15,-2.6),STONE)
	fire(level,Vector3(0,0.25,-2.6),0.95)
	# Feast table, armourer's worktop and loom corner are fixed architectural props.
	for side in [-1,1]:
		var table_z = -5.8 if side == -1 else -6.5
		level.house_solid(level,Vector3(1.65,0.67,0.68),Vector3(side*3.5,0.335,table_z),Color("684b37"))
		for i in range(3):
			Models.box(level,Vector3(0.15,0.035,0.12),Vector3(side*3.5+(i-1)*0.40,0.7,table_z-0.20),Color("c6b393"))
	Models.box(level,Vector3(1.55,0.025,2.2),Vector3(4.4,0.13,-7.6),Color("61727c"))
	# Forge is visually next to the anvil, away from the player's return lane.
	level.house_solid(level,Vector3(0.7,0.7,1.35),Vector3(-5.5,0.35,-1.5),STONE)
	fire(level,Vector3(-5.5,0.76,-1.5),0.75)
	Models.box(level,Vector3(0.65,1.15,0.5),Vector3(-5.5,1.16,-2.01),STONE)
	level.house_solid(level,Vector3(0.7,0.55,1.1),Vector3(5.35,0.275,-0.85),WOOD)
	Models.box(level,Vector3(0.18,0.31,0.18),Vector3(5.35,0.72,-0.85),Color("b8a984"))
	# A complete feast setting occupies the near left bay, never the return lane.
	level.house_solid(level,Vector3(2.5,0.68,0.8),Vector3(-3.7,0.34,1.0),Color("674b38"))
	for z in [0.14,1.88]: level.house_solid(level,Vector3(2.6,0.31,0.30),Vector3(-3.7,0.155,z),WOOD)
	for x in [-4.45,-3.7,-2.95]:
		Models.cylinder(level,0.18,0.04,Vector3(x,0.70,1),Color("ae9368"))
		Models.ball(level,Vector3(0.19,0.10,0.13),Vector3(x,0.77,1),Color("ccae75"))
		Models.cylinder(level,0.075,0.16,Vector3(x,0.78,0.76),WOOD)
	level.house_solid(level,Vector3(1.16,0.53,0.75),Vector3(3.5,0.265,1.4),STONE)
	Models.box(level,Vector3(1.2,0.08,0.80),Vector3(3.5,0.55,1.4),Color("9bacae"))
	for side in [-1,1]:
		level.house_solid(level,Vector3(0.5,0.34,1.1),Vector3(side*5.4,0.17,-4.5),WOOD)
	# Stone approach and tyre tracks explain how the van reached the settlement.
	for i in range(12):
		for side in [-1,1]: Models.box(level,Vector3(1.88,0.045,0.95),Vector3(side*0.98,0.04,3.6+i*1.04),STONE.lightened(float(i%3)*0.035))
	for x in [-0.62,0.62]: Models.box(level,Vector3(0.18,0.014,7),Vector3(x,0.075,12.6),Color("455c68"))
	for x in [-4.2,4.2]:
		Models.box(level,Vector3(0.16,1.6,0.16),Vector3(x,0.8,7),WOOD)
		fire(level,Vector3(x,1.5,7),0.6)
	# Foreground framing stays visible on a narrow portrait display as well.
	for side in [-1,1]:
		for z in [7.4,13.2]:
			pine(level,Vector3(side*5.8,0,z),3.0)
			level.barrier(Vector3(0.42,3,0.42),Vector3(side*5.8,1,z))
			level.walls.append(Rect2(side*5.8-0.21,z-0.21,0.42,0.42))
			Models.ball(level,Vector3(2.4,0.28,1.9),Vector3(side*4.3,0,z+1.7),SNOW)
			Models.ball(level,Vector3(0.6,0.42,0.65),Vector3(side*3.4,0.11,z+2),STONE)
