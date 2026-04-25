class_name State extends Node

# We use a signal to tell the StateMachine to change states.
# This keeps the states decoupled from the manager.
signal transitioned(state: State, new_state_name: String)

# Called exactly once when the state becomes active
func enter() -> void:
	pass

# Called exactly once when the state is swapped out
func exit() -> void:
	pass

# Replaces _process
func update(_delta: float) -> void:
	pass

# Replaces _physics_process
func physics_update(_delta: float) -> void:
	pass
