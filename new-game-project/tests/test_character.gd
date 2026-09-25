extends "res://tests/route_harness.gd"

func test() -> void:
	LocalLog.enabled = false
	var actor = ThiefVisual.new()
	root.add_child(actor)
	var idle_y = actor.body.position.y
	actor.animate(0.35, 0)
	check(actor.animation_state == "IDLE" and absf(actor.body.position.y - idle_y) > 0.001 and absf(actor.body.position.y - 0.6) < 0.01, "Idle breath is visible but subtle")
	check(absf(actor.head.rotation.y) > 0.001, "Idle head gently turns")
	actor.motion = 1
	actor.gait = PI / 2
	actor.animate(0, 5)
	check(is_equal_approx(rad_to_deg(actor.left_leg.rotation.x), 25) and is_equal_approx(rad_to_deg(actor.right_leg.rotation.x), -25), "Run alternates legs +25/-25 degrees")
	check(actor.left_arm.rotation.x < 0 and actor.right_arm.rotation.x > 0, "Run arms oppose legs with wider swing")
	actor.gait += PI
	actor.animate(0, 5)
	check(actor.left_leg.rotation.x < 0 and actor.right_leg.rotation.x > 0, "Second half-step reverses legs")
	var cadence = actor.cadence
	actor.panic = true
	actor.animate(0, 5)
	check(is_equal_approx(actor.cadence, cadence * 1.13), "Alarm speeds visuals by13 percent only")
	actor.panic = false
	actor.carrying = true
	actor.carry_blend = 1
	actor.gait = PI / 2
	actor.animate(0, 3)
	check(actor.animation_state == "CARRY" and actor.left_arm.rotation.x < -2 and actor.right_arm.rotation.x < -2, "Carry raises both arms")
	check(actor.left_leg.rotation.x > 0 and actor.right_leg.rotation.x < 0, "Carry retains walking legs")
	actor.heavy = true
	actor.heavy_blend = 1
	actor.animate(0, 3)
	check(actor.animation_state == "HEAVY CARRY" and actor.cadence < cadence and rad_to_deg(actor.left_leg.rotation.x) > 30, "Heavy gait has larger, slower steps")
	check(actor.body.rotation.x < 0 and absf(actor.body.rotation.z) > 0.07, "Heavy body leans backward and sways")
	var high = actor.carry_anchor.position.y
	actor.gait = 0
	actor.animate(0, 3)
	check(actor.carry_anchor.position.y < high, "Carried object bounces with same step phase")
	actor.paused = true
	var before = [actor.gait,actor.clock,actor.body.transform,actor.carry_anchor.transform]
	actor.animate(2, 5)
	check(before == [actor.gait,actor.clock,actor.body.transform,actor.carry_anchor.transform], "Pause freezes pose and carried object")
	actor.paused = false
	var skin: Color = actor.head.get_child(0).material_override.albedo_color
	actor.set_suit_color(Color("70dabc"))
	check(actor.tint_parts[0].material_override.albedo_color == Color("70dabc") and actor.head.get_child(0).material_override.albedo_color == skin, "Cosmetics tint outfit while preserving face")
	var second = ThiefVisual.new()
	check(second.tint_parts[0].material_override.albedo_color != Color("70dabc"), "Cosmetic materials do not leak across characters")
	second.free()
	actor.free()
	await new_session("apartment")
	world.player.set_process(false)
	check(world.player.carry_anchor.name == "CarryAnchor", "Real player exposes named CarryAnchor")
	var shape: CapsuleShape3D = world.player.get_child(0).shape
	check(is_equal_approx(shape.radius, 0.24) and is_equal_approx(shape.height, 1.3), "Original movement collider unchanged")
	begin()
	stand_by(world.items[0])
	tick(0.02)
	run.progress = run.progress_duration - 0.075
	world.player._process(0)
	check(world.player.visual.animation_state == "PICKUP" and world.player.visual.body.position.y < 0.6, "Final150ms of real pickup crouches torso")
	var elapsed_before = run.elapsed
	run.commit_pickup()
	world.player._process(0.15)
	check(run.carried == world.items[0] and run.carried.get_parent() == world.player.carry_anchor and run.carried.position == Vector3.ZERO, "Pickup moves real loot into anchor exactly once")
	check(run.elapsed == elapsed_before and world.player.visual.carry_blend == 1, "Pickup animation adds no gameplay delay and arms recover")
	world.player.velocity = Vector3(3,0,0)
	run.alarm_active = true
	world.player._process(0.02)
	check(world.player.visual.panic and world.player.velocity == Vector3(3,0,0), "Live alarm changes presentation without touching velocity")
	world.player.velocity = Vector3.ZERO
	world.player.position = world.van.load_position
	run.carried.state = LootItem.State.LOADING
	world.player._process(0.02)
	check(world.player.visual.animation_state == "LOAD" and is_equal_approx(world.player.visual.left_arm.rotation.x, -PI/2), "Live loading sends arms forward")
	var item = run.carried
	var impacts: Array = []
	world.van.cargo_landed.connect(func(): impacts.append(true))
	run.commit_load()
	check(run.carried == null and run.cargo.size() == 1 and run.cargo_value == 140 and store.data.wallet == 0, "Cargo commits before visual arc without early wallet credit")
	check(item.get_parent() == world.van.cargo_anchor, "Flight uses actual loaded item, no visual duplicate")
	var initial = item.position
	var endpoint = Vector3(-0.8,0.67,-0.35)
	check(LootVan.arc_position(initial, endpoint, 0.5).y > initial.lerp(endpoint,0.5).y + 0.7, "Load travels on a raised arc")
	run.pause()
	await create_timer(0.35).timeout
	check(item.position.is_equal_approx(initial) and impacts.is_empty(), "Pause freezes in-flight loot and delays WHAM")
	run.resume()
	await create_timer(0.32).timeout
	check(item.position.is_equal_approx(endpoint) and item.scale.is_equal_approx(Vector3.ONE * 0.38), "Loaded object lands in exact existing cargo slot")
	check(impacts.size() == 1 and world.van.visual_tweens.is_empty(), "WHAM fires once and flight releases tween")
	await create_timer(0.24).timeout
	check(is_zero_approx(world.van.model.position.y), "Van returns to neutral after impact")
	run.escape()
	check(run.result.earned == 140 and store.data.wallet == 140, "Escape banks the carried item's value immediately")
	await new_session("apartment")
	begin()
	stand_by(world.items[7])
	tick(3)
	world.player._process(0.2)
	check(run.carried != null and world.player.visual.heavy and world.player.visual.animation_state == "HEAVY CARRY", "Fridge activates comic heavy pose in live run")
	run.drop()
	world.player._process(0.2)
	check(not world.player.visual.carrying and not world.player.visual.heavy and world.player.visual.carry_blend == 0, "Drop restores free arms and clears heavy pose")
	var sound = SoundBank.new()
	root.add_child(sound)
	check(sound.clips.has("wham") and sound.clips.wham != sound.clips.load, "Landing has a distinct short impact sound")
	sound.free()
	print("CHARACTER SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

