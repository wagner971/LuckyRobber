extends SceneTree
var checks := 0
var failures := 0
var started := []
var actions := []
func _initialize() -> void: call_deferred("test")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS: " if ok else "FAIL: ")+message)
func sample(overrides: Dictionary = {}) -> Dictionary:
	var r := {"success":true,"earned":1240,"lost":0,"items":6,"elapsed":42.0,"mode":"normal","loot_types":["small_tv","chair"],"full_clear":false,"new_trophies":[],"new_rare_loot":[],"unlocked_locations":[]}
	r.merge(overrides,true)
	return r
func test() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/results_v2_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.wallet = 4820
	game.store.data.diamonds = 7
	root.add_child(game)
	var ui: GameUI = game.ui
	for connection in ui.start_requested.get_connections(): ui.start_requested.disconnect(connection.callable)
	for connection in ui.action_requested.get_connections(): ui.action_requested.disconnect(connection.callable)
	ui.start_requested.connect(func(location: String,mode: String): started.append([location,mode]))
	ui.action_requested.connect(func(action: String): actions.append(action))
	for scenario in [sample(),sample({"success":false,"earned":0,"lost":2350,"alarm_triggered":true}),sample({"mode":SpecialJobs.MODE}),sample({"mode":"FINAL_JOB","final_job_completed":true,"unlocked_locations":["house"]})]:
		ui.results(scenario,game.store,"apartment")
		await create_timer(0.95).timeout
		var view: ResultPresentation = ui.menu.find_child("ResultPresentation",true,false)
		check(view != null,"Results creates its art view")
		check(view.replay.text == ("PLAY AGAIN" if scenario.success else "RETRY"),"Replay is the main action")
		check(view.home.text == "RETURN TO HOMESCREEN","Home is the only secondary action")
		check(view.wallet.text == "$4,820" and view.diamonds.text == "7","Wallet finishes at actual persisted balance")
		check(view.amount.text == ("+$1,240" if scenario.success else "$2,350"),"Correct reward or loss count-up")
		check(game.store.data.wallet == 4820 and game.store.data.diamonds == 7,"Presentation never credits or deducts money")
		var replay_fill: ColorRect = view.replay.get_child(1)
		var home_fill: ColorRect = view.home.get_child(1)
		check(replay_fill.material.get_shader_parameter("top_color") == Color("fff04f"),"Replay/retry is yellow")
		check(home_fill.material.get_shader_parameter("top_color") == Color("63ffdb"),"Home is mint")
		view.replay.pressed.emit()
		check(started.back()==["apartment","normal"],"Replay stays at this location, completed final/special return to normal")
		view.home.pressed.emit()
		check(actions.back()=="home","Home action wired")
		view.notice.pressed.emit()
		check(is_instance_valid(ui.modal),"Secondary reward details are accessible")
		ui.close_pause()
		await process_frame
	for dimensions in [Vector2i(450,800),Vector2i(360,800),Vector2i(320,712),Vector2i(720,1100)]:
		root.size = dimensions
		ui.set_safe_area_override(Vector4(0,52,0,36))
		ui.results(sample({"earned":1234567}),game.store,"electronics")
		await create_timer(0.7).timeout
		var view: ResultPresentation = ui.menu.find_child("ResultPresentation",true,false)
		for control in [view.replay,view.home,view.notice,view.wallet,view.amount]:
			var r: Rect2 = control.get_global_rect()
			check(r.position.x >= ui.safe_insets.x and r.end.x <= ui.root.size.x-ui.safe_insets.z+1 and r.position.y >= ui.safe_insets.y and r.end.y <= ui.root.size.y-ui.safe_insets.w+1,"Safe area contains control at %s" % dimensions)
		check(view.amount.size.x <= 842,"Seven-digit reward fits the money field")
	ui.tutorial_results({"success":true,"tutorial":true,"replay":false,"earned":640,"wallet_before":4180,"saved":true},game.store)
	await process_frame
	var tutorial: ResultPresentation = ui.menu.find_child("ResultPresentation",true,false)
	check(tutorial.replay.text=="CHOOSE A JOB","Tutorial opens Jobs rather than forcing another run")
	tutorial.replay.pressed.emit()
	check(actions.back()=="tutorial_continue","Tutorial continue preserved")
	ui.tutorial_results({"success":false,"tutorial":true,"replay":true,"earned":0,"wallet_before":4820},game.store)
	await process_frame
	tutorial = ui.menu.find_child("ResultPresentation",true,false)
	tutorial.replay.pressed.emit()
	check(actions.back()=="retry_tutorial","Tutorial retry preserved")
	tutorial.home.pressed.emit()
	check(actions.back()=="home","Tutorial can leave to Home")
	ui.results(sample(),game.store,"apartment")
	await process_frame
	var motion: ResultPresentation = ui.menu.find_child("ResultPresentation",true,false)
	motion.set_process(false)
	motion.animate_at(0.0)
	var entrance := motion.reward_title.scale.x
	motion.animate_at(0.42)
	check(motion.reward_title.scale.x > entrance and motion.reward_title.scale.x > 1.0,"ESCAPED enters with a real overshooting scale animation")
	motion.animate_at(0.58)
	check(absf(motion.reward_title.scale.x-1.0)<0.001,"Title settles at its intended framing")
	motion.animate_at(1.195)
	var large_cash := motion.reward_cash.scale.x
	motion.animate_at(2.145)
	check(large_cash-motion.reward_cash.scale.x > 0.12,"Cash repeatedly shifts small-big-small")
	motion.animate_at(0.76)
	check(motion.amount.scale.x > 1.10,"Amount pops after the count-up")
	check(motion.reward_cash.animated and motion.reward_cash.viewport.own_world_3d,"Central reward is the animated 3D cash model")
	check(motion.money_rain.particles.size()==22,"Money rain has a bounded mobile-friendly particle count")
	check(motion.money_rain.particle_position(0,0).distance_to(motion.money_rain.particle_position(0,1))>50,"Bills genuinely travel, rather than remaining painted in the backdrop")
	check(motion.money_rain.mouse_filter==Control.MOUSE_FILTER_IGNORE and motion.reward_title.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Animated decoration cannot intercept menu taps")
	var old_motion: WeakRef = weakref(motion)
	ui.results(sample({"success":false,"earned":0,"lost":100}),game.store,"apartment")
	await process_frame
	await process_frame
	check(old_motion.get_ref()==null,"Leaving the success screen releases animation and its 3D viewport")
	var failure: ResultPresentation = ui.menu.find_child("ResultPresentation",true,false)
	check(failure.money_rain==null and failure.reward_cash==null,"Failure never celebrates with falling reward money")
	check(failure.is_processing(),"Failure runs its own animation")
	failure.set_process(false)
	failure.animate_at(0.0)
	var stamp_start := failure.failure_title.scale.x
	failure.animate_at(0.48)
	check(stamp_start>1.2 and absf(failure.failure_title.scale.x-1.0)<0.001,"BUSTED stamps in and settles")
	failure.animate_at(0.3)
	check(absf(failure.failure_title.position.x-80.0)>0.1,"Failure title gets a brief impact shake")
	failure.animate_at(0.8)
	check(absf(failure.failure_title.position.x-80.0)<0.001,"Shake stops rather than distracting indefinitely")
	failure.animate_at(1.275)
	var big_emblem := failure.failure_emblem.scale.x
	failure.animate_at(2.425)
	check(big_emblem-failure.failure_emblem.scale.x>0.10,"Failure emblem loops small-big-small")
	failure.animate_at(0.76)
	check(failure.amount.scale.x>1.08,"Lost amount pops after the count-up")
	check(failure.failure_sparks.amount==12,"Failure particles stay bounded")
	check(failure.failure_title.mouse_filter==Control.MOUSE_FILTER_IGNORE and failure.failure_emblem.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Failure animation cannot intercept Retry or Home")
	failure.hide()
	var paused_time := failure.animation_time
	failure._process(1.0)
	check(failure.animation_time==paused_time,"Hidden failure view stops CPU animation")
	failure.show()
	for dimensions in [Vector2i(320,712),Vector2i(360,800)]:
		root.size = dimensions
		await process_frame
		await process_frame
		for control in [failure.failure_title,failure.failure_emblem,failure.replay,failure.home]:
			var bounds: Rect2 = control.get_global_rect()
			check(bounds.position.x>=ui.safe_insets.x and bounds.end.x<=ui.root.size.x-ui.safe_insets.z+1 and bounds.position.y>=ui.safe_insets.y and bounds.end.y<=ui.root.size.y-ui.safe_insets.w+1,"Failure layout respects safe area at %s" % dimensions)
	var old_failure: WeakRef = weakref(failure)
	ui.results(sample(),game.store,"apartment")
	await process_frame
	await process_frame
	check(old_failure.get_ref()==null,"Leaving failure releases particles and animation")
	game.free()
	await process_frame
	print("RESULTS V2: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
