extends ColorRect

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Только визуальные эффекты
	gui_input.connect(_on_retry_input)

func _on_retry_input(event: InputEvent):
	# Только визуальная обратная связь
	if (event is InputEventScreenTouch or 
	   (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT)):
		
		if event.pressed:
			modulate.a = 0.7
		else:
			modulate.a = 1.0
