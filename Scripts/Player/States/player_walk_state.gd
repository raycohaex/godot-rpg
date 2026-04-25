class_name PlayerWalkState extends State

# We need access to the input component to know when to leave Idle
@export var input: PlayerInput
@onready var player: CharacterBody3D = $"../.."

@export_category("camera")
@export var camera: Camera3D
@export var bob_frequency: float = 2.0
@export var bob_amplitude: float = 0.08
@export var time_passed: float = 0.0

@export_category("audio")
@export var audiostream: AudioStreamPlayer3D
@export var footsteps: Array[AudioStream]

var _has_stepped: bool = false

func enter() -> void:
	print("Entered State: WALK")

func physics_update(_delta: float) -> void:
	# If the player presses a movement key, transition to the Walk state!
	var current_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	if current_speed < 0.5:
		transitioned.emit(self, "idle")
		
	if input.is_jump_pressed or not player.is_on_floor():
		transitioned.emit(self, "inair")

func update(_delta: float) -> void:
	var current_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	
	# we use step_rate to better control the actual steps taken
	var step_rate: float = 2
	time_passed += current_speed * step_rate * _delta
	
	var new_y: float = sin(time_passed) * bob_amplitude
	var new_x: float = cos(time_passed / 2.0) * bob_amplitude
	
	camera.position.x = new_x
	camera.position.y = new_y
	
	if sin(time_passed) < -0.85:
		if !_has_stepped:
			_play_footstep()
			_has_stepped = true
	else:
		_has_stepped = false
	


func _play_footstep() -> void:
	if footsteps.is_empty():
		return
	audiostream.stream = footsteps.pick_random()
	audiostream.pitch_scale = randf_range(0.8, 1.2)
	audiostream.play()
