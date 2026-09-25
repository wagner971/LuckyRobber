extends SceneTree

func _initialize() -> void:
	call_deferred("test")

func test() -> void:
	var failures := 0
	for location in Balance.LOCATION_ORDER:
		var level := HeistLevel.new()
		root.add_child(level)
		level.setup(location, 20)
		var rear := level.van.model.to_global(Vector3(-1.7, 0, 0))
		var cab := level.van.model.to_global(Vector3(1.7, 0, 0))
		var good := rear.z < cab.z and rear.distance_to(level.van.load_position) < cab.distance_to(level.van.load_position) and level.van.in_zone(level.van.load_position)
		if good:
			print("PASS: Van rear faces the %s entrance and load point" % location)
		else:
			printerr("FAIL: Van orientation at %s" % location)
			failures += 1
		level.free()
	print("VAN ORIENTATION: %d locations, %d failures" % [Balance.LOCATION_ORDER.size(), failures])
	quit(1 if failures else 0)
