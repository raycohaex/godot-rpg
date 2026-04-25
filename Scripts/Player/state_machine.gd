class_name StateMachine extends Node

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	# Loop through all child nodes and register them in the dictionary
	for child in get_children():
		if child is State:
			# We store the state name in lowercase for easy lookup
			states[child.name.to_lower()] = child
			# Connect the child's signal to our transition function
			child.transitioned.connect(on_child_transition)
			
	if initial_state:
		initial_state.enter()
		current_state = initial_state

# Delegate processing to the active state
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(state: State, new_state_name: String) -> void:
	# Ignore if the signal came from a state that is no longer active
	if state != current_state:
		return
		
	var new_state: State = states.get(new_state_name.to_lower())
	if !new_state:
		push_warning("State Machine: State " + new_state_name + " does not exist.")
		return
		
	# Swap the states
	if current_state:
		current_state.exit()
		
	new_state.enter()
	current_state = new_state
