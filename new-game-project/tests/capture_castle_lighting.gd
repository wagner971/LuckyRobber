extends SceneTree

# Same gameplay camera for every shot. Usage: --script res://tests/capture_castle_lighting.gd -- --prefix=before
# Writes tests/castle_lighting_<prefix>.png, _alarm.png and room crops at 2x resolution.
const CROPS = {"throne": Rect2i(60, 420, 780, 250), "treasury": Rect2i(60, 640, 300, 300), "crypt": Rect2i(540, 640, 300, 300), "exterior": Rect2i(0, 860, 900, 460)}

func _initialize() -> void: call_deferred("capture")

func frame() -> Image:
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()

func capture() -> void:
	var prefix = "after"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--prefix="): prefix = arg.substr(9)
	LocalLog.enabled = false
	root.size = Vector2i(900, 1600)
	var main = load("res://scenes/main.tscn").instantiate()
	main.store = SaveStore.new("res://tests/visual_castle_lighting_profile.json")
	main.store.data.upgrades = {"strength": 5, "grip": 20, "carry": 20, "capacity": 19, "noise": 1}
	main.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	root.add_child(main)
	main.start_run("castle")
	main.run.set_physics_process(false)
	var image: Image = await frame()
	image.save_png("res://tests/castle_lighting_%s.png" % prefix)
	for key in CROPS: image.get_region(CROPS[key]).save_png("res://tests/castle_lighting_%s_%s.png" % [prefix, key])
	# Alarm state: same HUD path as a real trigger, no gameplay values persisted.
	main.run.phase = RunManager.Phase.ACTIVE
	main.run.alarm_active = true
	main.run.remaining = 12.0
	main.run.feedback.emit("alarm", "ALARM! GET OUT!")
	var alarm: Image = await frame()
	alarm.save_png("res://tests/castle_lighting_%s_alarm.png" % prefix)
	main.action("abandon")
	print("CASTLE LIGHTING CAPTURE COMPLETE " + prefix)
	quit()
