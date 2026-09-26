extends "res://tests/route_harness.gd"

func _initialize() -> void: call_deferred("test")

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 8
	Engine.physics_ticks_per_second = 480
	Engine.max_physics_steps_per_frame = 64
	var profile = SaveStore.new("res://tests/laboratory_polish_profile.json")
	profile.session_only = true
	profile.data.upgrades = {"strength":Balance.max_level("strength"),"grip":18,"carry":18,"capacity":18,"noise":18}
	await new_session("laboratory","normal",profile)
	check(not world.valid_drop(Vector3(-5,0,0.47),0.1) and not world.valid_drop(Vector3(5,0,0.47),0.1),"Both analysis benches have solid drop footprints")
	check(world.items[0].position.y > 0.7 and world.items[1].position.y > 0.7 and world.items[0].model.position.y == 0,"Small instruments are supported at bench height without a carry offset")
	var solved = await drive_indices([0,1,2,3,4,5,6,7,8],"laboratory_polish_local_tier")
	check(solved and run.result.full_clear and run.cargo_value == 7250 and run.cargo_used == 39,"Laboratory-tier upgrades can retrieve all nine instruments and escape")
	check(store.data.duplication.unlocked,"Completing the redesigned Laboratory still unlocks duplication")
	check(store.data.duplication.known.size() == 9 and not store.data.duplication.has("charges"),"The actual full Laboratory escape records all nine reusable blueprints without scans")
	check(store.data.wallet == run.result.earned and int(run.result.loot_value) == 7250,"Original heist loot still pays full value immediately, separately from replicas")
	print("LABORATORY POLISH: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
