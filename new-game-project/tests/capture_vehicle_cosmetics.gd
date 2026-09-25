extends SceneTree

func _initialize() -> void: call_deferred("capture")

func shot(label: String) -> void:
	for i in range(8): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/vehicle_" + label + ".png")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var store := SaveStore.new()
	store.session_only = true
	store.data.wallet = 200000
	var ui := GameUI.new()
	root.add_child(ui)
	ui.cosmetics_page(store)
	await shot("daily")
	ui.selected_vehicle = "vehicle_pickup"
	ui.vehicle_page(store)
	await shot("pickup")
	root.size = Vector2i(360,800)
	ui.selected_vehicle = "vehicle_luxury"
	ui.vehicle_page(store)
	await shot("narrow")
	ui.free()
	root.size = Vector2i(1000,1000)
	root.content_scale_size = Vector2i(1000,1000)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(grid)
	for id in Balance.VEHICLE_ORDER:
		var cell := VBoxContainer.new()
		cell.custom_minimum_size = Vector2(490,240)
		grid.add_child(cell)
		var preview := VehiclePreview.new()
		preview.custom_minimum_size = Vector2(490,210)
		cell.add_child(preview)
		preview.setup(Balance.COSMETICS[id].vehicle_style)
		var label := Label.new()
		label.text = Balance.COSMETICS[id].name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.add_child(label)
	await shot("catalog")
	grid.free()
	quit()
