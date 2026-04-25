class_name InventoryItemUI extends Control

@onready var item_image: TextureRect = $ItemImage
@onready var item_label: Label = $ItemLabel
signal item_clicked(item_data: InventoryItem, ui_node: InventoryItemUI)

var item: InventoryItem:
	set(value):
		item = value 
		
		if is_node_ready():
			update_visuals()

func _ready() -> void:
	if item != null:
		update_visuals()
		
func update_visuals() -> void:
	item_image.texture = item.data.icon
	item_label.text = str(item.quantity)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			item_clicked.emit(item, self)
