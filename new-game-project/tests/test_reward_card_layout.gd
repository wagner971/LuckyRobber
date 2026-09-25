extends SceneTree
var checks:=0
var failures:=0
func _initialize() -> void: call_deferred("run_test")
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok:
		failures+=1
		print("FAIL: "+label)
func run_test() -> void:
	LocalLog.enabled=false
	var ui:=GameUI.new()
	root.add_child(ui)
	for screen in [Vector2i(360,640),Vector2i(360,800),Vector2i(450,800)]:
		root.size=screen
		await process_frame
		for id in LuckyEffects.CATALOG:
			var r:=LuckyReveal.new()
			r.configure(false,{"lucky":id},ui.heavy_font,Vector4(0,32,0,24))
			ui.root.add_child(r)
			r.set_process(false)
			r.elapsed=2.3
			r.update_visual()
			await process_frame
			check(r.card.encloses(r.claim.get_rect()),"Claim inside card "+id)
			check(r.description.position.y+r.description.size.y < r.card.position.y+r.card.size.y*0.79,"Description clears footer "+id)
			check(r.card.position.y>=32 and r.card.end.y<=r.size.y-24,"Safe area "+id)
			r.free()
	ui.free()
	print("REWARD CARD LAYOUT SUMMARY: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
