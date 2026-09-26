extends Node

var store: SaveStore
var level: HeistLevel
var run: RunManager
var ui: GameUI
var sound: SoundBank
var haptics: HapticManager
var camera_juice: CameraJuice
var current_location = "apartment"
var current_mode = "normal"
var last_result: Dictionary = {}
var screen = "home"
var sound_muted = false
var sfx_volume := 1.0
var haptics_enabled := true
var camera_effects_enabled := true
var duplication_refresh_at := 0
var wheel_refresh_at := 0
var gift_refresh_at := 0
var shop_day_seen := -1
var guided_upgrade_active := false
var development_mode = bool(ProjectSettings.get_setting("development/enabled", false))

func _ready() -> void:
	get_tree().auto_accept_quit = false
	get_tree().quit_on_go_back = false
	var launch_owned_store := store == null
	if store == null:
		var test_profile = OS.get_cmdline_user_args().has("--test-profile")
		store = create_launch_store(launch_profile_path(test_profile))
		if development_mode:
			LocalLog.enabled = false
		elif test_profile:
			LocalLog.enabled = false
			store.notice = "TEST PROFILE · Separate progress; your main save is unchanged."
	sound = SoundBank.new()
	add_child(sound)
	haptics = HapticManager.new()
	add_child(haptics)
	ui = GameUI.new()
	ui.development_mode = development_mode
	add_child(ui)
	ui.start_requested.connect(request_run)
	ui.buy_requested.connect(buy)
	ui.cosmetic_requested.connect(cosmetic_action)
	ui.action_requested.connect(request_action)
	ui.cash_reward_collected.connect(func(): sound.play("cash_collect"))
	ui.wheel_reward_revealed.connect(func(prize: Dictionary):
		sound.play("special_reveal" if prize.kind == "jackpot" else "cash_collect")
		haptics.play("upgrade")
	)
	load_preferences()
	if launch_owned_store and not store.data.tutorial_completed:
		start_tutorial()
	else: ui.home(store)
	store.dev_rewards_unlimited = development_mode
	if screen == "home": present_pending_gift()

func launch_profile_path(test_profile: bool) -> String:
	if test_profile: return "user://challenge_v2_test_profile.json"
	return "user://dev_progress.json" if development_mode else "user://progress.json"

func create_launch_store(profile_path: String) -> SaveStore:
	var launch_store = SaveStore.new(profile_path)
	launch_store.dev_rewards_unlimited = development_mode
	if not profile_path.ends_with("challenge_v2_test_profile.json"):
		launch_store.wheel_ledger_path = "user://daily_wheel.json"
	if development_mode:
		# A new DEV launch starts with defaults. Save during this session still works,
		# including tutorial progress and Special Jobs, but the next launch resets it.
		launch_store.load_daily_ledger()
		launch_store.save_progress()
		launch_store.notice = "DEV MODE · Fresh start every launch. Progress lasts for this session."
	else:
		launch_store.load_progress()
	return launch_store

func start_run(location: String, mode: String = "normal", training: bool = false) -> void:
	if not training and not store.data.lucky_pending.is_empty() and not store.data.lucky_pending.seen:
		present_lucky()
		return
	if not store.unlocked(location) or mode not in Balance.MODES: return
	if mode == SpecialJobs.MODE:
		if not SpecialJobs.can_play(store.data, location): return
	elif mode == "FINAL_JOB":
		if not Progression.powerups_ready(store.data,location):
			ui.shop_selected_key = Progression.missing_loadout(store.data, location)[0]
			open_menu("shop")
			return
		if location == "apartment":
			if not Progression.final_job_unlocked(store.data): return
		elif location == "museum":
			if not Progression.museum_final_job_unlocked(store.data): return
		else: return
		if Balance.van_capacity(store.data.upgrades.capacity) < Balance.LOCATIONS[location].expected_cargo: return
	elif mode != "normal" and not Progression.campaign_cleared(store.data): return
	if is_instance_valid(run) and run.phase in [RunManager.Phase.ACTIVE, RunManager.Phase.PAUSED]: return
	cleanup_run()
	current_location = location
	current_mode = mode
	screen = "run"
	level = HeistLevel.new()
	add_child(level)
	level.setup(location, store.data.upgrades.capacity, false, training)
	level.set_visual_polish(camera_effects_enabled)
	camera_juice = CameraJuice.new()
	level.add_child(camera_juice)
	camera_juice.setup(level.camera, level.player)
	camera_juice.set_enabled(camera_effects_enabled)
	Models.apply_appearance(level.player.visual, level.van.model, store.data.cosmetics.equipped)
	run = RunManager.new()
	add_child(run)
	run.setup(level, store, location, mode)
	run.feedback.connect(on_feedback)
	run.ended.connect(on_ended)
	run.cash_loaded.connect(func(amount: int): ui.show_cash_load(run, amount))
	ui.show_run()
	ui.set_scene_polish(location, camera_effects_enabled)
	ui.update_run(run, 0)
	if not training and mode == "normal" and not store.data.heist_briefing_seen and store.data.successes == 0:
		run.pause()
		screen = "heist_briefing"
		ui.show_heist_briefing(location)

