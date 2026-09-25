extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run_test")
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS: " if ok else "FAIL: ")+message)
func run_test() -> void:
	root.size=Vector2i(900,160)
	root.content_scale_size=Vector2i(900,160)
	var chart:=Control.new()
	root.add_child(chart)
	var colors: Array[Color]=[Color(0.98,0.98,0.98),Color(0.5,0.5,0.5),Color(0.025,0.025,0.025),Color(0.3,0.45,0.7),Color(0.7,0.58,0.3),Color(0.7,0.35,0.55),Color(0,1,1),Color(1,0,0),Color(0,0,1)]
	for i in colors.size():
		var patch:=ColorRect.new()
		patch.color=colors[i]
		patch.position=Vector2(i*100,0)
		patch.size=Vector2(100,160)
		chart.add_child(patch)
	await process_frame
	await RenderingServer.frame_post_draw
	var before:=root.get_texture().get_image()
	var grade:=ColorRect.new()
	grade.size=Vector2(900,160)
	var mat:=ShaderMaterial.new()
	mat.shader=preload("res://assets/shaders/vivid_world.gdshader")
	grade.material=mat
	chart.add_child(grade)
	var hud:=ColorRect.new()
	hud.color=Color(0.4,0.5,0.6)
	hud.size=Vector2(900,20)
	chart.add_child(hud)
	await process_frame
	await RenderingServer.frame_post_draw
	var after:=root.get_texture().get_image()
	for i in 9:
		var a:=before.get_pixel(i*100+50,80)
		var b:=after.get_pixel(i*100+50,80)
		if i<3: check(absf(a.r-b.r)<0.008 and absf(b.r-b.g)<0.008 and absf(b.g-b.b)<0.008,"Neutral white/gray/black retained in rendered color pass")
		elif i>=6: check(absf(a.r-b.r)<0.008 and absf(a.g-b.g)<0.008 and absf(a.b-b.b)<0.008,"Fully saturated colors remain intact without invalid pixels")
		else:
			check(b.s>a.s+0.12,"Colored scene swatch gains visible saturation")
			check(absf(b.v-a.v)<0.008,"Color boost does not burn highlights")
	var untouched:=after.get_pixel(50,10)
	check(absf(untouched.r-hud.color.r)<0.008 and absf(untouched.g-hud.color.g)<0.008,"HUD drawn after the grade retains its own colors")
	chart.free()
	LocalLog.enabled=false
	root.size=Vector2i(450,800)
	root.content_scale_size=Vector2i(720,1280)
	var game=load("res://scenes/main.tscn").instantiate()
	game.store=SaveStore.new()
	game.store.session_only=true
	game.store.data.tutorial_completed=true
	root.add_child(game)
	game.ui.home(game.store)
	await process_frame
	check(not game.ui.world_color_grade.is_visible_in_tree(),"World pass is disabled behind menus and wheel art")
	check(game.ui.world_color_grade.get_index()<game.ui.scene_polish.get_index() and game.ui.world_color_grade.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Color pass precedes atmospheric effects and never intercepts movement")
	for destination in ["home","shop","garage","cosmetics","locations"]:
		game.open_menu(destination)
		await create_timer(0.12).timeout
		check(is_instance_valid(game.ui.menu),"Vivid menu opens: "+destination)
	game.free()
	await process_frame
	print("VIVID COLOR: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
