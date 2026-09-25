extends "res://tests/test_ui_v2.gd"

func shot(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"): return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/variety_" + label + ".png")

func start_clock(game: Node) -> void:
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	game.run.intention = Vector2.RIGHT
	game.run._physics_process(1.0 / 60)
	game.run.intention = Vector2.ZERO

func test() -> void:
	LocalLog.enabled = false
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/variety_ui_profile.json")
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.special_interval = 2
	root.add_child(game)
	game.set_physics_process(false)
	check(not game.store.session_only and game.development_mode, "Persistent DEV profile")
	check(not all_text(game.ui.menu).contains("SPECIAL JOB AVAILABLE"), "No special card before threshold")
	check(not game.dev_force_special("museum"), "Developer hook cannot force locked location")
	game.start_run("apartment", "special")
	check(game.run == null, "Special cannot be launched without offer")
	for i in range(2):
		game.start_run("apartment")
		start_clock(game)
		game.run.abandon()
	check(game.store.data.special_pending and all_text(game.ui.menu).contains("RUSH HOUR AVAILABLE IN JOBS"), "Result announces exact normal threshold")
	game.action("locations")
	await process_frame
	check(find_button(game.ui.menu, "⚡ RUSH HOUR · 35s · +40%") != null and find_button(game.ui.menu, "PLAY  ▶") != null, "Pending card has both choices")
	check(all_text(game.ui.menu).contains("35s · +40%") and game.ui.jobs_index == 0, "Offer clearly shows conditions on the Apartment page")
	await shot("offer")
	var pending = game.store.data.duplicate(true)
	game.action("shop")
	game.action("locations")
	check(game.store.data == pending, "Navigation cannot reroll or advance scheduler")
	check(not game.dev_force_special("apartment"), "Hook cannot replace existing offer")
	find_button(game.ui.menu, "PLAY  ▶").pressed.emit()
	check(game.run.mode == "normal" and game.run.remaining == 60 and game.store.data.special_pending, "Continue Normal plays60 and preserves pending")
	start_clock(game)
	game.run.abandon()
	check(game.store.data.special_interval == pending.special_interval and game.store.data.special_location_id == pending.special_location_id and game.store.data.runs_since_special == 2, "Ignoring actual offer does not replace or queue specials")
	game.action("locations")
	find_button(game.ui.menu, "⚡ RUSH HOUR · 35s · +40%").pressed.emit()
	game.run.set_physics_process(false)
	game.ui.update_run(game.run, 0)
	check(game.run.mode == "special" and game.run.remaining == 35 and not Progression.campaign_cleared(game.store.data), "Special playable before Mastery unlock")
	check(game.ui.session_info.text.contains("RUSH HOUR") and game.ui.session_info.text.contains("+40% CASH") and game.ui.timer.text == "35.0", "Special HUD identifies35 and bonus")
	await shot("hud")
	game.action("locations")
	check(game.store.data.special_pending and not game.store.data.special_in_progress, "Back before first movement preserves offer")
	game.action("play_special")
	game.run.set_physics_process(false)
	game.action("pause")
	game.action("abandon")
	check(game.store.data.special_pending, "READY abandon preserves offer")
	game.action("locations")
	game.action("play_special")
	start_clock(game)
	var active = game.run
	game.start_run("apartment", "normal")
	check(game.run == active and game.run.mode == "special", "Active run cannot be silently replaced by restart")
	check(not game.dev_force_special("apartment"), "Hook blocked during active run")
	# UI settlement fixture: one genuinely LOADED TV, value140.
	game.level.player.position = game.level.van.load_position
	game.run.carried = game.level.items[0]
	game.run.carried.state = LootItem.State.LOADING
	game.run.commit_load()
	game.action("escape")
	check(game.last_result.success and game.last_result.rush_bonus == 56 and game.store.data.wallet == 196 and game.screen == "results", "Live Rush banks base140 and bonus56 directly")
	check(game.store.data.wallet == 196, "Rush payout is not repeated")
	var result_text = all_text(game.ui.menu)
	check(result_text.contains("LOOT VALUE $140") and result_text.contains("RUSH BONUS +$56"), "Special result keeps a compact, correct bonus breakdown")
	check(not result_text.contains("CONTRACT NOT MET") and not result_text.contains("MEDAL EARNED"), "Special results do not pretend to be Mastery")
	check(find_button(game.ui.menu, "PLAY AGAIN →") == null and find_button(game.ui.menu, "CONTINUE NORMAL") != null, "One-off special cannot replay from result")
	await shot("results")
	find_button(game.ui.menu, "CONTINUE NORMAL").pressed.emit()
	check(game.run.mode == "normal" and game.run.remaining == 60, "Result returns to normal60")
	game.action("locations")
	check(not all_text(game.ui.menu).contains("SPECIAL JOB AVAILABLE"), "Consumed card disappears")
	await shot("normal")
	check(game.dev_force_special("apartment") and game.store.data.runs_since_special == game.store.data.special_interval, "Developer hook safely forces threshold")
	var interval = game.store.data.special_interval
	game.action("dev_max")
	check(game.store.data.special_interval == interval and game.store.data.special_pending, "DEV MAX does not consume or reroll job")
	game.free()
	await process_frame
	game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/variety_ui_profile.json")
	game.store.load_progress()
	root.add_child(game)
	check(game.store.data.wallet == 196 and game.store.data.special_pending and game.store.data.special_interval == interval and Progression.upgrades_maxed(game.store.data), "New DEV game instance restores money, MAX abilities and exact pending offer")
	check(all_text(game.ui.menu).contains("RUSH HOUR READY"), "Restored offer is announced on Home")
	check(find_button(game.ui.menu, "PLAY") != null and find_button(game.ui.menu, "PLAY").tooltip_text == "RUSH HOUR", "Restored Home highlights the pending Rush Hour")
	game.action("locations")
	check(find_button(game.ui.menu, "⚡ RUSH HOUR · 35s · +40%") != null, "Restored offer is playable from Jobs")
	game.development_mode = false
	check(not game.dev_force_special("apartment"), "Developer force hook disabled in production")
	game.free()
	print("VARIETY UI SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