func request_run(location: String, mode: String = "normal") -> void:
	if is_instance_valid(ui.gift_reveal): return
	if ui.motion.travelling: return
	present_run(func(): start_run(location, mode))

func request_action(kind: String) -> void:
	if is_instance_valid(ui.gift_reveal): return
	if ui.motion.travelling: return
	if kind in ["play_special", "play_final_job", "play_museum_final_job", "replay_tutorial", "retry_tutorial", "dev_final_job"]:
		present_run(func(): action(kind))
	else: action(kind)

func present_run(start: Callable) -> void:
	ui.input.reset()
	var pending := {}
	ui.motion.travel(func():
		start.call()
		if is_instance_valid(run) and screen in ["run", "heist_briefing"]:
			pending["run"] = weakref(run)
			pending["physics"] = run.is_physics_processing()
			pending["player"] = level.player.enabled
			pending["input"] = ui.input.enabled
			run.set_physics_process(false)
			level.player.enabled = false
			ui.input.enabled = false
	, func():
		if pending.has("run") and pending.run.get_ref() == run and is_instance_valid(run):
			run.set_physics_process(pending.physics)
			# A focus-loss pause during the reveal must remain paused.
			if run.phase != RunManager.Phase.PAUSED:
				level.player.enabled = pending.player
				ui.input.enabled = pending.input
			ui.input.reset()
	)

func start_tutorial(replay: bool = false) -> void:
	if is_instance_valid(run) and run.phase in [RunManager.Phase.ACTIVE, RunManager.Phase.PAUSED]: return
	start_run("apartment", "normal", true)
	if run == null: return
	run.enable_tutorial(replay)
	ui.update_run(run, 0)

func play() -> void:
	open_menu("locations")

func cleanup_run() -> void:
	if is_instance_valid(run):
		run.set_physics_process(false)
		run.queue_free()
		run = null
	if is_instance_valid(level):
		level.player.enabled = false
		level.queue_free()
		level = null
	camera_juice = null

func _physics_process(_delta: float) -> void:
	if is_instance_valid(run): run.intention = ui.input.movement()

func _process(delta: float) -> void:
	if is_instance_valid(ui.menu_diamond_label) and not (screen == "daily_wheel" and ui.wheel_busy) and ui.menu_diamond_label.text != str(store.data.diamonds):
		ui.menu_diamond_label.text = str(store.data.diamonds)
	if is_instance_valid(run) and screen == "run": ui.update_run(run, delta)
	if screen == "duplication" and Time.get_ticks_msec() >= duplication_refresh_at:
		duplication_refresh_at = Time.get_ticks_msec() + 500
		ui.update_duplication_timers(store)
	if screen == "daily_wheel" and not ui.wheel_busy and Time.get_ticks_msec() >= wheel_refresh_at:
		wheel_refresh_at = Time.get_ticks_msec() + 1000
		ui.refresh_daily_wheel(store)
	if screen == "home" and Time.get_ticks_msec() >= gift_refresh_at:
		gift_refresh_at = Time.get_ticks_msec() + 1000
		ui.refresh_home_gift(store)
	if screen in ["cosmetics", "vehicle"] and PlayRewards.shop_day() != shop_day_seen:
		shop_day_seen = PlayRewards.shop_day()
		if screen == "vehicle": ui.refresh_vehicle(store)
		else: ui.refresh_cosmetics(store)

