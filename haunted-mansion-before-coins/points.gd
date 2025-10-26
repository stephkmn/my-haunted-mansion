extends Label

var points = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "Points: " + str(points)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _add_points(correct: bool) -> void:
	if correct:
		print("Added 5 points")
		points += 5
		text = "Points: " + str(points)
		GlobalState.money += 5
	
