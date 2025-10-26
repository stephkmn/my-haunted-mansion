# furniture_store.gd
extends CanvasLayer

signal furniture_selected(furniture_data)

var scroll_container: ScrollContainer
var grid_container: GridContainer
var money_label: Label
var close_button: Button
var main_panel: ColorRect

func _ready():
	setup_store()
	update_money_display()

func setup_store():
	# Create main panel
	main_panel = ColorRect.new()
	main_panel.size = Vector2(800, 600)
	main_panel.color = Color(0.056, 0.047, 0.078, 0.835)
	main_panel.position = Vector2(50, 1000)
	add_child(main_panel)

	# Create close button (top-right corner of panel)
	close_button = Button.new()
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(30, 30)
	close_button.position = Vector2(760, 10)
	close_button.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
	main_panel.add_child(close_button)

	# Connect close button
	close_button.connect("pressed", _on_close_button_pressed)

	# Create title
	var title = Label.new()
	title.text = "Furniture Store"
	title.position = Vector2(20, 10)
	title.add_theme_font_size_override("font_size", 28)
	main_panel.add_child(title)

	# Create money label
	money_label = Label.new()
	money_label.name = "MoneyLabel"
	money_label.text = "Money: $100"
	money_label.position = Vector2(600, 20)
	money_label.add_theme_font_size_override("font_size", 24)
	main_panel.add_child(money_label)

	# Create scroll container
	scroll_container = ScrollContainer.new()
	scroll_container.name = "ScrollContainer"
	scroll_container.size = Vector2(760, 520)
	scroll_container.position = Vector2(20, 60)
	main_panel.add_child(scroll_container)

	# Create grid container
	grid_container = GridContainer.new()
	grid_container.name = "GridContainer"
	grid_container.columns = 4
	grid_container.custom_minimum_size = Vector2(100, 0)
	scroll_container.add_child(grid_container)

	# Create furniture items
	create_furniture_items()

func create_furniture_items():
	# Clear existing items
	for child in grid_container.get_children():
		child.queue_free()
	
	# Create furniture items
	var furniture_data_script = load("res://scripts/furniture_data.gd")
	if furniture_data_script:
		for furniture_data in furniture_data_script.get_furniture_items():
			var item = create_store_item(furniture_data)
			grid_container.add_child(item)
	else:
		print("ERROR: Could not load furniture_data.gd")

func _on_close_button_pressed():
	print("Close button pressed!")
	self.visible = false

func create_store_item(furniture_data: Dictionary) -> Control:
	var item = Button.new()
	item.custom_minimum_size = Vector2(180, 80)
	item.text = "%s\n$%d" % [furniture_data["name"], furniture_data["price"]]
	
	# Style based on category
	match furniture_data["category"]:
		"seating": item.add_theme_color_override("font_color", Color(0.9, 0.6, 0.7))
		"surface": item.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9))
		"lighting": item.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
		"decor": item.add_theme_color_override("font_color", Color(0.6, 0.9, 0.7))
	
	item.connect("pressed", _on_furniture_item_pressed.bind(furniture_data))
	return item

func _on_furniture_item_pressed(furniture_data: Dictionary):
	if GlobalState.money >= furniture_data["price"]:
		furniture_selected.emit(furniture_data)
	else:
		show_insufficient_funds()

func show_insufficient_funds():
	# Flash money label red
	var tween = create_tween()
	tween.tween_property(money_label, "theme_override_colors/font_color", Color.RED, 0.2)
	tween.tween_property(money_label, "theme_override_colors/font_color", Color.WHITE, 0.2)

func update_money_display():
	money_label.text = "Money: $%d" % GlobalState.money


func add_money(amount: int):
	GlobalState.money += amount
	update_money_display()

func spend_money(amount: int) -> bool:
	if GlobalState.money >= amount:
		GlobalState.money -= amount
		update_money_display()
		return true
	return false


func _on_haunted_room_furniture_removed(furniture_data: Variant) -> void:
	update_money_display()
