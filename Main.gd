extends Node

@export var mob_scene: PackedScene
var reload_cooldown := false
var time_score := 0.0
var score_update_interval := 0.1

@onready var score_timer: Timer = $ScoreTimer  # Теперь с аннотацией @onready

func _ready():
	$UserInterface/Retry.hide()
	$UserInterface/ScoreLabel.hide()
	$UserInterface/Retry.gui_input.connect(_on_retry_input)
	
	# Создаем таймер программно, если он не существует
	if !has_node("ScoreTimer"):
		score_timer = Timer.new()
		score_timer.name = "ScoreTimer"
		add_child(score_timer)
		score_timer.timeout.connect(_update_score)
	
	score_timer.wait_time = score_update_interval
	score_timer.start()
	
	var mob_scene = load("res://chaser_mob.tscn")
	if mob_scene == null:
		print("ОШИБКА: Не удалось загрузить сцену chaser_mob.tscn!")
		return
	
	await get_tree().create_timer(1.0).timeout
	spawn_chaser_mob()

func _update_score():
	time_score += score_update_interval
	$UserInterface/ScoreLabel.text = "Время: %.1f" % time_score



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
	await get_tree().process_frame
	get_tree().reload_current_scene()

var min_spawn_distance = 15.0
var spawn_radius = 20.0

func _on_mob_timer_timeout():
	$MobTimer.wait_time = randf_range(0, 2.0)
	var mob = mob_scene.instantiate()
	var player_pos = $Player.global_position
	
	var angle = randf() * 2 * PI
	var distance = randf_range(min_spawn_distance, spawn_radius)
	var spawn_pos = player_pos + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
	
	mob.initialize(spawn_pos, player_pos)
	add_child(mob)
	# Убрали подключение сигнала squashed

func spawn_chaser_mob():
	var mob = load("res://chaser_mob.tscn").instantiate()
	var spawn_pos = Vector3(
		randf_range(-10, 10),
		0,
		randf_range(-10, 10))
	mob.position = spawn_pos
	add_child(mob)

func _on_player_hit():
	$MobTimer.stop()
	score_timer.stop()  # Используем сохраненную ссылку
	$UserInterface/Retry.show()
	$UserInterface/ScoreLabel.show()
