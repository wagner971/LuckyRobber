extends SceneTree
var checks:=0
var failures:=0
func _initialize() -> void: call_deferred("run_test")
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok:
		failures+=1
		print("FAIL: "+label)
func find_icon_button(node: Node, label: String) -> Button:
	if node is Button and node.tooltip_text==label: return node
	for child in node.get_children():
		var found:=find_icon_button(child,label)
		if found!=null: return found
	return null
func settle() -> void:
	for i in range(6): await process_frame
func run_test() -> void:
	LocalLog.enabled=false
	var game=load("res://scenes/main.tscn").instantiate()
	game.store=SaveStore.new()
	game.store.session_only=true
	game.store.data.tutorial_completed=true
	game.store.data.heist_briefing_seen=true
	game.store.data.wallet=6100
	root.add_child(game)
	for dimensions in [Vector2i(360,640),Vector2i(360,800),Vector2i(450,800)]:
		root.size=dimensions
		game.ui.set_safe_area_override(Vector4(0,48,0,32))
		for entry in [["UPGRADES","shop"],["GARAGE","garage"],["LOCKER","cosmetics"]]:
			game.open_menu("home")
			await settle()
			var b:=find_icon_button(game.ui.menu,entry[0])
			check(b!=null and b.text=="" and b.accessibility_name==entry[0],"Home icon-only accessible "+entry[0])
			check(b.get_global_rect().end.y<=game.ui.root.size.y-32,"Home shortcuts above safe bottom")
			b.pressed.emit()
			check(game.screen==entry[1],"Home shortcut navigates "+entry[1])
		for entry in [["HOME","home"],["JOBS","locations"],["UPGRADES","shop"],["GARAGE","garage"]]:
			game.open_menu("locations")
			await settle()
			var b:=find_icon_button(game.ui.menu,entry[0])
			check(b!=null and b.text=="" and b.accessibility_name==entry[0],"Nav icon-only accessible "+entry[0])
			check(b.get_global_rect().end.y<=game.ui.root.size.y-32,"Nav above safe bottom")
			b.pressed.emit()
			check(game.screen==entry[1],"Nav navigates "+entry[1])
		game.open_menu("home")
		await settle()
		check(game.ui.menu.find_child("HomeLogo",true,false)!=null,"Supplied title present")
		if dimensions==Vector2i(360,800):
			await create_timer(0.65).timeout
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://tests/violet_home_narrow.png")
		game.open_menu("locations")
		await settle()
		if dimensions==Vector2i(360,800):
			await create_timer(0.65).timeout
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://tests/violet_jobs_narrow.png")
	game.free()
	await settle()
	print("VIOLET NAVIGATION SUMMARY: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
