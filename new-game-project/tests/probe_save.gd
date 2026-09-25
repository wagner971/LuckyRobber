extends SceneTree
func _initialize():
	var save = SaveStore.new("res://tests/probe_save.json")
	save.data.wallet = 250
	save.data.upgrades.strength = 2
	save.save_progress()
	var restored = SaveStore.new(save.path)
	restored.load_progress()
	for key in save.data:
		if save.data[key] != restored.data[key]: print(key, " BEFORE=", save.data[key], " AFTER=", restored.data[key])
	print("ERROR ",restored.last_error)
	quit()
