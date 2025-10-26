extends Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(_on_pressed) 

func _on_pressed() -> void:
	var main_menu_node = get_parent().get_parent()
	
	if main_menu_node is Node2D and main_menu_node.has_method("_on_LineEdit_text_entered"):
		var line_edit_node = main_menu_node.line_edit
		
		main_menu_node._on_LineEdit_text_entered(line_edit_node.text)
		
	if main_menu_node is Node2D and main_menu_node.has_method("_start_button_clicked"):
		main_menu_node._start_button_clicked()
