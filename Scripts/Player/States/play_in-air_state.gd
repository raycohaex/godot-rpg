class_name PlayerInAirState extends State

# We need access to the input component to know when to leave Idle
@export var input: PlayerInput
@onready var player: CharacterBody3D = $"../.."

func enter() -> void:
	print("Entered State: Air")

func physics_update(_delta: float) -> void:
	if player.is_on_floor():
		if input.movement_direction != Vector2.ZERO:
			transitioned.emit(self, "walk")
		else:
			transitioned.emit(self, "idle")
