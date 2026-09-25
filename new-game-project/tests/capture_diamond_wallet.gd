extends SceneTree
func _initialize() -> void: call_deferred("capture")
func shot(id: String) -> void:
	await create_timer(0.55).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/diamond_"+id+".png")
func capture() -> void:
	LocalLog.enabled=false
	root.size=Vector2i(450,800)
	var game=load("res://scenes/main.tscn").instantiate()
	game.store=SaveStore.new()
	game.store.session_only=true
	game.store.data.tutorial_completed=true
	game.store.data.heist_briefing_seen=true
	game.store.data.wallet=9420
	game.store.data.diamonds=50
	root.add_child(game)
	await shot("home")
	root.size=Vector2i(360,800)
	game.open_menu("locations")
	await shot("jobs_narrow")
	game.open_menu("shop")
	await shot("shop_narrow")
	game.open_menu("daily_wheel")
	await shot("wheel_narrow")
	game.start_run("apartment")
	await shot("hud_narrow")
	game.cleanup_run()
	game.free()
	await process_frame
	quit()
