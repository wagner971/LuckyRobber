extends "res://tests/test_ui_v2.gd"

func test() -> void:
	LocalLog.enabled = false
	# Check all RNG buckets, including both illustrations for medium cash.
	var distribution := {}
	for draw in range(100):
		var prize := DailyWheel.choose(SaveStore.new().data, draw)
		distribution[prize.id] = distribution.get(prize.id, 0) + 1
		for variant in range(DailyWheelView.slots_for(prize.index).size()):
			var destination := DailyWheelView.target_rotation(prize.index, variant)
			check(DailyWheelView.prize_at_rotation(destination + TAU * 5) == prize.index, "Draw %d maps to the correct PNG sector %d" % [draw, variant])
	for prize in DailyWheel.PRIZES:
		check(distribution.get(prize.id, 0) == prize.weight, "Art preserves exact odds: " + prize.id)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new()
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.heist_briefing_seen = true
	root.add_child(game)
	game.store.dev_rewards_unlimited = true
	for viewport_size in [Vector2i(450,800), Vector2i(360,800)]:
		root.size = viewport_size
		game.ui.set_safe_area_override(Vector4(0,40,0,30))
		game.open_menu("daily_wheel")
		await process_frame
		await process_frame
		var art = game.ui.wheel_disc.get_parent().get_parent()
		art.fit()
		var visible_area = Rect2(Vector2(0,40), game.ui.root.size - Vector2(0,70))
		check(visible_area.encloses(game.ui.wheel_spin_button.get_global_rect()), "Spin touch target fits safe area " + str(viewport_size))
		check(visible_area.encloses(game.ui.wheel_disc.get_global_rect()), "Entire circle fits safe area " + str(viewport_size))
		check(is_equal_approx(art.canvas.scale.x, art.canvas.scale.y), "PNG circle is never stretched into an ellipse")
	# Animate each real payout: no second award from the view and no balance spoiler.
	Engine.time_scale = 10
	for draw in [0,38,39,59,81,82,92]:
		var prize = game.store.claim_daily_spin(int(Time.get_unix_time_from_system()), draw)
		var wallet: int = game.store.data.wallet
		var diamonds: int = game.store.data.diamonds
		game.ui.animate_daily_spin(prize, game.store)
		check(game.ui.wheel_busy and game.ui.wheel_spin_button.disabled, "Tap locked while spinning")
		await create_timer(3.6).timeout
		check(not game.ui.wheel_busy and DailyWheelView.prize_at_rotation(game.ui.wheel_disc.rotation) == prize.index, "Animated result matches awarded prize " + prize.id)
		check(game.store.data.wallet == wallet and game.store.data.diamonds == diamonds, "Reveal never credits a second reward")
		check(game.ui.menu_diamond_label.text == str(diamonds), "Wallet updates when the reward is revealed")
	# Navigation cancels the visual, while the save keeps the already committed award.
	var pending = game.store.claim_daily_spin(int(Time.get_unix_time_from_system()), 39)
	game.ui.animate_daily_spin(pending, game.store)
	var saved_gems: int = game.store.data.diamonds
	game.open_menu("home")
	await create_timer(3.6).timeout
	check(game.ui.wheel_disc == null and not game.ui.wheel_busy and game.store.data.diamonds == saved_gems, "Leaving mid-spin cannot lose or duplicate a saved reward")
	game.store.dev_rewards_unlimited = false
	game.open_menu("daily_wheel")
	check(game.ui.wheel_spin_button.disabled and game.ui.wheel_reset.text.begins_with("NEXT SPIN"), "Production cooldown dims the PNG button and shows the reset timer")
	game.free()
	await process_frame
	print("WHEEL ART: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
