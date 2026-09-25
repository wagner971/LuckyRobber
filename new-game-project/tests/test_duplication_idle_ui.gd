extends SceneTree

var checks := 0
var failures := 0
var game: Node
var captures := false

func _initialize() -> void: call_deferred("test")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS: " if ok else "FAIL: ")+label)

func button_with(label: String, parent: Node = null) -> Button:
	if parent == null: parent = game.ui.menu
	if parent is Button and label in parent.text: return parent
	for child in parent.get_children():
		var found = button_with(label,child)
		if found: return found
	return null

func shot(label: String) -> void:
	for frame in range(6): await process_frame
	if captures:
		await create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/idle_%s_%dx%d.png" % [label,root.size.x,root.size.y])

func test() -> void:
	LocalLog.enabled = false
	captures = OS.get_cmdline_user_args().has("--capture")
	for dimensions in [Vector2i(450,800),Vector2i(320,712)]:
		root.size = dimensions
		game = load("res://scenes/main.tscn").instantiate()
		game.store = SaveStore.new("res://tests/idle_ui_unused.json")
		game.store.session_only = true
		game.store.data.tutorial_completed = true
		game.store.data.noise_tutorial_completed = true
		game.store.data.successes = 4
		game.store.data.first_job_at = 1
		game.store.data.wallet = 10000
		root.add_child(game)
		game.action("duplication")
		check(game.screen != "duplication","Locked Laboratory is inaccessible")
		Duplication.register_heist(game.store.data,"laboratory",["lab_quantum_core","lab_microscope","fridge"])
		game.ui.set_safe_area_override(Vector4(0,56,0,40))
		game.action("duplication")
		await shot("empty")
		check(game.screen == "duplication" and button_with("START AUTO") != null,"Unlocked lab opens with an automatic-production action")
		button_with("START AUTO").pressed.emit()
		check(game.store.data.duplication.jobs[0].type_id == "lab_quantum_core","Actual UI starts the selected highest-yield blueprint")
		await shot("running")
		check(button_with("COPYING") != null and button_with("COPYING").disabled,"No premature collect action")
		var now = int(Time.get_unix_time_from_system())
		game.store.data.duplication.jobs[0].last_at = now-102
		game.ui.update_duplication_timers(game.store)
		await shot("full")
		var collect = button_with("COLLECT $522")
		check(collect != null and not collect.disabled,"Offline copies become collectible through the live UI")
		var wallet = game.store.data.wallet
		if collect: collect.pressed.emit()
		check(game.store.data.wallet == wallet+522 and not game.store.data.duplication.jobs[0].is_empty(),"Collect pays exactly once and keeps automatic production active")
		game.action("duplication_claim:0")
		check(game.store.data.wallet == wallet+522,"Repeated UI action cannot duplicate the payout")
		button_with("ADD CHAMBER").pressed.emit()
		button_with("ADD CHAMBER").pressed.emit()
		check(game.store.data.duplication.slot_level == 3 and game.store.data.wallet == wallet+522-3600,"UI upgrades purchase the two additional chambers at advertised prices")
		game.action("duplicate:1:lab_quantum_core")
		game.action("duplicate:2:lab_microscope")
		await shot("three_chambers")
		for control in get_nodes_in_group("duplication_claim_button"):
			if not game.ui.menu.is_ancestor_of(control): continue
			check(control.get_global_rect().end.x <= game.ui.root.size.x-game.ui.safe_insets.z+1,"Chamber claim button fits narrow safe width")
		game.action("home")
		var paused_wallet = game.store.data.wallet
		game.action("duplication_claim:0")
		check(game.store.data.wallet == paused_wallet,"Claim action is rejected outside the lab screen")
		game.free()
		await process_frame
	print("IDLE UI: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
