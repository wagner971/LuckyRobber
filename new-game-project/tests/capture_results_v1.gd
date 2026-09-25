extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func sample(overrides: Dictionary) -> Dictionary:
	var result = {
		"success": true, "mode": "normal", "earned": 1240, "loot_value": 1240,
		"rush_bonus": 0, "lost": 0, "items": 6, "lost_items": 0,
		"loot_types": ["small_tv", "chair", "rubber_duck"],
		"elapsed": 42.0, "full_clear": false, "abandoned": false,
		"alarm_triggered": false, "final_job_completed": false,
		"unlocked_locations": [], "special_unlocked": false, "contract_met": false,
		"new_trophies": [], "new_objectives": [], "new_cosmetics": []
	}
	result.merge(overrides, true)
	return result

func shot(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/results_" + name + ".png")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(720, 1280)
	var main = load("res://scenes/main.tscn").instantiate()
	main.store = SaveStore.new("res://tests/results_visual_profile.json")
	main.store.data.tutorial_completed = true
	main.store.data.noise_tutorial_completed = true
	root.add_child(main)
	main.store.data.wallet = 4820
	main.ui.results(sample({}), main.store, "apartment")
	await create_timer(1.0).timeout
	await shot("escaped")
	main.ui.results(sample({"success": false, "earned": 0, "lost": 2350, "items": 7, "lost_items": 8, "alarm_triggered": true}), main.store, "apartment")
	await create_timer(1.0).timeout
	await shot("busted")
	main.ui.results(sample({"earned": 4600, "full_clear": true, "items": 9}), main.store, "apartment")
	await create_timer(1.0).timeout
	await shot("full_clear")
	main.store.data.objectives.apartment = {"cash": true, "signature": true, "full_clear": true}
	main.store.data.apartment_final_job_completed = true
	main.store.data.unlocked.append("house")
	main.ui.results(sample({"mode": "FINAL_JOB", "earned": 1210, "items": 9, "full_clear": true, "final_job_completed": true, "unlocked_locations": ["house"]}), main.store, "apartment")
	await create_timer(1.0).timeout
	await shot("final_job")
	main.store.data.trophies.append("flamingo")
	main.ui.results(sample({"new_trophies": ["PINK FLAMINGO"], "loot_types": ["pink_flamingo", "chair"]}), main.store, "apartment")
	await create_timer(1.0).timeout
	await shot("trophy")
	root.size = Vector2i(450, 800)
	main.ui.results(sample({"new_trophies": ["PINK FLAMINGO"], "loot_types": ["pink_flamingo", "chair"]}), main.store, "apartment")
	await create_timer(1.0).timeout
	await shot("trophy_mobile")
	root.size = Vector2i(360,800)
	main.ui.set_safe_area_override(Vector4(0,52,0,36))
	main.store.data.wallet = 2345678
	main.store.data.diamonds = 1250
	main.ui.results(sample({"earned":1234567,"unlocked_locations":["electronics"]}),main.store,"electronics")
	await create_timer(1.0).timeout
	await shot("narrow_safe")
	main.ui.results(sample({"success":false,"earned":0,"lost":2350}),main.store,"apartment")
	await create_timer(1.0).timeout
	await shot("busted_narrow_safe")
	main.free()
	print("RESULTS CAPTURE COMPLETE")
	quit()
