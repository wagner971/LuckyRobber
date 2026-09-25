class_name ScreenMotion
extends CanvasLayer

# Retain the outgoing UI for a few frames instead of reading the screen back
# from the GPU. Old 3D previews keep their last frame and stop rendering.
var outgoing: Control
var page_tween: Tween
var curtain: ColorRect
var travelling := false
var page_generation := 0

func _ready() -> void:
	layer = 90
	curtain = ColorRect.new()
	curtain.color = Color("1c072b")
	curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(curtain)
	curtain.hide()

func _input(_event: InputEvent) -> void:
	if travelling or is_instance_valid(outgoing) or (page_tween != null and page_tween.is_valid() and page_tween.is_running()):
		get_viewport().set_input_as_handled()

func discard_page() -> void:
	page_generation += 1
	if page_tween != null and page_tween.is_valid(): page_tween.kill()
	if is_instance_valid(outgoing):
		outgoing.hide()
		outgoing.queue_free()
	outgoing = null

func retain(page: Control) -> void:
	discard_page()
	outgoing = page
	page.reparent(self, false)
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.process_mode = Node.PROCESS_MODE_DISABLED
	ignore_pointer(page)
	freeze_viewports(page)

func ignore_pointer(node: Node) -> void:
	if node is Control: node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children(): ignore_pointer(child)

func freeze_viewports(node: Node) -> void:
	if node is SubViewport: node.render_target_update_mode = SubViewport.UPDATE_DISABLED
	for child in node.get_children(): freeze_viewports(child)

func reveal(page: Control) -> void:
	var generation := page_generation
	# Containers and embedded 3D previews must have a valid size before blending.
	await get_tree().process_frame
	await get_tree().process_frame
	if generation != page_generation or not is_instance_valid(page) or page.is_queued_for_deletion(): return
	page_tween = create_tween().set_parallel(true)
	if is_instance_valid(outgoing):
		page_tween.tween_property(outgoing, "modulate:a", 0.0, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	else:
		page.modulate.a = 0.0
		page_tween.tween_property(page, "modulate:a", 1.0, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	page_tween.chain().tween_callback(func():
		if generation == page_generation:
			if is_instance_valid(outgoing): outgoing.queue_free()
			outgoing = null
	)

func travel(change_scene: Callable, ready_to_play: Callable) -> void:
	if travelling: return
	travelling = true
	discard_page()
	curtain.modulate.a = 0.0
	curtain.show()
	var fade := create_tween()
	fade.tween_property(curtain, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_SINE)
	await fade.finished
	change_scene.call()
	await get_tree().process_frame
	await get_tree().process_frame
	fade = create_tween()
	fade.tween_property(curtain, "modulate:a", 0.0, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await fade.finished
	curtain.hide()
	travelling = false
	ready_to_play.call()
