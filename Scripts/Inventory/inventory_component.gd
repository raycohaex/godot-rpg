class_name InventoryComponent extends Node

@export var grid_size: Vector2i = Vector2i(10, 5) 
@export var items: Array[InventoryItem] = []

func has_space_for(target_pos: Vector2i, item_size: Vector2i) -> bool:
	# Boundary check on whether the item fits
	if target_pos.x < 0 or target_pos.y < 0:
		return false
	# Below we add the position of the top left most tile and check the width of the total items width.
	# If this exceeds the grid maximum size, the item clearly doesn't fit.
	if target_pos.x + item_size.x > grid_size.x:
		return false
	if target_pos.y + item_size.y > grid_size.y:
		return false
		
	# Check for overlapping items
	for x_offset in item_size.x:
		for y_offset in item_size.y:
			# Calculate the absolute grid coordinate to check
			var check_x: int = target_pos.x + x_offset
			var check_y: int = target_pos.y + y_offset
			
			# If get_item_at returns anything other than null, the space is taken!
			if get_item_at(check_x, check_y) != null:
				return false
	
	return true
	
func find_first_free_space(item_size: Vector2i) -> Variant:
	for y in grid_size.y:
		for x in grid_size.x:
			var check_pos: Vector2i = Vector2i(x, y)
			if has_space_for(check_pos, item_size):
				return check_pos
	return null
	
func add_item(item_data: ItemData, amount: int) -> int:
	var max_stack_size: int = item_data.stack_size if item_data.stackable else 1
	if item_data.stackable:
		var existing_items: Array[InventoryItem] = get_items_by_type(item_data)
		for item in existing_items:
			var available_space: int = max_stack_size - item.quantity
			# Item is already at max stack
			if available_space <= 0:
				continue
			# We want to know how much we can substract
			var quantity_to_add: int = min(amount, available_space)
			item.quantity += quantity_to_add
			amount -= quantity_to_add
			# We managed to stack in existing slots so we are finished
			if amount <= 0:
				return amount
	
	# We need to fill the inventory and in case we receive large stacks
	# it should be split into multiple stacks.
	while (amount > 0):
		var item_space: Variant = find_first_free_space(item_data.item_grid_size)
		
		# We may be on iteration 2, 3, etc. and there might not be space left.
		if item_space is not Vector2i:
			return amount
			
		var quantity_to_add: int = min(amount, max_stack_size)
		var item_in_inventory: InventoryItem = InventoryItem.new()
		item_in_inventory.grid_position = item_space
		item_in_inventory.data = item_data
		item_in_inventory.quantity = quantity_to_add
		items.append(item_in_inventory)
		
		amount -= quantity_to_add
	
	return amount
	
func move_item(item: InventoryItem, target_pos: Vector2i) -> bool:
	items.erase(item)
	
	if has_space_for(target_pos, item.data.item_grid_size):
		item.grid_position = target_pos
		items.append(item)
		return true
	else:
		items.append(item)
		return false
	
func get_items_by_type(item_type: ItemData) -> Array[InventoryItem]:
	return items.filter(func(item): return item.data == item_type)
			
			

func get_item_at(x: int, y: int) -> InventoryItem:
	for item in items:
		var item_right: int = item.grid_position.x + item.data.item_grid_size.x
		var item_bottom: int = item.grid_position.y + item.data.item_grid_size.y
		
		# If the X,Y coordinate falls inside this item's rectangle, return the item
		if x >= item.grid_position.x and x < item_right and y >= item.grid_position.y and y < item_bottom:
			return item
			
	return null # The space is empty!
