extends "res://tests/route_harness.gd"

func expose_for(seconds: float) -> void:
	var security = world.security
	var sensor: Dictionary = security.sensors[0]
	for frame in range(ceili(seconds*60)):
		# Follow one real camera's current direction, keeping exposure continuous.
		var pivot: Node3D = sensor.pivot
		world.player.position = Vector3(pivot.position.x,0,pivot.position.z)+Vector3(sin(pivot.rotation.y),0,cos(pivot.rotation.y))*1.2
		security.tick(1.0/60,run)

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	for location in Balance.LOCATION_ORDER:
		await new_session(location)
		check(is_instance_valid(world.security) == (location in SecurityPatrol.LOCATIONS), "Security only in requested maps: "+location)
		if not is_instance_valid(world.security): continue
		var security = world.security
		check(security.sensors.size() == (2 if location=="electronics" else (4 if location=="museum" else 3)), "Gentle sensor count: "+location)
		var clear_patrols := true
		var clear_loot := true
		for step in range(300):
			security.clock = float(step)*0.1
			security.move_sensors(0.1)
			for sensor in security.sensors:
				if not sensor.guard: continue
				var point: Vector3 = sensor.pivot.position
				if not world.valid_drop(point,0.30):
					clear_patrols = false
					if step==0: print("PATROL BLOCK ",location," ",point)
				for item in world.items:
					if Vector2(point.x-item.position.x,point.z-item.position.z).length() < float(item.data.radius)+0.23:
						clear_loot = false
		check(clear_patrols,"Patrol stays clear of fixed furniture and walls: "+location)
		check(clear_loot,"Patrol does not cross loot: "+location)
	await new_session("electronics")
	var security = world.security
	var sensor: Dictionary = security.sensors[0]
	sensor.pivot.position = Vector3(0,1.6,0)
	sensor.pivot.rotation.y = 0
	check(security.sees(sensor,Vector3(0,0,1)),"Camera sees a player in its clear cone")
	check(not security.sees(sensor,Vector3(0,0,-1)),"Camera cannot see behind itself")
	check(not security.sees(sensor,Vector3(0,0,5)),"Camera has finite range")
	check(not security.sees(sensor,Vector3(2,0,0)),"Camera cannot see outside its cone")
	check(not security.sees(sensor,Vector3(0,0,2.5)),"Entrance and van approach stay safe even in front of a sensor")
	var guard: Dictionary = security.sensors[1]
	guard.pivot.position = Vector3(0,0,-1)
	guard.pivot.rotation.y = 0
	check(security.sees(guard,Vector3(0,0,0)),"Guard uses the same real vision test")
	check(not security.sees(guard,Vector3(0,0,-2)),"Player can pass behind a guard")
	world.wall(Vector3(2,0.6,0.2),Vector3(0,0.3,0.6))
	await physics_frame
	await physics_frame
	check(not security.sees(sensor,Vector3(0,0,1)),"A real wall blocks detection")
	check(security.ray_end(Vector3(0,0,0),Vector3(0,0,2)).z < 0.6,"Displayed vision cone stops at the same wall")
	await new_session("electronics")
	security = world.security
	run.phase = RunManager.Phase.ACTIVE
	security.clock = 4
	expose_for(0.6)
	check(security.suspicion > 0 and security.detections == 0,"A brief crossing only raises suspicion")
	world.player.position = world.van.load_position
	security.tick(0.8,run)
	check(security.suspicion == 0,"Leaving sight clears suspicion quickly")
	var before: float = run.remaining
	expose_for(2)
	check(security.detections == 1 and is_equal_approx(run.remaining,before-2),"Continuous detection costs exactly two seconds")
	check(not run.alarm_active and run.current_noise == 0 and run.phase == RunManager.Phase.ACTIVE,"Detection neither triggers police nor loses the run")
	var previous_clock: float = security.clock
	run.pause()
	expose_for(3)
	check(security.clock == previous_clock and security.cooldown > 8,"Pause freezes patrol and cooldown")
	run.resume()
	expose_for(3)
	check(security.detections == 1 and security.suspicion == 0,"Shared cooldown prevents overlapping sensors from chaining penalties")
	security.cooldown = 0
	expose_for(2)
	check(security.detections == 2 and security.time_lost == 4,"Electronics has at most four seconds of security penalties")
	security.cooldown = 0
	expose_for(4)
	check(security.detections == 2,"Reached budget disables further catches")
	await new_session("laboratory")
	security = world.security
	run.phase = RunManager.Phase.ACTIVE
	security.clock = 4
	run.alarm_active = true
	expose_for(3)
	check(security.detections == 0 and security.suspicion == 0,"Police countdown suspends security penalties")
	run.alarm_active = false
	run.remaining = 9
	expose_for(3)
	check(security.detections == 0,"Last ten seconds never get an extra security penalty")
	check(security.limit_for(SpecialJobs.MODE)==1 and security.limit_for("rush")==1,"Short challenge modes permit only one catch")
	for location in SecurityPatrol.LOCATIONS:
		var profile = SaveStore.new("res://tests/security_route.json")
		profile.session_only = true
		profile.data.upgrades = MAXED.duplicate()
		profile.data.upgrades.grip = Balance.powerup_requirement(location)
		profile.data.upgrades.carry = Balance.powerup_requirement(location)
		await new_session(location,"normal",profile)
		var order: Array = []
		for i in range(world.items.size()): order.append(i)
		check(await drive_indices(order,"security_live_"+location),"Full physical route with live security at required speed levels: "+location)
		print("SECURITY CATCHES ",location," ",world.security.detections," time_lost=",world.security.time_lost," remaining=",run.remaining)
		# Worst penalty budget up front, still with moving live cameras and guards.
		await new_session(location,"normal",profile)
		world.security.detections = world.security.limit_for("normal")
		world.security.time_lost = world.security.detections*SecurityPatrol.PENALTY
		run.remaining -= world.security.time_lost
		check(await drive_indices(order,"security_worst_"+location),"Full clear remains possible after maximum penalty budget: "+location)
	print("SECURITY CHECKS %d; FAILURES %d" % [checks,failures])
	quit(1 if failures else 0)
