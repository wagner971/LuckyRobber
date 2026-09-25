extends SceneTree

var game
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("test")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS: " if ok else "FAIL: ") + message)

func button_named(node: Node, value: String) -> Button:
	if node is Button and node.text == value: return node
	for child in node.get_children():
		var found = button_named(child,value)
		if found != null: return found
	return null

func make_game() -> void:
	if is_instance_valid(game):
		game.free()
		await process_frame
	game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/play_museum_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	game.store.data.museum_final_job_completed = true
	for key in Balance.UPGRADE_KEYS: game.store.data.upgrades[key] = Balance.max_level(key)
	root.add_child(game)
	await create_timer(0.35).timeout

func walk_forward(message: String) -> void:
	var start: Vector3 = game.level.player.position
	var origin = root.get_visible_rect().size * Vector2(0.5,0.70)
	var touch = InputEventScreenTouch.new()
	touch.index = 0
	touch.position = origin
	touch.pressed = true
	root.push_input(touch,true)
	var drag = InputEventScreenDrag.new()
	drag.index = 0
	drag.position = origin + Vector2(0,-78)
	drag.relative = Vector2(0,-78)
	root.push_input(drag,true)
	await create_timer(0.40).timeout
	touch.pressed = false
	touch.position = drag.position
	root.push_input(touch,true)
	check(game.level.player.position.distance_to(start) > 0.6, message)
	check(game.run.started and game.run.remaining < game.run.rules.duration, "Movement starts the Museum clock")

func test() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(360,800)
	for state in ["fresh","normal","special","apartment_final","museum_final"]:
		await make_game()
		game.store.data.tutorial_completed = state != "fresh"
		if state == "special": SpecialJobs.make_pending(game.store.data,"museum")
		if state == "apartment_final":
			game.store.data.objectives.apartment.cash = true
			game.store.data.objectives.apartment.signature = true
		if state == "museum_final":
			game.store.data.apartment_final_job_completed = true
			game.store.data.museum_final_job_completed = false
			for location in Balance.LOCATION_ORDER.slice(0,7):
				game.store.data.objectives[location] = {"cash":true,"signature":true,"full_clear":true}
		game.ui.home(game.store)
		button_named(game.ui.menu,"PLAY").pressed.emit()
		await create_timer(0.6).timeout
		check(game.screen == "locations" and not is_instance_valid(game.run), "Home PLAY selects a location, never starts a job: " + state)
	for mode in ["normal","FINAL_JOB"]:
		await make_game()
		game.store.data.objectives.museum.cash = true
		game.store.data.objectives.museum.signature = true
		game.store.data.heist_briefing_seen = false
		game.action("locations")
		game.ui.start_requested.emit("museum",mode)
		await create_timer(0.6).timeout
		if mode == "normal":
			check(game.screen == "heist_briefing" and game.run.phase == RunManager.Phase.PAUSED, "Fresh Museum opens its paused briefing")
			button_named(game.ui.modal,"START HEIST").pressed.emit()
			await create_timer(0.2).timeout
		await walk_forward("Museum moves after UI launch/briefing: " + mode)
	await make_game()
	game.store.data.heist_briefing_seen = true
	game.action("locations")
	game.ui.start_requested.emit("museum","normal")
	await create_timer(0.18).timeout
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await create_timer(0.4).timeout
	check(game.run.phase == RunManager.Phase.PAUSED and not game.ui.input.enabled, "Focus loss during reveal keeps Museum paused")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	button_named(game.ui.modal,"RESUME").pressed.emit()
	await create_timer(0.2).timeout
	await walk_forward("Museum moves after a reveal interrupted by focus loss")
	game.free()
	await process_frame
	print("PLAY / MUSEUM: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
