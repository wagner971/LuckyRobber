extends SceneTree
func _initialize() -> void: call_deferred("capture")
func shot(id: String, delay: float = 0.4) -> void:
	await create_timer(delay).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/lucky_wheel_" + id + ".png")
func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new()
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.heist_briefing_seen = true
	game.store.data.wallet = 1200
	game.store.data.diamonds = 12
	root.add_child(game)
	game.open_menu("daily_wheel")
	await shot("ready")
	var prize = game.store.claim_daily_spin(int(Time.get_unix_time_from_system()), 38)
	game.ui.animate_daily_spin(prize, game.store)
	await shot("spinning", 0.8)
	await shot("jackpot", 3.0)
	root.size = Vector2i(360, 800)
	game.ui.set_safe_area_override(Vector4(0, 44, 0, 30))
	game.open_menu("daily_wheel")
	game.store.dev_rewards_unlimited = false
	game.ui.refresh_daily_wheel(game.store)
	await shot("narrow_used")
	game.ui.wheel_info(game.store)
	await shot("odds")
	game.free()
	await process_frame
	quit()
