class_name PlayerInput extends Node

var movement_direction: Vector2 = Vector2.ZERO
var look_delta: Vector2 = Vector2.ZERO
var is_jump_pressed: bool = false

func _ready() -> void:
	# This hides the cursor and locks it to the center of the game window.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Moving
	movement_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
# We use _unhandled_input so we don't move while using UI.
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# We use event.relative to get the mouse movement in itself, since event.position is locked to the
		# center of the screen.
		look_delta = event.relative

	if event.is_action_pressed("jump"):
		is_jump_pressed = true
