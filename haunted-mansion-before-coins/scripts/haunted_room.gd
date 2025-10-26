# haunted_room.gd
extends Node2D

# Signals
signal furniture_placed(furniture_data, position)
signal furniture_removed(furniture_data)

# Room properties
var room_size = Vector2(900, 1600)
var furniture_instances = []  # Array of placed furniture
var selected_furniture = null
var drag_offset = Vector2.ZERO

@onready var spawn_area = $FurnitureSpawnArea

func _ready():
	GlobalState.restore_room(self)
	setup_room()
	setup_input()

func setup_room():
	# Set up room background and boundaries
	var background = $Background
	background.size = room_size
	background.color = Color(0.08, 0.08, 0.15)
	
	# Furniture spawn area
	spawn_area.size = room_size - Vector2(80, 80)
	spawn_area.position = Vector2(40, 40)
	spawn_area.color = Color(0.12, 0.12, 0.2, 0.0)
	spawn_area.mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup_input():
	# Enable input processing
	set_process_input(true)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position()
			
			if selected_furniture:
				# If we're already dragging something, stop dragging regardless of what we click
				stop_dragging()
			else:
				# Only start dragging if we're not already dragging something
				var clicked_furniture = get_furniture_at_position(mouse_pos)
				if clicked_furniture:
					start_dragging(clicked_furniture, mouse_pos)
				
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			var mouse_pos = get_global_mouse_position()
			var furniture = get_furniture_at_position(mouse_pos)
			if furniture and furniture != selected_furniture:
				remove_furniture(furniture)
	
	elif event is InputEventMouseMotion and selected_furniture:
		var mouse_pos = get_global_mouse_position()
		selected_furniture.position = mouse_pos - drag_offset
		update_drag_feedback(is_valid_placement(selected_furniture))
		
func update_drag_feedback(is_valid: bool):
	if selected_furniture:
		# Use the furniture_node's set_highlighted function instead of accessing Sprite2D directly
		if selected_furniture.has_method("set_highlighted"):
			selected_furniture.set_highlighted(is_valid)
		else:
			print("Selected furniture doesn't have set_highlighted method")

func start_dragging(furniture, mouse_pos):
	selected_furniture = furniture
	if selected_furniture:
		print("Furniture selected.")
	drag_offset = mouse_pos - furniture.position
	furniture.z_index = 10  # Bring to front
	spawn_area.color = Color(0.12, 0.12, 0.2, 0.3)

func is_valid_placement(furniture_node) -> bool:
	if not furniture_node.has_meta("furniture_size"):
		print("❌ No furniture_size metadata")
		return false
	
	var furniture_size = furniture_node.get_meta("furniture_size")
	# Fix: Account for centered sprite by subtracting half the size
	var furniture_rect = Rect2(furniture_node.position - furniture_size/2, furniture_size)
	var spawn_rect = Rect2(spawn_area.position, spawn_area.size)
	
	# Check if within spawn area
	if not spawn_rect.encloses(furniture_rect):
		print("❌ Not within spawn area")
		return false
	
	# Check for collisions with other furniture
	for other_furniture in furniture_instances:
		if other_furniture != furniture_node and other_furniture.has_meta("furniture_size"):
			var other_size = other_furniture.get_meta("furniture_size")
			var other_rect = Rect2(other_furniture.position - other_size/2, other_size)
			
			if furniture_rect.intersects(other_rect):
				print("❌ Collision with other furniture")
				return false
	
	print("✅ Placement is valid")
	return true

func stop_dragging():
	if selected_furniture:
		var valid = is_valid_placement(selected_furniture)
		print("Placement valid: ", valid)
		
		if valid:
			selected_furniture.z_index = 1  # Reset z-index
			if selected_furniture.has_meta("furniture_data"):
				var furniture_data = selected_furniture.get_meta("furniture_data")
				furniture_placed.emit(furniture_data, selected_furniture.position)
		else:
			# Return to original position or remove
			print("Invalid placement - removing furniture")
			remove_furniture(selected_furniture)
		
		# Clear the selected furniture AFTER processing
		selected_furniture = null
		spawn_area.color = Color(0.12, 0.12, 0.2, 0.0)
		print("Stopped dragging")

func create_furniture_node(furniture_data: Dictionary) -> Node2D:
	var furniture_node = Node2D.new()

	# FIRST: Create and add the sprite
	var sprite = Sprite2D.new()

	# TRY TO LOAD ACTUAL TEXTURE
	var texture_path = furniture_data["texture"]
	var texture = load(texture_path)

	if texture:
		# Use the actual furniture image
		sprite.texture = texture
		print("✅ Loaded actual texture: ", texture_path)
	else:
		# Fallback to placeholder if image doesn't exist
		sprite.texture = create_placeholder_texture(furniture_data)
		print("❌ Texture not found, using placeholder: ", texture_path)

	sprite.centered = true
	furniture_node.add_child(sprite)

	# SECOND: Set the furniture data AND size
	furniture_node.set_meta("furniture_data", furniture_data)  # Store the full data dictionary
	furniture_node.set_meta("furniture_size", furniture_data["size"])  # Store just the size

	# THIRD: Attach the script AFTER the sprite exists
	furniture_node.set_script(preload("res://scripts/furniture_node.gd"))

	return furniture_node

