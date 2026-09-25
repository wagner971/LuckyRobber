extends SceneTree
func _initialize() -> void: call_deferred("capture")
func shot(id: String) -> void:
	for i in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/card_v2_"+id+".png")
func capture() -> void:
	LocalLog.enabled=false
	root.size=Vector2i(450,800)
	var ui:=GameUI.new()
	root.add_child(ui)
	for id in ["silent","noise","bottomless"]:
		var r:=LuckyReveal.new()
		r.configure(false,{"lucky":id},ui.heavy_font,Vector4.ZERO)
		ui.root.add_child(r)
		r.set_process(false)
		r.elapsed=2.3
		r.update_visual()
		await shot(id)
		r.free()
	for rarity in range(4):
		var r:=GiftReveal.new()
		r.configure(false,{"rarity":rarity},ui.heavy_font,Vector4.ZERO)
		ui.root.add_child(r)
		r.set_process(false)
		r.elapsed=4.5
		r.update_visual()
		await shot("outfit_%d"%rarity)
		r.free()
	root.size=Vector2i(360,800)
	var r:=LuckyReveal.new()
	r.configure(false,{"lucky":"slippery"},ui.heavy_font,Vector4(0,32,0,24))
	ui.root.add_child(r)
	r.set_process(false)
	r.elapsed=2.3
	r.update_visual()
	await shot("narrow")
	ui.free()
	quit()
