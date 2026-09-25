extends SceneTree

func _initialize() -> void:
	call_deferred("test")

func test() -> void:
	LocalLog.enabled = false
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	var fresh_starts_playing: bool = game.screen == "run" and is_instance_valid(game.run) and game.level.training_layout and game.run.onboarding != null
	if not fresh_starts_playing:
		printerr("FAIL: New launch must start in the practice garage")
		quit(1)
		return
	print("PASS: New launch enters the practice garage before Home")
	game.free()
	quit()
