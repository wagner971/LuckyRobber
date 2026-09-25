class_name ThiefPlayer
extends CharacterBody3D

var visual: ThiefVisual
var carry_anchor: Node3D
var money_magnet_anchor: Node3D
var move_input = Vector2.ZERO
var speed_factor = 1.0
var enabled = true
var run_state: Node

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var collision = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = 0.24
	shape.height = 1.3
	collision.shape = shape
	collision.position.y = 0.65
	add_child(collision)
	visual = Models.thief()
	add_child(visual)
	carry_anchor = visual.carry_anchor
	money_magnet_anchor = Node3D.new()
	money_magnet_anchor.name = "PlayerMoneyMagnetAnchor"
	money_magnet_anchor.position = Vector3(0, 1.0, 0)
	add_child(money_magnet_anchor)

func _physics_process(delta: float) -> void:
	var direction = move_input.limit_length() if enabled else Vector2.ZERO
	if not enabled:
		velocity = Vector3.ZERO
		return
	var desired = Vector3(direction.x, 0, direction.y) * Balance.BASE_SPEED * speed_factor
	var rate = Balance.BASE_SPEED / (Balance.STOP_TIME if direction == Vector2.ZERO else Balance.ACCEL_TIME)
	velocity = velocity.move_toward(desired, rate * delta)
	move_and_slide()
	position.y = 0
	if direction.length() > 0.01:
		visual.rotation.y = atan2(direction.x, direction.y)

func _process(delta: float) -> void:
	if is_instance_valid(run_state):
		visual.paused = run_state.phase in [RunManager.Phase.PAUSED, RunManager.Phase.FINISHED]
		visual.carrying = run_state.carried != null
		visual.heavy = visual.carrying and run_state.carried.data.weight_class in ["HEAVY", "VERY_HEAVY"]
		visual.panic = run_state.alarm_active
		visual.loading = visual.carrying and run_state.carried.state == LootItem.State.LOADING
		# Anticipation occupies the last 0.15s of the existing pickup, never adds time.
		visual.pickup_amount = clampf((run_state.progress - run_state.progress_duration + 0.15) / 0.15, 0, 1) if run_state.target != null else 0.0
	visual.animate(delta, velocity.length() if enabled else 0.0)
