extends RefCounted

static func part(art: Node3D, label: String, size: Vector3, at: Vector3, color: String) -> MeshInstance3D:
	var mesh = Models.box(art,size,at,Color(color))
	mesh.name = label
	return mesh

static func solid(level: Node3D, size: Vector3, at: Vector3) -> void:
	level.barrier(size,at)
	level.walls.append(Rect2(at.x-size.x/2,at.z-size.z/2,size.x,size.z))

static func cabinet(art: Node3D, level: Node3D, at: Vector3, size: Vector3) -> void:
	part(art,"TechnicalCabinet",size,at,"587381")
	part(art,"CabinetTop",Vector3(size.x+0.04,0.05,size.z+0.04),at+Vector3.UP*(size.y/2+0.025),"b8cac6")
	solid(level,Vector3(size.x,size.y+0.05,size.z),at+Vector3.UP*0.025)

static func build(level: Node3D) -> void:
	var art = Node3D.new()
	art.name = "LaboratoryInterior"
	level.add_child(art)
	# Matched station architecture, with continuous epoxy floors and perimeter services.
	for side in [-1.0,1.0]:
		for z in [0.55,-3.3,-7.1,-10.0]:
			part(art,"StationFloorInset",Vector3(4.76,0.013,2.63),Vector3(side*4.96,0.078,z),"819caa" if z > -8 else "708f9b")
			part(art,"StationThreshold",Vector3(0.05,0.007,1.32),Vector3(side*2.55,0.09,z),"a5c7bd")
		for z in [-1.17,-5.19,-8.63]:
			part(art,"StationFloorJoint",Vector3(4.82,0.006,0.035),Vector3(side*4.96,0.089,z),"405e6e")
		part(art,"WallServiceRail",Vector3(0.08,0.12,14.9),Vector3(side*7.59,0.27,-4),"3b5868")
		part(art,"WallPipe",Vector3(0.055,0.055,14.8),Vector3(side*7.53,0.44,-4),"b5c2bb")
		# Outer-wall cupboards leave the inner approach and all paired doors clear.
		for z in [0.50,-3.25,-7.04,-10.12]:
			cabinet(art,level,Vector3(side*7.12,0.39,z),Vector3(0.62,0.60,1.32))
			for offset in [-0.34,0.34]:
				part(art,"CupboardPull",Vector3(0.045,0.16,0.06),Vector3(side*6.79,0.43,z+offset),"c1cfca")
		# Sample preparation bench: the microscope/analyzer lift off, the bench stays.
		cabinet(art,level,Vector3(side*5.00,0.39,0.47),Vector3(2.32,0.62,0.70))
		for x in [4.18,5.06,5.84]:
			part(art,"BenchDrawerSeam",Vector3(0.018,0.49,0.027),Vector3(side*x,0.42,0.835),"314e60")
			part(art,"BenchDrawerPull",Vector3(0.22,0.035,0.04),Vector3(side*x,0.57,0.859),"b4c4bd")
		part(art,"SampleTray",Vector3(0.42,0.032,0.39),Vector3(side*5.76,0.771,0.49),"35576b")
		for offset in [-0.12,0.0,0.12]:
			part(art,"SealedSampleVial",Vector3(0.06,0.19,0.06),Vector3(side*5.76,0.88,0.49+offset),"bdd3c3")
			part(art,"VialCap",Vector3(0.07,0.032,0.07),Vector3(side*5.76,0.99,0.49+offset),"b99f6c")
		# Both front stations have a wall-mounted wash sink and a drying rack.
		part(art,"LabSink",Vector3(0.43,0.025,0.61),Vector3(side*7.10,0.755,0.50),"6a959d")
		part(art,"LabTap",Vector3(0.17,0.23,0.045),Vector3(side*7.30,0.86,0.50),"adbfbd")
		part(art,"SinkBackboard",Vector3(0.055,0.61,1.12),Vector3(side*7.58,0.85,0.50),"a4b9ba")
		for z in [0.20,0.42,0.64]: part(art,"DryingPeg",Vector3(0.18,0.035,0.035),Vector3(side*7.47,1.02,z),"547586")
		# Rear containment has actual utility panels and labelled sealed storage.
		part(art,"ContainmentBackboard",Vector3(3.60,0.94,0.045),Vector3(side*4.95,0.77,-11.60),"466879")
		part(art,"ContainmentLight",Vector3(3.45,0.045,0.06),Vector3(side*4.95,1.27,-11.54),"b4d4c6")
		for x in [4.10,5.75]:
			part(art,"PressureGauge",Vector3(0.30,0.31,0.05),Vector3(side*x,0.90,-11.54),"b0c4c1")
			part(art,"GaugeFace",Vector3(0.19,0.18,0.015),Vector3(side*x,0.90,-11.505),"315263")
		for z in [-7.55,-6.65]:
			part(art,"PrototypeBoundary",Vector3(2.13,0.009,0.05),Vector3(side*4.70,0.098,z),"c5b079")
	# Centrifuge sample station: refrigeration grille and specimen preparation surface.
	for z in [-3.62,-3.42,-3.22,-3.02]:
		part(art,"ColdCabinetVent",Vector3(0.04,0.045,0.63),Vector3(-6.79,0.25,z),"2f4a5b")
	part(art,"SampleHolder",Vector3(0.38,0.035,0.72),Vector3(-7.1,0.76,-3.3),"334c5c")
	for z in [-3.5,-3.25,-3.0]: part(art,"SampleCassette",Vector3(0.28,0.14,0.16),Vector3(-7.1,0.847,z),"b0c5bb")
	# Data rack: cooling and cable routing terminate at its own bay, never across the hall.
	part(art,"ServerVentFrame",Vector3(0.07,0.64,1.49),Vector3(7.57,0.86,-3.3),"315467")
	for z in [-3.82,-3.56,-3.3,-3.04,-2.78]:
		part(art,"VentFin",Vector3(0.09,0.43,0.04),Vector3(7.51,0.87,z),"99afb1")
	part(art,"ServerCableDuct",Vector3(1.95,0.035,0.13),Vector3(5.90,0.10,-3.68),"3d6072")
	# Robot calibration jig and laser beam stop make the engineering equipment purposeful.
	cabinet(art,level,Vector3(-6.0,0.565,-7.1),Vector3(0.72,0.97,0.96))
	part(art,"RobotWorkTray",Vector3(0.65,0.04,0.88),Vector3(-6.0,1.12,-7.1),"304d60")
	for z in [-7.28,-6.89]: part(art,"CalibrationPart",Vector3(0.25,0.19,0.20),Vector3(-5.84,1.235,z),"c5ab72")
	part(art,"LaserBeamStop",Vector3(0.08,0.69,0.90),Vector3(6.72,0.94,-7.1),"314b5b")
	part(art,"LaserTargetOuter",Vector3(0.09,0.44,0.58),Vector3(6.66,0.94,-7.1),"b0a27d")
	part(art,"LaserTargetCenter",Vector3(0.10,0.18,0.25),Vector3(6.60,0.94,-7.1),"486c7a")
	# Keep core pickup and approach open; only the recovered rear dock is permanent.
	solid(level,Vector3(2.70,0.30,0.55),Vector3(0,0.23,-11.10))
	for side in [-1.0,1.0]: solid(level,Vector3(0.27,1.03,0.27),Vector3(side*1.15,0.595,-11.1))
	for at in [Vector3(-5.0,2.65,0.5),Vector3(5.0,2.65,0.5),Vector3(-5,2.65,-6),Vector3(5,2.65,-6),Vector3(0,2.8,-10)]:
		var light = OmniLight3D.new()
		light.position = at
		light.light_color = Color("d5e3da")
		light.light_energy = 0.40
		light.omni_range = 4.4
		light.shadow_enabled = false
		art.add_child(light)
