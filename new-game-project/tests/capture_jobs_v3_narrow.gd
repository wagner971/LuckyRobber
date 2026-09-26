extends SceneTree

# QA: the Jobs page on a short 450x800 phone and with the Museum Final Job ready.
func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/jobs_v3_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.first_job_at = 1
	game.store.data.wallet = 12640
	game.store.data.diamonds = 19
	game.store.data.unlocked = Balance.LOCATION_ORDER.slice(0, 7)
	for key in Balance.UPGRADE_KEYS: game.store.data.upgrades[key] = Balance.required_level(key, "museum")
	game.store.data.objectives.museum.cash = true
	game.store.data.objectives.museum.signature = true
	game.store.data.objectives.apartment.cash = true
	game.store.data.objectives.apartment.signature = true
	game.store.data.objectives.apartment.full_clear = true
	game.store.data.apartment_final_job_completed = true
	Progression.refresh(game.store.data)
	root.add_child(game)
	game.ui.set_safe_area_override(Vector4(0, 40, 0, 30))
	game.ui.jobs_index = 6
	game.action("locations")
	for i in range(6): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/jobs_v3_museum_narrow.png")
	game.ui.jobs_index = 0
	game.action("locations")
	for i in range(6): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/jobs_v3_apartment_narrow.png")
	game.free()
	print("JOBS V3 NARROW CAPTURE COMPLETE")
	quit()
