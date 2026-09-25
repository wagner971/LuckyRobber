extends SceneTree
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	LocalLog.enabled=false
	root.size=Vector2i(450,800)
	var game=load("res://scenes/main.tscn").instantiate()
	game.store=SaveStore.new()
	game.store.session_only=true
	game.store.data.tutorial_completed=true
	game.store.data.heist_briefing_seen=true
	root.add_child(game)
	game.store.data.lucky_pending={"id":"weak","seen":false}
	game.present_lucky()
	var reveal: LuckyReveal=game.ui.gift_reveal
	reveal.set_process(false)
	for time in [0.5,2.2]:
		reveal.elapsed=time
		reveal.update_visual()
		for i in range(5): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/lucky_%s.png" % ("block" if time<1 else "curse"))
	reveal.claim.pressed.emit()
	game.start_run("apartment")
	game.run.set_physics_process(false)
	while not game.run.world_prepared: await physics_frame
	for item in game.level.items.duplicate():
		if item.data.type_id=="lucky_block": game.level.items.erase(item); item.free()
	var block:=LuckyEffects.spawn(game.level,Vector3(-0.5,0.04,1.3))
	game.run.lucky.mark(block,"LUCKY BLOCK",Color("bd49ff"),false)
	game.run.intention=Vector2.ZERO
	game.ui.update_run(game.run,0)
	for i in range(8): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/lucky_world.png")
	game.cleanup_run()
	game.store.data.lucky_pending={"id":"magnet","seen":false}
	game.present_lucky()
	reveal=game.ui.gift_reveal
	reveal.set_process(false)
	root.size=Vector2i(360,800)
	reveal.insets=Vector4(0,32,0,24)
	reveal.layout()
	reveal.elapsed=2.3
	reveal.update_visual()
	for i in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/lucky_narrow.png")
	game.cleanup_run()
	game.free()
	await process_frame
	quit()

