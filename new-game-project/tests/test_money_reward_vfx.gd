extends "res://tests/test_suite.gd"

var controller: CashBurst3D
var completed: Array[int] = []

func make_controller() -> void:
	controller = CashBurst3D.new()
	world.add_child(controller)
	controller.setup(run)
	controller.set_process(false)
	controller.collected.connect(func(amount: int): completed.append(amount))

func step(seconds: float) -> void:
	for i in range(ceili(seconds * 60.0)):
		controller._process(1.0 / 60.0)

func capture(name: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"): return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/money_reward_%s.png" % name)

func capture_model_detail() -> void:
	if not OS.get_cmdline_user_args().has("--capture"): return
	var viewport := SubViewport.new()
	viewport.size = Vector2i(512, 512)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("102536")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("cfe5d8")
	settings.ambient_light_energy = 0.45
	environment.environment = settings
	viewport.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -35, 0)
	light.light_energy = 1.0
	viewport.add_child(light)
	var camera := Camera3D.new()
	viewport.add_child(camera)
	camera.position = Vector3(0.28, 0.28, 0.72)
	camera.look_at(Vector3.ZERO)
	camera.fov = 42
	camera.current = true
	var piece := CashPiece3D.new()
	viewport.add_child(piece)
	piece.configure(controller.body_mesh, controller.face_mesh, controller.band_mesh, controller.body_material, controller.face_material, controller.band_material)
	piece.rotation = Vector3(0.28, 0.42, 0.12)
	piece.show()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png("res://tests/money_reward_model_detail.png")
	viewport.free()

func test() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	await create_run()
	world.player.position = world.van.load_position + Vector3(-0.75, 0, 0.2)
	make_controller()
	check(world.van.money_burst_origin.name == "MoneyBurstOrigin" and world.player.money_magnet_anchor.name == "PlayerMoneyMagnetAnchor", "Dedicated van and torso anchors exist")
	check(CashBurst3D.piece_count(50) == 9 and CashBurst3D.piece_count(340) == 12 and CashBurst3D.piece_count(1000) == 16 and CashBurst3D.piece_count(2500) == 19, "Reward tiers are cosmetic 9/12/16/19")
	check(CashBurst3D.piece_count(1500) == 19, "$1500 enters the highest visual tier without changing its value")
	for amount in [50, 340, 1000, 2500]:
		var cargo_before: int = run.cargo_value
		var wallet_before: int = store.data.wallet
		var count := controller.play_reward_vfx(amount)
		check(count == CashBurst3D.piece_count(amount), "$%d creates expected mesh count" % amount)
		var piece := controller.active_pieces[0]
		check(piece.get_child_count() == 3 and piece.get_child(0) is MeshInstance3D and piece.get_child(1) is MeshInstance3D and piece.get_child(2) is MeshInstance3D, "$%d consists of three real MeshInstance3D boxes" % amount)
		check(piece.get_child(0).mesh is BoxMesh and piece.get_child(0).mesh.size.y >= 0.015 and piece.get_child(2).mesh.size.z > piece.get_child(0).mesh.size.z, "$%d has real thickness, green face and raised band" % amount)
		check(piece.global_position.distance_to(world.van.money_burst_origin.global_position) < 0.01, "$%d starts at van origin" % amount)
		step(0.22)
		var farthest := 0.0
		for active_piece in controller.active_pieces:
			farthest = maxf(farthest, active_piece.global_position.distance_to(world.van.money_burst_origin.global_position))
		check(farthest < 1.5 and piece.rotation.length() > 0.1, "$%d stays compact and rotates in 3D" % amount)
		await capture(str(amount))
		step(0.65)
		check(controller.active_pieces.is_empty() and completed.back() == amount, "$%d completes and returns every piece to pool" % amount)
		check(run.cargo_value == cargo_before and store.data.wallet == wallet_before, "$%d VFX does not modify van loot or wallet" % amount)
	check(controller.all_pieces.size() == 19, "Different reward tiers reuse a bounded pool")
	await capture_model_detail()
	var first_count := controller.play_reward_vfx(340)
	controller.play_reward_vfx(2500)
	controller.play_reward_vfx(2500)
	check(first_count == 12 and controller.active_pieces.size() == 40 and controller.all_pieces.size() == 40, "Overlapping loads respect global 40-piece cap")
	var fourth_count := controller.play_reward_vfx(50)
	check(fourth_count == 6 and controller.active_pieces.size() == 40 and controller.all_pieces.size() == 40, "A fourth immediate load reuses oldest visual pieces instead of losing its burst")
	var frozen_position := controller.active_pieces[0].global_position
	var frozen_clock := controller.clock
	run.pause()
	step(0.2)
	check(controller.clock == frozen_clock and controller.active_pieces[0].global_position == frozen_position, "Pause freezes money animation")
	run.resume()
	step(0.88)
	check(controller.active_pieces.is_empty() and controller.pool.size() == 40 and controller.pending.is_empty(), "Overlapping bursts cleanly return every piece")
	controller.play_reward_vfx(50)
	step(0.39)
	var old_target := world.player.money_magnet_anchor.global_position
	world.player.position += Vector3(-1.2, 0, 0)
	var new_target := world.player.money_magnet_anchor.global_position
	step(0.36)
	var moving_piece := controller.active_pieces[0]
	check(moving_piece.global_position.distance_to(new_target) < moving_piece.global_position.distance_to(old_target), "Magnet tracks moving player's current torso position")
	step(0.2)
	check(controller.active_pieces.is_empty(), "Moving-target burst finishes without leftovers")
	controller.play_reward_vfx(50)
	controller.clear_active()
	check(controller.active_pieces.is_empty() and controller.pending.is_empty(), "Explicit cleanup cancels an active burst")
	var old_controller := controller
	await create_run()
	check(not is_instance_valid(old_controller) and world.player.money_magnet_anchor != null, "New run has no cash from previous run")
	print("MONEY REWARD VFX CHECKS %d; FAILURES %d" % [checks, failures])
	quit(1 if failures > 0 else 0)
