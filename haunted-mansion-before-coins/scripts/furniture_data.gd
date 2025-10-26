# furniture_data.gd (create this as a new script)
extends Node

# Furniture database
static func get_furniture_items():
	return [
		{
			"id": "spooky_chair",
			"name": "Spooky Chair",
			"price": 30,
			"texture": "res://assets/furniture/chair.png",  # You'll need to add these
			"size": Vector2(170, 200),
			"category": "seating"
		},
		{
			"id": "coffin",
			"name": "Ancient Coffin",
			"price": 80,
			"texture": "res://assets/furniture/coffin.png",
			"size": Vector2(350, 230),
			"category": "decor"
		},
		{
			"id": "candle",
			"name": "Eerie Candle",
			"price": 20,
			"texture": "res://assets/furniture/candle.png",
			"size": Vector2(100, 125),
			"category": "lighting"
		},
		{
			"id": "skull",
			"name": "Crystal Skull",
			"price": 25,
			"texture": "res://assets/furniture/skull.png",
			"size": Vector2(150, 150),
			"category": "decor"
		},
		{
			"id": "ghost",
			"name": "Spooky Ghost",
			"price": 30,
			"texture": "res://assets/furniture/ghost.png",
			"size": Vector2(180, 250),
			"category": "decor"
		},
		{
			"id": "pumpkin",
			"name": "Smiley Pumpkin",
			"price": 20,
			"texture": "res://assets/furniture/pumpkin.png",
			"size": Vector2(150, 150),
			"category": "lighting"
		},
		{
			"id": "bat",
			"name": "Count Dracula Himself",
			"price": 25,
			"texture": "res://assets/furniture/bat.png",
			"size": Vector2(180,140),
			"category": "decoration"
		}
	]

# Get furniture by ID
static func get_furniture_by_id(id: String):
	for item in get_furniture_items():
		if item["id"] == id:
			return item
	return null
