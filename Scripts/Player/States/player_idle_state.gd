class_name PlayerIdleState extends State

# We need access to the input component to know when to leave Idle
@export var input: PlayerInput
@onready var player: CharacterBody3D = $"../.."

@export var camera: Camera3D

func enter() -> void:
	print("Entered State: IDLE")

func physics_update(_delta: float) -> void:
	# If the player presses a movement key, transition to the Walk state!
	if input.movement_direction != Vector2.ZERO:
		transitioned.emit(self, "walk")
		
	if input.is_jump_pressed or not player.is_on_floor():
		transitioned.emit(self, "inair")

func update(_delta: float) -> void:
	if camera.position != Vector3.ZERO:
		camera.position = lerp(camera.position, Vector3.ZERO, _delta)
