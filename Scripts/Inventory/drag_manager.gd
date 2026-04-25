extends CanvasLayer

var is_dragging = false
var dragged_item_data: InventoryItem
var drag_visual: TextureRect
signal item_thrown(item_data: InventoryItem)

var current_hovered_container = null

var source_inventory: InventoryComponent = null

func pick_up_item(item: InventoryItem, visual_node: Control, _source_inventory: InventoryComponent):
	is_dragging = true
	dragged_item_data = item
	source_inventory = _source_inventory
	
	drag_visual = TextureRect.new()
	drag_visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	drag_visual.size = visual_node.size
	drag_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE # We give this to prevent ui bugs with dragging
	drag_visual.texture = item.data.icon
	add_child(drag_visual)
	
	visual_node.modulate.a = 0.5 

func _process(_delta):
	if is_dragging and drag_visual:
		drag_visual.global_position = get_viewport().get_mouse_position() - (drag_visual.size / 2.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if is_dragging:
				var all_zones = get_tree().get_nodes_in_group("item_drop_zone")
				var mouse_pos = get_viewport().get_mouse_position()
				var item_dropped: bool = false

				for zone in all_zones:
					if zone.get_global_rect().has_point(mouse_pos):
						assert(zone.owner.has_method("receive_drop"))
						if zone.owner != null and zone.owner.has_method("receive_drop"):
							zone.owner.receive_drop(dragged_item_data)
							item_dropped = true
							break
				if not item_dropped:
					item_thrown.emit(dragged_item_data)
					source_inventory.remove_item(dragged_item_data)
				source_inventory = null
				item_dropped = true
				is_dragging = false
				dragged_item_data = null # Assign null, otherwise it would be deleted
				drag_visual.queue_free()
