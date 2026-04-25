class_name InventoryUI extends Control

const TILE_SIZE: int = 32

@export var inventory_component: InventoryComponent
@export var item_ui_scene: PackedScene
@onready var item_container: Control = $CenterContainer/BoardWrapper/ItemContainer

func _ready() -> void:
	visible = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = !visible
		if visible:
			_refresh_ui()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func receive_drop(item: InventoryItem) -> void:
	# Get mouse pos local to container and correct it to take top left of the image.
	var mouse_pos: Vector2 = item_container.get_local_mouse_position()
	var item_pixel_size: Vector2 = Vector2(item.data.item_grid_size) * TILE_SIZE
	var corrected_mouse_pos: Vector2 = mouse_pos - (Vector2(item.data.item_grid_size) / 2)
	
	# Calculate the grid it should be dropped at by deviding by tile size.
	var target_grid_pos = Vector2i(corrected_mouse_pos / TILE_SIZE)
	
	inventory_component.move_item(item, target_grid_pos)
	_refresh_ui()
	

func _refresh_ui() -> void:
	for child in item_container.get_children():
		child.call_deferred('free')

	for item in inventory_component.items:
		var new_scene = item_ui_scene.instantiate()
		item_container.add_child(new_scene)
		
		
		var position: Vector2i = item.grid_position * TILE_SIZE
		var size: Vector2i = item.data.item_grid_size * TILE_SIZE
		
		new_scene.position = Vector2(position)
		new_scene.size.x = size.x
		new_scene.size.y = size.y
		new_scene.item = item


func _on_background_panel_mouse_entered() -> void:
	DragManager.current_hovered_container = self


func _on_background_panel_mouse_exited() -> void:
	DragManager.current_hovered_container = null
