extends Node

@export var mob_scene: PackedScene
var reload_cooldown := false

func _ready():
	$UserInterface/Retry.hide()
	# Обработка ввода только здесь
	$UserInterface/Retry.gui_input.connect(_on_retry_input)
	var mob_scene = load("res://chaser_mob.tscn")
	if mob_scene == null:
		print("ОШИБКА: Не удалось загрузить сцену chaser_mob.tscn!")
		return
	
	await get_tree().create_timer(1.0).timeout
	spawn_chaser_mob()

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
var min_spawn_distance = 15.0  # Минимальное расстояние от игрока
var spawn_radius = 20.0  # Радиус спавна

func _on_mob_timer_timeout():
	$MobTimer.wait_time = randf_range(0, 2.0)
	var mob = mob_scene.instantiate()
	var player_pos = $Player.global_position
	
	# Генерируем случайную точку на окружности вокруг игрока
	var angle = randf() * 2 * PI
	var distance = randf_range(min_spawn_distance, spawn_radius)
	var spawn_pos = player_pos + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
	
	mob.initialize(spawn_pos, player_pos)
	add_child(mob)
	mob.squashed.connect($UserInterface/ScoreLabel._on_Mob_squashed)


func spawn_chaser_mob():
	var mob = load("res://chaser_mob.tscn").instantiate()
	# Спавн в случайной точке вокруг игрока
	var spawn_pos = Vector3(
		randf_range(-10, 10),
		0,
		randf_range(-10, 10))
	mob.position = spawn_pos
	add_child(mob)
	print("Моб заспавнен на позиции: ", spawn_pos)


func _on_player_hit():
	$MobTimer.stop()
	$UserInterface/Retry.show()
