extends SceneTree

func _initialize() -> void:
	call_deferred("test")

func test() -> void:
	LocalLog.enabled = false
	var world = HeistLevel.new()
	root.add_child(world)
	world.setup("apartment", 1, true)
	var store = SaveStore.new("res://tests/loop_test.json")
	var run = RunManager.new()
	root.add_child(run)
	run.setup(world, store, "apartment")
	run.set_physics_process(false)
	world.player.set_physics_process(false)
	await physics_frame
	await physics_frame
	run.intention = Vector2.LEFT
	run._physics_process(0.1)
	run.intention = Vector2.ZERO
	world.player.position = world.items[0].position + Vector3(0, 0, 0.65)
	for i in range(60): run._physics_process(1.0 / 60)
	assert(run.carried == world.items[0], "TV should be visibly carried")
	assert(run.carried.get_parent() == world.player.carry_anchor)
	world.player.position = world.van.load_position
	for i in range(25): run._physics_process(1.0 / 60)
	assert(run.carried == null and run.cargo.size() == 1)
	assert(run.cargo_value == 140 and store.data.wallet == 0)
	assert(run.phase == RunManager.Phase.ACTIVE, "Loading must not escape")
	run.escape()
	assert(store.data.wallet == 390, "Clear bonus and TV value bank together")
	run.escape()
	assert(store.data.wallet == 390, "Escape cannot pay the TV twice")
	print("PASS: TV pickup -> visible carry -> van load -> immediate banking")
	quit(0)
