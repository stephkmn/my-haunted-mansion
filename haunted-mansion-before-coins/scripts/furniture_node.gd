extends Node2D

# Furniture properties
var furniture_data: Dictionary
var is_draggable = true
var is_resizable = true
var is_selected = false
var selection_box: ColorRect

func _ready():
	# Wait a frame for the sprite to be set up, then create collision
	call_deferred("setup_furniture")
	create_selection_box()

func create_selection_box():
	selection_box = ColorRect.new()
	selection_box.color = Color(1,1,1,0.3)
	selection_box.visible = false
	# Allow mouse to pass through
	selection_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(selection_box)


func update_selection_box():
	if not selection_box or not has_meta("furniture_size"):
		return
	
	var furniture_size = get_meta("furniture_size")
	selection_box.size = furniture_size
	selection_box.position = -furniture_size / 2  # Center it

func set_selected(selected: bool):
	is_selected = selected
	selection_box.visible = selected
	
	if selected:
		update_selection_box()
		z_index = 10  # Bring to front when selected
	else:
		z_index = 1   # Reset z-index

func set_highlighted(highlight: bool):
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		if highlight:
			sprite.modulate = Color(1.2, 1.2, 1.2)  # Brighten
		else:
			sprite.modulate = Color(1, 1, 1)  # Normal

# Handle scroll wheel for resizing
# Handle scroll wheel for resizing
func handle_scroll(delta: float):
	if is_selected and has_meta("furniture_data") and has_meta("furniture_size"):
		var furniture_data = get_meta("furniture_data")
		var current_size = get_meta("furniture_size")
		var min_size = furniture_data.get("min_size", current_size * 0.5)
		var max_size = furniture_data.get("max_size", current_size * 2.0)
		
		# Use a smaller scale factor for smoother resizing
		var scale_factor = 1.05 if delta > 0 else 0.95
		var new_size = current_size * scale_factor
		
		# Clamp to min/max sizes
		new_size = new_size.clamp(min_size, max_size)
		
		# Only update if size actually changed
		if new_size != current_size:
			update_size(new_size)
			return true
	
	return false

# Update furniture size and refresh collision
# Update furniture size and refresh collision
func update_size(new_size: Vector2):
	if has_meta("furniture_data"):
		var furniture_data = get_meta("furniture_data")
		var min_size = furniture_data.get("min_size", new_size * 0.5)
		var max_size = furniture_data.get("max_size", new_size * 2.0)
		
		# Clamp to min/max sizes
		new_size = new_size.clamp(min_size, max_size)
		
		# Update metadata
		set_meta("furniture_size", new_size)
		
		# Update sprite - recreate the texture at the new size
		if has_node("Sprite2D"):
			var sprite = $Sprite2D
			if sprite.texture:
				# Get the original texture path from furniture data
				var texture_path = furniture_data["texture"]
				var original_texture = load(texture_path)
				
				if original_texture:
					# Create a new texture at the scaled size
					var image = original_texture.get_image()
					
					# Calculate the scale factor needed
					var original_size = image.get_size()
					var scale_x = new_size.x / original_size.x
					var scale_y = new_size.y / original_size.y
					
					# Resize the image
					image.resize(int(new_size.x), int(new_size.y), Image.INTERPOLATE_LANCZOS)
					
					# Create new texture from resized image
					var new_texture = ImageTexture.create_from_image(image)
					sprite.texture = new_texture
					sprite.scale = Vector2(1, 1)  # Reset scale since we resized the texture
				else:
					# Fallback: use scaling if texture loading fails
					var original_texture_size = sprite.texture.get_size()
					sprite.scale = new_size / original_texture_size
			else:
				# If no texture, create a placeholder at the new size
				sprite.texture = create_placeholder_texture(new_size)
		
		# Update selection box
		update_selection_box()
		
		# Remove old collision and create new one
		for child in get_children():
			if child is Area2D:
				child.queue_free()
		
		create_collision_from_size(new_size)

# Helper function to create placeholder texture at specific size
func create_placeholder_texture(size: Vector2) -> Texture2D:
	var image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	
	# Use category-based colors or default purple
	var color = Color(0.3, 0.2, 0.4)  # Default purple
	if has_meta("furniture_data"):
		var furniture_data = get_meta("furniture_data")
		match furniture_data.get("category", ""):
			"seating": color = Color(0.4, 0.2, 0.3)    # Reddish
			"surface": color = Color(0.2, 0.3, 0.4)    # Blueish  
			"lighting": color = Color(0.8, 0.6, 0.2)   # Gold
			"decor": color = Color(0.3, 0.4, 0.2)      # Greenish
	
	image.fill(color)
	return ImageTexture.create_from_image(image)

func setup_furniture():
	# Use the furniture size from metadata instead of Sprite2D texture
	if has_meta("furniture_size"):
		var furniture_size = get_meta("furniture_size")
		create_collision_from_size(furniture_size)
		print("✅ Collision created using metadata size: ", furniture_size)
	elif has_node("Sprite2D"):
		var sprite = $Sprite2D
		if sprite and sprite.texture:
			# Fallback to sprite texture size if no metadata
			create_collision_from_size(sprite.texture.get_size())
			print("✅ Collision created using sprite texture size")
		else:
			print("❌ Sprite2D exists but has no texture")
	else:
		print("❌ No Sprite2D node found and no size metadata")

func create_collision_from_size(size: Vector2):
	var area = Area2D.new()
	area.name = "ClickArea"

	# Ensure the Area2D can detect mouse enter/exit
	area.monitorable = true
	area.input_pickable = true
	
	area.input_pickable = true
	area.monitorable = true
	area.collision_layer = 1
	area.collision_mask = 1


	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = Vector2.ZERO
	area.add_child(collision)
	add_child(area)

	# Connect signals using Callable (Godot 4 style)
	area.connect("mouse_entered", Callable(self, "_on_area_mouse_entered"))
	area.connect("mouse_exited", Callable(self, "_on_area_mouse_exited"))


func _on_area_mouse_entered():
	print("mouse entered area:", get_path())
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_area_mouse_exited():
	print("mouse exited area:", get_path())
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