func on_feedback(kind: String, message: String) -> void:
	match kind:
		"pickup":
			var heavy: bool = is_instance_valid(run) and is_instance_valid(run.carried) and run.carried.data.weight_class in ["HEAVY", "VERY_HEAVY"]
			sound.play("pickup_heavy" if heavy else "pickup_light")
			haptics.play("pickup_heavy" if heavy else "pickup_light")
			if is_instance_valid(camera_juice): camera_juice.pickup_kick()
		"rare_found": sound.play("special_reveal")
		"lucky_spawn":
			sound.play("special_reveal")
			haptics.play("upgrade")
		"load": sound.play("cash_burst")
		"wham":
			var weight := str(level.van.last_impact_weight) if is_instance_valid(level) else "MEDIUM"
			var category := weight.to_lower()
			sound.play("impact_" + category)
			haptics.play("load_" + category)
			if is_instance_valid(camera_juice): camera_juice.impact_punch({"LIGHT": 0.08, "MEDIUM": 0.30, "HEAVY": 0.60, "VERY_HEAVY": 0.85}.get(weight, 0.30))
		"noise": sound.play("noise_tick")
		"noise_warning": sound.play("noise_warning")
		"full":
			sound.play("noise_warning")
			haptics.play("alarm")
		"alarm":
			sound.play("alarm_trigger")
			haptics.play("alarm")
			if is_instance_valid(camera_juice): camera_juice.alarm_pulse()
		"tick":
			if is_instance_valid(run) and run.remaining <= 5.0: sound.play("timer_tick")
		"success":
			sound.play("escape_success")
			haptics.play("escape")
			if is_instance_valid(camera_juice): camera_juice.success_pulse()
		"failure":
			sound.play("busted")
			haptics.play("busted")
			if is_instance_valid(camera_juice): camera_juice.busted_punch()
		_: sound.play(kind)
	if is_instance_valid(run) and run.onboarding != null: return
	ui.notify(message)

