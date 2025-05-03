extends Node

@export var mob_scene: PackedScene
var reload_cooldown := false

func _ready():
	$UserInterface/Retry.hide()
	# Обработка ввода только здесь
	$UserInterface/Retry.gui_input.connect(_on_retry_input)

func _on_retry_input(event: InputEvent):
	if reload_cooldown or not $UserInterface/Retry.visible:
		return
	
	var is_valid_tap = (event is InputEventScreenTouch and event.pressed) or \
					  (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	
	if is_valid_tap:
		_safe_reload_scene()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible and not reload_cooldown:
		_safe_reload_scene()

func _safe_reload_scene():
	reload_cooldown = true
	# Отложенная перезагрузка через кадр
	await get_tree().process_frame
	get_tree().reload_current_scene()

# Остальные функции остаются без изменений
func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	mob.initialize(mob_spawn_location.position, $Player.position)
	add_child(mob)
	mob.squashed.connect($UserInterface/ScoreLabel._on_Mob_squashed)

func _on_player_hit():
	$MobTimer.stop()
	$UserInterface/Retry.show()
