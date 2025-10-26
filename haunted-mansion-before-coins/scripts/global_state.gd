extends Node

# Global game data
var money: int = 500
var furniture_data_list: Array = []  # Store placed furniture info (data + position)

# Save furniture layout
func save_room(furniture_instances: Array):
	furniture_data_list.clear()
	for furniture in furniture_instances:
		if furniture.has_meta("furniture_data") and furniture.has_meta("furniture_size"):
			var data = furniture.get_meta("furniture_data")
			furniture_data_list.append({
				"id": data["id"],
				"position": furniture.position
			})

# Restore furniture layout
func restore_room(haunted_room):
	for item in furniture_data_list:
		var data = load("res://scripts/furniture_data.gd").get_furniture_by_id(item["id"])
		if data:
			haunted_room.add_furniture(data, item["position"])