func on_ended(result: Dictionary) -> void:
	last_result = result
	ui.input.reset()
	if result.get("tutorial", false):
		if result.get("success", false) and not result.get("replay", false):
			screen = "tutorial_departure"
			ui.hud.hide()
			ui.input.enabled = false
			var departure := create_tween()
			departure.tween_property(level.van.model, "position", level.van.model.position + Vector3(0, 0, 4.5), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			await departure.finished
			if screen == "tutorial_departure":
				screen = "results"
				ui.page_motion_requested = true
				ui.tutorial_results(result,store)
			return
		screen = "results"
		ui.page_motion_requested = true
		ui.tutorial_results(result, store)
		return
	show_run_results()

func show_run_results() -> void:
	ui.page_motion_requested = true
	screen = "results"
	store.save_progress()
	if last_result.is_empty():
		open_menu("home")
		return
	var result: Dictionary = last_result
	ui.results(result, store, current_location)
	if result.get("special_unlocked", false):
		sound.play("special_reveal")
	var new_trophies: Array = result.get("new_trophies", [])
	if not new_trophies.is_empty():
		reveal_trophy_sound(ui.menu)
	if result.get("final_job_completed", false):
		sound.play("special_reveal")
	present_pending_gift()

func present_pending_gift() -> void:
	if store.read_only or store.last_error != "": return
	var reward := LevelGifts.pending(store.data)
	var pending_lucky: bool = not store.data.lucky_pending.is_empty() and not store.data.lucky_pending.seen
	if (reward.is_empty() and not pending_lucky) or is_instance_valid(ui.gift_reveal): return
	var result_menu := ui.menu
	await get_tree().create_timer(1.2).timeout
	if not is_instance_valid(ui) or ui.menu != result_menu or screen not in ["home","results"] or is_instance_valid(ui.gift_reveal): return
	if pending_lucky: present_lucky()
	else: present_gift(false,reward)

func present_lucky() -> void:
	if is_instance_valid(ui.gift_reveal) or store.data.lucky_pending.is_empty(): return
	ui.set_previews_active(false)
	var reveal := LuckyReveal.new()
	reveal.configure(false,{"lucky":store.data.lucky_pending.id,"tokens":store.data.lucky_pending.get("tokens",LuckyMeter.tokens_for(store.data.lucky_pending.id))},ui.heavy_font,ui.safe_insets)
	ui.gift_reveal = reveal
	ui.root.add_child(reveal)
	reveal.cue.connect(func(kind: String): sound.play(kind))
	var acknowledge := func() -> bool:
		store.data.lucky_pending.seen = true
		if not store.save_progress():
			store.data.lucky_pending.seen = false
			reveal.claim.text = "SAVE FAILED · RETRY"
			reveal.claim.disabled = false
			reveal.play_button.disabled = false
			return false
		ui.gift_reveal = null
		reveal.queue_free()
		ui.set_previews_active(true)
		return true
	reveal.collected.connect(func():
		if acknowledge.call(): present_pending_gift()
	)
	# The twist is the hook: one tap goes straight back into the last heist.
	reveal.play_now.connect(func():
		if not acknowledge.call(): return
		var target := str(store.data.get("last_location", ""))
		if target == "" or not store.unlocked(target): target = current_location if current_location != "" and store.unlocked(current_location) else "apartment"
		present_run(func(): start_run(target, "normal"))
	)

func present_gift(daily: bool, reward: Dictionary) -> void:
	if is_instance_valid(ui.gift_reveal): return
	ui.set_previews_active(false)
	var reveal := GiftReveal.new()
	reveal.configure(daily,reward,ui.heavy_font,ui.safe_insets)
	ui.gift_reveal = reveal
	ui.root.add_child(reveal)
	reveal.cue.connect(func(kind: String): sound.play(kind))
	reveal.collected.connect(func():
		if reward.has("location"):
			var entry: Dictionary = store.data.level_gifts.get(reward.location,{})
			if not entry.is_empty():
				entry.seen = true
				if not store.save_progress():
					entry.seen = false
					reveal.claim.text = "SAVE FAILED · RETRY"
					reveal.claim.disabled = false
					return
		ui.gift_reveal = null
		reveal.queue_free()
		ui.set_previews_active(true)
		if daily and development_mode:
			present_gift(false,{"rarity":LevelGifts.roll(),"prototype":true,"dev_preview":true})
	)

func reveal_trophy_sound(result_menu: Control) -> void:
	await get_tree().create_timer(0.72).timeout
	if screen == "results" and is_instance_valid(result_menu) and ui.menu == result_menu: sound.play("special_reveal")

func buy(key: String) -> void:
	if screen not in ["locations", "shop"]: return
	var old_wallet: int = store.data.wallet
	var old_level: int = store.data.upgrades[key]
	if not store.purchase(key, true): return
	LocalLog.event("upgrade_purchased", {"upgrade": key, "level": store.data.upgrades[key], "wallet": store.data.wallet})
	sound.play("strength_unlock" if key == "strength" else "upgrade_purchase")
	haptics.play("strength" if key == "strength" else "upgrade")
	if guided_upgrade_active and key == "carry":
		guided_upgrade_active = false
	if screen == "shop": ui.shop_page(store)
	else: ui.locations(store)
	ui.animate_upgrade_purchase(key, old_wallet, old_level, store)

func cosmetic_action(id: String, operation: String) -> void:
	if screen not in ["cosmetics", "vehicle"]: return
	var previous_wallet: int = store.data.wallet
	var purchased := false
	if operation == "buy":
		purchased = store.purchase_cosmetic(id, true, -1, id in Balance.VEHICLE_ORDER)
		if purchased: sound.play("upgrade")
	elif operation == "equip": store.equip_cosmetic(id, true)
	elif operation == "reset": store.unequip_cosmetics(true)
	elif operation == "reset_suit": store.unequip_slot("suit", true)
	elif operation == "reset_van": store.unequip_slot("van", true)
	if screen == "vehicle":
		ui.refresh_vehicle(store)
		if purchased: ui.animate_vehicle_purchase(previous_wallet,store)
	else: ui.refresh_cosmetics(store)

func action(kind: String) -> void:
	if is_instance_valid(ui.gift_reveal): return
	if kind.begins_with("gift_view:") and screen == "trophies":
		var location := kind.trim_prefix("gift_view:")
		if store.data.level_gifts.has(location):
			present_gift(false,{"rarity":store.data.level_gifts[location].rarity,"prototype":true})
		return
	if kind.begins_with("garage_buy:"):
		if screen != "garage": return
		var old_cash := int(store.data.wallet)
		if store.purchase_garage(kind.trim_prefix("garage_buy:"),true):
			sound.play("upgrade_purchase")
			haptics.play("upgrade")
			ui.garage_page(store)
			ui.garage_title.text = "MADE IT YOURS!"
			ui.garage_live_preview.celebrate_furniture(kind.trim_prefix("garage_buy:"))
			UiJuice.count_label(ui.garage_wallet,old_cash,int(store.data.wallet),0.45)
			UiJuice.pulse(ui.garage_buy,1.04,0.22)
		else: ui.refresh_garage_selection(store)
		return
	if kind.begins_with("vehicle_preview:") and screen in ["cosmetics", "vehicle"]:
		var id := kind.trim_prefix("vehicle_preview:")
		if id in Balance.VEHICLE_ORDER and (id in PlayRewards.today_shop() or id in store.data.cosmetics.owned):
			ui.selected_vehicle = id
			open_menu("vehicle")
		return
	if kind.begins_with("duplicate:") and screen == "duplication":
		var parts := kind.split(":")
		if parts.size() == 3 and Duplication.start(store.data, int(parts[1]), parts[2], int(Time.get_unix_time_from_system())):
			store.save_progress()
			sound.play("upgrade_purchase")
			ui.duplication_lab(store)
		return
	if kind.begins_with("duplication_claim:") and screen == "duplication":
		var earned := Duplication.claim(store.data, int(kind.trim_prefix("duplication_claim:")), int(Time.get_unix_time_from_system()))
		if earned > 0:
			store.save_progress()
			sound.play("cash_collect")
			ui.duplication_lab(store)
		return
	if kind.begins_with("lucky_buy:") and screen == "lucky_shop":
		var reward_id := kind.trim_prefix("lucky_buy:")
		var before := store.data.duplicate(true)
		if LuckyShop.buy(store.data, reward_id):
			if store.save_progress():
				sound.play("upgrade")
				haptics.play("upgrade")
				if LuckyShop.CATALOG[reward_id].kind == "cosmetic": store.equip_cosmetic(str(LuckyShop.CATALOG[reward_id].cosmetic), true)
			else: store.data = before
			ui.lucky_shop_page(store)
		return
	if kind.begins_with("lucky_equip:") and screen == "lucky_shop":
		if LuckyShop.equip(store.data, kind.trim_prefix("lucky_equip:")):
			store.save_progress()
			sound.play("upgrade")
			ui.lucky_shop_page(store)
		return
	if kind.begins_with("sfx_volume:") and screen == "settings":
		sfx_volume = clampf(float(kind.trim_prefix("sfx_volume:")), 0, 1)
		sound.set_sfx_volume(sfx_volume)
		save_preferences()
		return
	match kind:
		"daily_gift":
			if screen != "home": return
			var old_cash := int(store.data.wallet)
			var gift := store.claim_daily_gift()
			if gift.is_empty():
				ui.refresh_home_gift(store)
				return
			sound.play("cash_collect")
			haptics.play("upgrade")
			ui.show_daily_gift_reward(gift, old_cash, store)
			present_gift(true,gift)
		"daily_spin":
			if screen != "daily_wheel" or ui.wheel_busy: return
			var prize := store.claim_daily_spin()
			if prize.is_empty():
				ui.refresh_daily_wheel(store)
				return
			ui.animate_daily_spin(prize, store)
		"begin_heist":
			if screen != "heist_briefing" or not is_instance_valid(run): return
			store.data.heist_briefing_seen = true
			store.save_progress()
			ui.close_pause(true)
			ui.input.reset()
			ui.input.enabled = true
			run.resume()
			screen = "run"
			ui.update_run(run,0)
		"duplication_upgrade":
			if screen != "duplication": return
			if Duplication.upgrade(store.data):
				store.save_progress()
				sound.play("upgrade_purchase")
				ui.duplication_lab(store)
		"play": play()
		"replay_tutorial":
			if screen == "settings": start_tutorial(true)
		"retry_tutorial":
			if screen == "results": start_tutorial(last_result.get("replay", false))
		"tutorial_continue":
			if screen == "results":
				ui.jobs_index = 0
				open_menu("locations")
		"guided_upgrade":
			if screen == "results":
				guided_upgrade_active = true
				ui.shop_selected_key = "carry"
				open_menu("shop")
		"play_special":
			start_run(store.data.special_location_id, SpecialJobs.MODE)
		"play_final_job":
			start_run("apartment", "FINAL_JOB")
		"play_museum_final_job":
			start_run("museum", "FINAL_JOB")
		"dev_final_job":
			# Human-playtest hook only: sets exactly the Apartment progression-tier
			# stats plus the Van level Final Job requires, and unlocks the objective
			# gate, so a tester can jump straight to the challenge itself without
			# grinding. Never exposed as a real UI button outside development_mode.
			if not development_mode or screen not in ["home", "locations", "shop"]: return
			for key in Balance.UPGRADE_KEYS: store.data.upgrades[key] = Balance.required_level(key, "apartment")
			store.data.objectives.apartment.cash = true
			store.data.objectives.apartment.signature = true
			start_run("apartment", "FINAL_JOB")
		"dev_max":
			if not development_mode or screen not in ["home", "locations", "shop", "settings"]: return
			for key in Balance.UPGRADE_KEYS: store.data.upgrades[key] = Balance.max_level(key)
			# Both finales count as done so Progression.refresh keeps every location, Chapter 2 included.
			store.data.apartment_final_job_completed = true
			store.data.museum_final_job_completed = true
			for location in Balance.LOCATION_ORDER:
				if location not in store.data.unlocked: store.data.unlocked.append(location)
			Progression.refresh(store.data)
			store.save_progress()
			sound.play("upgrade")
			if screen == "home": ui.home(store)
			elif screen == "shop": ui.shop_page(store)
			elif screen == "settings": ui.settings_page(store,sound_muted,sfx_volume,haptics_enabled,camera_effects_enabled)
			else: ui.locations(store)
		"home", "garage", "shop", "cosmetics", "collection", "trophies", "duplication", "locations", "stats", "settings", "daily_wheel", "lucky_shop":
			open_menu(kind)
		"toggle_sound":
			if screen != "settings": return
			sound_muted = not sound_muted
			AudioServer.set_bus_mute(0,sound_muted)
			save_preferences()
			ui.settings_page(store,sound_muted,sfx_volume,haptics_enabled,camera_effects_enabled)
		"toggle_haptics":
			if screen != "settings": return
			haptics_enabled = not haptics_enabled
			haptics.set_enabled(haptics_enabled)
			save_preferences()
			ui.settings_page(store,sound_muted,sfx_volume,haptics_enabled,camera_effects_enabled)
		"toggle_camera_effects":
			if screen != "settings": return
			camera_effects_enabled = not camera_effects_enabled
			if is_instance_valid(camera_juice): camera_juice.set_enabled(camera_effects_enabled)
			if is_instance_valid(level): level.set_visual_polish(camera_effects_enabled)
			ui.set_scene_polish(current_location, camera_effects_enabled)
			save_preferences()
			ui.settings_page(store,sound_muted,sfx_volume,haptics_enabled,camera_effects_enabled)
		"pause":
			if is_instance_valid(run) and run.phase in [RunManager.Phase.READY, RunManager.Phase.ACTIVE]:
				run.pause()
				ui.show_pause()
		"resume":
			if screen == "run" and is_instance_valid(run) and run.phase == RunManager.Phase.PAUSED:
				ui.input.reset()
				ui.input.enabled = true
				run.resume()
				ui.close_pause(true)
		"abandon":
			if is_instance_valid(run): run.abandon()
		"drop":
			if is_instance_valid(run): run.drop()
		"escape":
			if is_instance_valid(run): run.escape()

func _unhandled_key_input(event: InputEvent) -> void:
	if is_instance_valid(ui.gift_reveal): return
	if ui.motion.travelling: return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if screen == "run": action("pause")
		elif screen == "locations": action("home")
		elif screen != "home": action("locations")
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if not is_instance_valid(ui): return
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED]:
		ui.set_previews_active(false)
		ui.input.reset()
		if screen == "run": action("pause")
	elif what in [NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED]:
		ui.set_previews_active(true)
		if screen == "duplication": ui.duplication_lab(store)
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if screen == "run": action("pause")
		elif screen == "locations": action("home")
		elif screen != "home": action("locations")
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Only permanent progress is stored. An unfinished run has no claim on it.
		if is_instance_valid(run) and run.mode == SpecialJobs.MODE and run.started and run.phase != RunManager.Phase.FINISHED:
			run.abandon()
		store.save_progress()
		get_tree().quit()