func get_furniture_at_position(position: Vector2):
	for furniture in furniture_instances:
		if furniture.has_meta("furniture_size"):
			var furniture_size = furniture.get_meta("furniture_size")
			# Fix: Account for centered sprite
			var furniture_rect = Rect2(furniture.position - furniture_size/2, furniture_size)
			
			if furniture_rect.has_point(position):
				return furniture
	
	return null

func add_furniture(furniture_data: Dictionary, position: Vector2 = Vector2.ZERO):
	var furniture_scene = create_furniture_node(furniture_data)
	
	if position == Vector2.ZERO:
		# Find empty spot
		position = find_empty_spot(furniture_data)
	
	# Adjust position for centered sprites - add half the furniture size
	var furniture_size = furniture_data["size"]
	position += furniture_size / 2
	
	furniture_scene.position = position
	add_child(furniture_scene)
	furniture_instances.append(furniture_scene)
	
	furniture_placed.emit(furniture_data, position)
	return furniture_scene

func create_placeholder_texture(furniture_data: Dictionary) -> Texture2D:
	# Create a colored rectangle as placeholder
	var image = Image.create(int(furniture_data["size"].x), int(furniture_data["size"].y), false, Image.FORMAT_RGBA8)
	
	# Different colors for different categories
	var color = Color(0.3, 0.2, 0.4)  # Default purple
	match furniture_data["category"]:
		"seating": color = Color(0.4, 0.2, 0.3)    # Reddish
		"surface": color = Color(0.2, 0.3, 0.4)    # Blueish  
		"lighting": color = Color(0.8, 0.6, 0.2)   # Gold
		"decor": color = Color(0.3, 0.4, 0.2)      # Greenish
	
	image.fill(color)
	
	var texture = ImageTexture.create_from_image(image)
	return texture

func find_empty_spot(furniture_data: Dictionary) -> Vector2:
	# Simple algorithm to find empty spot
	var furniture_size = furniture_data["size"]
	var grid_size = 20  # Grid snapping
	
	# Start from half the furniture size to account for centered sprites
	var start_x = int(furniture_size.x / 2)
	var start_y = int(furniture_size.y / 2)
	
	for y in range(start_y, int(spawn_area.size.y - furniture_size.y), grid_size):
		for x in range(start_x, int(spawn_area.size.x - furniture_size.x), grid_size):
			var test_pos = spawn_area.position + Vector2(x, y)
			var test_rect = Rect2(test_pos, furniture_size)
			
			var collision = false
			for furniture in furniture_instances:
				if furniture.has_meta("furniture_size"):
					var other_size = furniture.get_meta("furniture_size")
					var furniture_rect = Rect2(furniture.position, other_size)
					if test_rect.intersects(furniture_rect):
						collision = true
						break
			
			if not collision:
				return test_pos
	
	# If no empty spot found, place randomly (adjusted for centered sprites)
	return spawn_area.position + Vector2(
		start_x + randf() * (spawn_area.size.x - furniture_size.x - start_x),
		start_y + randf() * (spawn_area.size.y - furniture_size.y - start_y)
	)

func remove_furniture(furniture_node):
	# Remove from list
	furniture_instances.erase(furniture_node)

	# Refund if possible
	if furniture_node.has_meta("furniture_data"):
		var furniture_data = furniture_node.get_meta("furniture_data")
		
		# Refund money (use the 'price' from the furniture data)
		if "price" in furniture_data:
			GlobalState.money += furniture_data["price"]
			print("Refunded:", furniture_data["price"], "New balance:", GlobalState.money)

		# Emit signal for any connected logic (UI updates, etc.)
		furniture_removed.emit(furniture_data)
	
	# Delete the node from the scene
	furniture_node.queue_free()


func clear_all_furniture():
	for furniture in furniture_instances:
		furniture.queue_free()
	furniture_instances.clear()

func get_furniture_count() -> int:
	return furniture_instances.size()

func get_total_value() -> int:
	var total = 0
	for furniture in furniture_instances:
		if furniture.has_meta("furniture_data"):
			var furniture_data = furniture.get_meta("furniture_data")
			total += furniture_data.get("price", 0)
	return total

func _exit_tree():
	GlobalState.save_room(furniture_instances)
