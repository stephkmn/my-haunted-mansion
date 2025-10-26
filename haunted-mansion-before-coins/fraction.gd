extends Node2D

@onready var line_edit: LineEdit = $LineEdit
@onready var label: Label = $Label
@onready var label2: Label = $Label2
@onready var start_button: Button = $Button
@onready var done_screen: ColorRect = $ThingForDoneScreen
@onready var return_button: Button = $ReturnHomeFromFraction

const QUESTIONS = [
	{
		"question": "1/2 + 3/4 = ?",
		"answer_float": 1.25,
		"answer_string": "1.25"
	},
	{
		"question": "6/7 + 2/7 = ?",
		"answer_float": 8.0/7.0,
		"answer_string": "1.14"
	},
	{
		"question": "11/21 + 3/4 = ?",
		"answer_float": 107.0/84.0,
		"answer_string": "1.29"
	},
]

var current_question_index: int = 0
var score: int = 0

func _ready():
	line_edit.text_submitted.connect(_on_LineEdit_text_entered)
	line_edit.grab_focus()
	
	self.visible = true
	done_screen.visible = false
	return_button.visible = false

func _display_current_question() -> void:
	if current_question_index < QUESTIONS.size():
		label2.text = QUESTIONS[current_question_index].question
		label.text = "Enter your answer above."
		label.modulate = Color.WHITE
	else:
		label2.text = "QUIZ COMPLETE!"
		line_edit.editable = false
		
		print("Fraction game ended")
		
		done_screen.visible = true
		return_button.visible = true
		
		# FIX: Only queue_free the button if it exists and isn't null
		if start_button and is_instance_valid(start_button):
			start_button.queue_free()
		
		line_edit.visible = false
		
		label.text = "Final Score: %d out of %d\nYou earned %d coins." % [score, QUESTIONS.size(), (score * 10)]
		GlobalState.money += score * 10
		label.modulate = Color.GREEN
		label.add_theme_font_size_override("font_size", 28)
		label.position = Vector2(210, 680)
		label.size = Vector2(480, 150)

func _on_LineEdit_text_entered(new_text: String) -> void:
	var input_text = new_text.strip_edges()
	if input_text.is_empty():
		line_edit.clear()
		line_edit.grab_focus()
		return
		
	if current_question_index >= QUESTIONS.size():
		return
	
	# FIX: Add input validation
	if not input_text.is_valid_float():
		label.text = "Please enter a valid number!"
		label.modulate = Color.RED
		line_edit.clear()
		line_edit.grab_focus()
		return
	
	var user_input_float: float = input_text.to_float()
	
	var correct_answer = QUESTIONS[current_question_index].answer_float
	var correct_answer_str = QUESTIONS[current_question_index].answer_string
	
	# FIX: Use tolerance for floating point comparison
	var tolerance = 0.01
	if input_text.is_valid_float() and abs(user_input_float - correct_answer) <= tolerance:
		label.text = "CORRECT! (%s)" % correct_answer_str
		label.modulate = Color.GREEN
		score += 1
	else:
		label.text = "INCORRECT. The correct answer was: %s" % correct_answer_str
		label.modulate = Color.RED
		
	line_edit.clear()
	line_edit.grab_focus()
	await get_tree().create_timer(2.0).timeout  # Reduced from 5.0 to 2.0 seconds
	
	current_question_index += 1
	_display_current_question()

func _on_button_pressed() -> void:
	print("Start button pressed")
	_display_current_question()
