extends SceneTree
func _initialize() -> void: call_deferred("capture")
func shot(id: String) -> void:
	for i in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/gift_"+id+".png")
func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var ui := GameUI.new()
	root.add_child(ui)
	var reveal := GiftReveal.new()
	reveal.configure(false,{"rarity":2},ui.heavy_font,Vector4.ZERO)
	ui.root.add_child(reveal)
	reveal.set_process(false)
	for entry in [[0.45,"box"],[0.9,"open"],[2.0,"cycling"],[4.35,"rare"]]:
		reveal.elapsed = entry[0]
		reveal.update_visual()
		await shot(entry[1])
	root.size = Vector2i(360,800)
	reveal.rarity = 3
	reveal.elapsed = 4.7
	reveal.update_visual()
	await shot("legendary_narrow")
	reveal.free()
	reveal = GiftReveal.new()
	reveal.configure(true,{"cash":300,"diamonds":2},ui.heavy_font,Vector4(0,35,0,26))
	ui.root.add_child(reveal)
	reveal.set_process(false)
	reveal.elapsed = 1.9
	reveal.update_visual()
	await shot("daily")
	ui.free()
	quit()
