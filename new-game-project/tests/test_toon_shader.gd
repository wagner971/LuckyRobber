extends SceneTree

var checks := 0
var failures := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1
	print(("PASS: " if value else "FAIL: ") + message)

func _initialize() -> void: call_deferred("test")

func meshes(node: Node, into: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D: into.append(node)
	for child in node.get_children(): meshes(child, into)

func test() -> void:
	LocalLog.enabled = false
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/camera_toon_profile.json")
	game.store.session_only = true
	game.store.data.upgrades = {"strength":Balance.max_level("strength"),"grip":20,"carry":20,"capacity":20,"noise":20}
	root.add_child(game)
	game.set_physics_process(false)
	game.start_run("apartment")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)

	check(game.level.camera.get_node_or_null("CameraToonEffect") == null, "Gameplay camera has no toon post-process")
	check(not ResourceLoader.exists("res://assets/shaders/camera_toon.gdshader"), "Old toon shader is removed from the project")
	check(game.ui.layer >= 0, "HUD remains on its normal UI layer")

	var scene_meshes: Array[MeshInstance3D] = []
	meshes(game.level, scene_meshes)
	check(scene_meshes.size() > 100, "Complete level geometry inspected")
	var custom_toon_count := 0
	for instance in scene_meshes:
		if instance.material_override is ToonMaterial: custom_toon_count += 1
	check(custom_toon_count == 0, "No level mesh has a per-object toon shader")
	var suit = game.level.player.visual.tint_parts[0].material_override
	check(suit is StandardMaterial3D, "Character uses an ordinary surface material")
	var white_stripe = game.level.player.visual.body.get_child(1).material_override
	check(white_stripe.albedo_color == ThiefVisual.WHITE and white_stripe.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED, "White costume bands stay bright under night lighting")
	game.level.player.visual.set_suit_color(Color("945bca"))
	check(suit.albedo_color == Color("945bca"), "Cosmetic recolour still updates the character")
	var zone = game.level.van.zone.material_override
	check(zone is StandardMaterial3D, "Gameplay marker has no custom toon material")
	game.ui.update_run(game.run, 0.0)
	check(zone.albedo_color != Color.TRANSPARENT, "Animated van-zone colour still updates")
	game.free()
	print("NATURAL RENDERING CHECKS %d; FAILURES %d" % [checks, failures])
	quit(1 if failures else 0)
