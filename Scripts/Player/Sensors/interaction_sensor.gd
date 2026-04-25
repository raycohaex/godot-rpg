extends RayCast3D

# 1. We store the physical Node3D (the RigidBody), not the Resource data!
var target_node: Node3D = null
@export var inventory: InventoryComponent

func _physics_process(_delta: float) -> void:
	if is_colliding():
		var collider = get_collider()
		
		if collider.is_in_group(&"item"):
			target_node = collider
		else:
			target_node = null
	else:
		target_node = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if target_node != null:
			var amount_to_add: int = target_node.quantity
			
			# we assume the item is setup correctly here
			var item_from_registry: ItemData = ItemRegistry.get_item(target_node.id)
			
			# try adding the item(s) to inventory, this might result in a "partial add", hence we say items_left
			var items_left: int = inventory.add_item(item_from_registry, amount_to_add)
			
			# If inventory full
			if items_left == amount_to_add:
				return
			
			# Everything picked up
			if items_left == 0:
				target_node.queue_free()
				target_node = null
			elif items_left < amount_to_add:
				target_node.quantity = items_left
