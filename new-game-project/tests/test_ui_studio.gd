extends "res://tests/capture_ui_studio_extended.gd"

var checks := 0
var failures := 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS: " if ok else "FAIL: ") + message)

func settle() -> void:
	for i in range(5): await process_frame

func inside_safe(control: Control) -> bool:
	var bounds = control.get_global_rect()
	var insets = game.ui.safe_insets
	return bounds.position.x >= insets.x - 1 and bounds.end.x <= game.ui.root.size.x - insets.z + 1 and bounds.position.y >= insets.y - 1 and bounds.end.y <= game.ui.root.size.y - insets.w - GameUI.PAGE_GUTTER + 1

func capture() -> void:
	LocalLog.enabled = false
	for dimensions in [Vector2i(360,640), Vector2i(360,720), Vector2i(320,712)]:
		root.size = dimensions
		game = load("res://scenes/main.tscn").instantiate()
		game.store = SaveStore.new("res://tests/ui_studio_regression.json")
		game.store.session_only = true
		game.store.data.tutorial_completed = true
		game.store.data.noise_tutorial_completed = true
		game.store.data.successes = 5
		game.store.data.first_job_at = 1
		game.store.data.heist_briefing_seen = true
		game.store.data.wallet = 1234567
		game.store.data.apartment_final_job_completed = true
		game.store.data.museum_final_job_completed = true
		game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
		for location in Balance.LOCATION_ORDER:
			game.store.data.objectives[location] = {"cash":true,"signature":true,"full_clear":true}
		root.add_child(game)
		game.ui.set_safe_area_override(Vector4(0,72,0,54))
		for location in ["apartment", "museum"]:
			SpecialJobs.make_pending(game.store.data, location)
			# Force the offer to this location to cover the maximum-action combination.
			game.store.data.special_location_id = location
			game.store.data.special_pending = true
			game.ui.jobs_index = Balance.LOCATION_ORDER.find(location)
			game.action("locations")
			await settle()
			check(inside_safe(find_button(game.ui.menu, "PLAY  ▶")) and inside_safe(find_button(game.ui.menu, "COLLECTION")), "Jobs controls fit safe portrait with three secondary actions: %s %s" % [location, dimensions])
		for state in ["success", "failure", "dense", "final"]:
			var result = outcome()
			if state == "failure": result.success = false; result.lost = 2350
			if state == "dense":
				result.full_clear = true
				result.new_trophies = ["QUANTUM CORE"]
				result.unlocked_locations = ["museum"]
				result.special_unlocked = true
				result.earned = 1234567
			if state == "final":
				result.final_job_completed = true
				result.mode = "FINAL_JOB"
				result.new_trophies = ["QUANTUM CORE"]
			game.ui.results(result, game.store, "museum" if state == "final" else "apartment")
			await settle()
			var primary = find_button(game.ui.menu, "NEXT JOB  ▶" if state == "final" else ("RETRY" if state == "failure" else "PLAY AGAIN"))
			check(primary != null and inside_safe(primary) and inside_safe(find_button(game.ui.menu, "COLLECTION")), "Results and navigation stay in safe area: %s %s" % [state, dimensions])
			if state == "final":
				primary.pressed.emit()
				check(game.screen == "locations" and game.ui.jobs_index == Balance.LOCATION_ORDER.find("pyramid"), "Museum completion action selects the newly unlocked chapter")
		game.action("collection")
		await settle()
		var hint = find_label(game.ui.menu, "Escape with rare loot")
		check(hint != null and hint.size.y < 50 and inside_safe(hint), "Collection completion caption never wraps vertically")
		game.start_run("apartment")
		game.run.set_physics_process(false)
		game.action("pause")
		await settle()
		find_button(game.ui.modal, "ABANDON RUN").pressed.emit()
		check(game.run.phase != RunManager.Phase.FINISHED and find_button(game.ui.modal, "LEAVE & LOSE LOOT") != null, "Abandon requires explicit loss confirmation")
		find_button(game.ui.modal, "KEEP PLAYING").pressed.emit()
		check(game.screen == "run" and not is_instance_valid(game.ui.modal), "Keep Playing resumes without losing the run")
		game.action("pause")
		find_button(game.ui.modal, "ABANDON RUN").pressed.emit()
		find_button(game.ui.modal, "LEAVE & LOSE LOOT").pressed.emit()
		check(game.screen == "results" and game.last_result.abandoned, "Confirmed abandon reaches honest run-ended results")
		check(game.ui.loot_caption.text == "ESCAPE TO BANK", "HUD describes current automatic banking flow")
		game.free()
		await process_frame
	print("STUDIO UI: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func find_label(node: Node, caption: String) -> Label:
	if node is Label and node.text == caption: return node
	for child in node.get_children():
		var found = find_label(child, caption)
		if found != null: return found
	return null
