extends SceneTree

func _initialize() -> void: call_deferred("capture")

func shot(id: String) -> void:
	for i in range(10): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/garage_"+id+".png")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var store := SaveStore.new()
	store.session_only = true
	store.data.wallet = 200000
	var ui := GameUI.new()
	root.add_child(ui)
	ui.home(store)
	await shot("home_starter")
	ui.garage_page(store)
	await shot("shop")
	store.data.garage_owned = GarageDecor.CATALOG.keys()
	ui.home(store)
	await shot("home_furnished")
	root.size = Vector2i(360,800)
	ui.garage_page(store)
	await shot("shop_narrow")
	root.size = Vector2i(450,1000)
	ui.home(store)
	await shot("home_tall")
	ui.free()
	quit()
