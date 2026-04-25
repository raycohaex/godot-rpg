class_name ConsumableTrait extends ItemTrait

@export var heal_amount: int = 20

func consume() -> void:
	print("Ate the item for " + str(heal_amount) + " health!")
