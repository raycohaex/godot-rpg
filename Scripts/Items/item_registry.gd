extends Node

# Note: this file is made because it's easy. The problem here is
# that when the item list grows to 100s of items or if multiple devs work on the project
# that this service is too opinionated. Some problems i can think of here are;
# - it assumes every .tres file in the items folder is a ItemData resource
# - lookup is slow in big projects
# i think to solve this it should use a map file but i couldn't think of an easy way to generate one, it would require a custom tool i think.
var _database: Dictionary = {}

const ROOT_FOLDER: String = "res://Scripts/Items/"

func _ready() -> void:
	_scan_folder(ROOT_FOLDER)
	print("ItemRegistry initialized successfully with ", _database.size(), " items.")

# --- THE LOOKUP (Used by Player and Inventory) ---
func get_item(id: StringName) -> ItemData:
	if _database.has(id):
		return _database[id]
	
	push_error("ItemRegistry: Could not find item with ID: ", id)
	return null

func _scan_folder(path: String) -> void:
	var dir = DirAccess.open(path)
	
	if not dir:
		push_error("ItemRegistry: Could not open folder -> ", path)
		return
		
	for file_name in dir.get_files():
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var resource_path = path + "/" + file_name
			
			# Load it and cast it to our custom Resource type
			var item_resource = load(resource_path) as ItemData
			
			if item_resource:
				if item_resource.id != &"":
					# Register it into the database!
					_database[item_resource.id] = item_resource
				else:
					push_warning("ItemRegistry: Found ItemData but its ID is empty -> ", file_name)
	
	# recursively look in subfolders
	for dir_name in dir.get_directories():
		var subfolder_path = path + "/" + dir_name
		_scan_folder(subfolder_path)
