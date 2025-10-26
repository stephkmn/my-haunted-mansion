# main.gd
extends Node2D

@onready var haunted_room = $HauntedRoom
@onready var furniture_store = $FurnitureStore
# @onready var math_game = $MathGame

var shop_button: Button

func _ready():
	print("Main scene loaded!")
	print("HauntedRoom found: ", $HauntedRoom != null)
	print("FurnitureStore found: ", $FurnitureStore != null)
	
	create_shop_button()
	connect_signals()
	update_ui()
	
	if furniture_store.has_node("main_panel"):
		furniture_store.get_node("main_panel").visibility = false
	
func create_shop_button():
	# Create the shop button
	shop_button = Button.new()
	shop_button.text = "🛍️ Shop"
	shop_button.custom_minimum_size = Vector2(100, 40)
	shop_button.position = Vector2(20, 20)  # Top-left corner
	add_child(shop_button)

	# Connect the button signal
	shop_button.connect("pressed", _on_shop_button_pressed)

func _on_shop_button_pressed():
	print("Shop button pressed!")
	furniture_store.visible = true

# In main.gd - add to connect_signals() function
func connect_signals():
	# Connect furniture store signals
	furniture_store.furniture_selected.connect(_on_furniture_selected)

	# Connect haunted room signals  
	haunted_room.furniture_placed.connect(_on_furniture_placed)
	haunted_room.furniture_removed.connect(_on_furniture_removed)

	# Connect math game signals
	# math_game.math_solved.connect(_on_math_solved)

func _on_furniture_selected(furniture_data: Dictionary):
	print("Furniture selected: ", furniture_data["name"])
	if furniture_store.spend_money(furniture_data["price"]):
		haunted_room.add_furniture(furniture_data)
		update_ui()
		# Auto-close shop after purchase (optional)
		furniture_store.visible = false

func _on_furniture_placed(furniture_data: Dictionary, position: Vector2):
	print("Placed %s at %s" % [furniture_data["name"], position])

func _on_furniture_removed(furniture_data: Dictionary):
	# Optional: Refund part of the cost?
	print("Removed %s" % furniture_data["name"])

func _on_math_solved(correct: bool, reward: int):
	if correct:
		furniture_store.add_money(reward)
		update_ui()

func update_ui():
	var furniture_count = haunted_room.get_furniture_count()
	var total_value = haunted_room.get_total_value()
	
	# Update any UI displays
	print("Furniture: %d, Total Value: $%d" % [furniture_count, total_value])