# No production UI exposes this hook. It cannot change an active or pending job.
func dev_force_special(location: String) -> bool:
	if not development_mode or not store.unlocked(location) or store.data.special_pending: return false
	if is_instance_valid(run) and run.phase != RunManager.Phase.FINISHED: return false
	SpecialJobs.make_pending(store.data, location)
	store.save_progress()
	return true


func load_preferences() -> void:
	var config = ConfigFile.new()
	if config.load(store.path + ".settings.cfg") == OK:
		sound_muted = bool(config.get_value("audio","muted",false))
		sfx_volume = clampf(float(config.get_value("audio","sfx_volume",1.0)), 0, 1)
		haptics_enabled = bool(config.get_value("feedback","haptics",true))
		camera_effects_enabled = bool(config.get_value("feedback","camera_effects",true))
	AudioServer.set_bus_mute(0,sound_muted)
	sound.set_sfx_volume(sfx_volume)
	haptics.set_enabled(haptics_enabled)

func save_preferences() -> void:
	var config = ConfigFile.new()
	config.set_value("audio","muted",sound_muted)
	config.set_value("audio","sfx_volume",sfx_volume)
	config.set_value("feedback","haptics",haptics_enabled)
	config.set_value("feedback","camera_effects",camera_effects_enabled)
	var error := config.save(store.path + ".settings.cfg")
	if error != OK: store.last_error = "Could not save preferences: " + error_string(error)

func open_menu(destination: String) -> void:
	if destination == "collection": destination = "garage"
	if destination != "shop": guided_upgrade_active = false
	if destination == "duplication" and not store.data.duplication.unlocked: return
	ui.page_motion_requested = destination != screen
	if is_instance_valid(run) and run.started and run.phase != RunManager.Phase.FINISHED:
		run.abandon()
	cleanup_run()
	screen = destination
	if destination in ["cosmetics", "vehicle"]: shop_day_seen = PlayRewards.shop_day()
	match destination:
		"home": ui.home(store)
		"garage": ui.garage_page(store)
		"locations": ui.locations(store)
		"shop": ui.shop_page(store)
		"cosmetics": ui.cosmetics_page(store)
		"vehicle": ui.vehicle_page(store)
		"collection": ui.collection(store)
		"trophies": ui.trophy_shelf(store)
		"duplication": ui.duplication_lab(store)
		"stats": ui.stats_page(store)
		"settings": ui.settings_page(store,sound_muted,sfx_volume,haptics_enabled,camera_effects_enabled)
		"daily_wheel": ui.daily_wheel_page(store)
		"lucky_shop": ui.lucky_shop_page(store)
	if destination == "home": present_pending_gift()

