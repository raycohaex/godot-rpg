class_name ItemData extends Resource

@export var id: StringName
@export var item_name: String
@export var item_grid_size: Vector2i 
@export var item_traits: Array[ItemTrait]
@export var stackable: bool = true
@export var stack_size: int = 10
@export var icon: Texture2D

@export var drop_scene: PackedScene
