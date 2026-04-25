extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Relations
@onready var _head: Node3D = $Head
@onready var _input: PlayerInput = $PlayerInput
@onready var _shapecast: ShapeCast3D = $ShapeCast3D

@export_group("Movement")
@export var max_speed: float = 7.0
@export var acceleration: float = 6.0
@export var friction: float = 8.0
@export var air_control: float = 0.3

@export_group("Controls")
@export var mouse_sensitivity: float = 0.002

func _ready() -> void:
	# This hides the cursor and locks it to the center of the game window.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Listen to the drag manager in case the player drops something from any pane that supports it
	DragManager.item_thrown.connect(drop_item_in_world)

func _physics_process(delta: float) -> void:
	# First person looking around.
	if _input.look_delta != Vector2.ZERO:
		rotation.y -= (_input.look_delta.x * mouse_sensitivity)
		
		# Rotate first, then clamp it
		_head.rotation.x -= (_input.look_delta.y * mouse_sensitivity)
		_head.rotation.x = clamp(_head.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))
		
		# If we don't reset this to ZERO, the camera will spin forever!
		_input.look_delta = Vector2.ZERO

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if _input.is_jump_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_input.is_jump_pressed = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_vector = Vector3(_input.movement_direction.x, 0, _input.movement_direction.y)
	var direction := (transform.basis * direction_vector).normalized()
	var target_velocity = direction * max_speed
	
	
	var weight: float = acceleration * delta
	
	velocity.x = lerp(velocity.x, target_velocity.x, weight)
	velocity.z = lerp(velocity.z, target_velocity.z, weight)
	
	move_and_slide()
	
func drop_item_in_world(item: InventoryItem): 
	assert(_shapecast)
	_shapecast.force_shapecast_update()
	var culling_percentage: float = _shapecast.get_closest_collision_safe_fraction()
	var target_pos: Vector3 = _shapecast.target_position * culling_percentage
	
	var new_item_3d: Node = item.data.drop_scene.instantiate()
	
	# We have to convert the target position from local (player's shapecast) to
	# where that related in the world.
	var global_drop_pos: Vector3 = _shapecast.to_global(target_pos)
	new_item_3d.global_position = global_drop_pos
	
	# Get the "world" as a parent to spawn the item in, or in a future maybe a worlditem group node.
	var world = get_tree().current_scene
	world.add_child(new_item_3d)
	
