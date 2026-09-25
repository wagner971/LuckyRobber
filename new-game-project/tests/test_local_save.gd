extends SceneTree

func _initialize() -> void:
	var store = SaveStore.new("user://qa_roundtrip.json")
	store.data.wallet = 420
	assert(store.save_progress(), "user:// write must succeed")
	var readback = SaveStore.new(store.path)
	readback.load_progress()
	assert(readback.data.wallet == 420, "user:// read must roundtrip")
	print("PASS: actual user:// save roundtrip at ", ProjectSettings.globalize_path(store.path))
	quit(0)
