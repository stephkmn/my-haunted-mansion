extends ItemList
var a = randi_range(-10,10)
var b = randi_range(-13,13)
var x = randi_range(-10,10)
# ax + b = c
var c = a*x + b
signal new_question(a: int, b: int, c: int)
signal correct_answer(correct: bool)
var list_of_answers = [randi_range(1,101),randi_range(1,101),randi_range(1,101),x]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if a == 0:
		a = 11
	if b == 0:
		b = 14
	if x == 0:
		x = 11
	
	c = a * x + b;
		
	new_question.emit(a,b,c)
	for i in range(0,4):
		set_item_text(i, str(list_of_answers[i]))
		
	add_theme_font_size_override("font_size", 45)
	fixed_icon_size = Vector2(700, 75)
	icon_scale = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func correct(idx: int) -> bool:
	return list_of_answers[idx] == x


func _on_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	print("Picked answer " + get_item_text(index) + ": ")
	if correct(index):
		print("Correct")
		correct_answer.emit(true)
	else:
		print("Incorrect")
		correct_answer.emit(false)
		
		# make new problem
	a = randi_range(-10,10)
	b = randi_range(-13,13)
	x = randi_range(-10,10)
	
	if a == 0:
		a = 11
	if b == 0:
		b = 14
	if x == 0:
		x = 11
	
	c = a*x + b
	list_of_answers = [randi_range(1,101),randi_range(1,101),randi_range(1,101),x]
	list_of_answers.shuffle()
	new_question.emit(a,b,c)
	for i in range(0,4):
		set_item_text(i, str(list_of_answers[i]))
