extends CharacterBody3D

# Настройки
@export var speed: float = 12.0
@export var acceleration: float = 10.0
@export var detection_radius: float = 100.0
@export var min_distance: float = 1.5

# Цель и состояние
var target: Node3D
var is_active: bool = false

# Ноды
@onready var detection_area: Area3D = $DetectionArea
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready():
	# Настройка зоны обнаружения
	var shape = SphereShape3D.new()
	shape.radius = detection_radius
	detection_area.get_node("CollisionShape3D").shape = shape
	
	# Связываем сигналы
	$AnimationPlayer.play("mixamo_com")
	detection_area.body_entered.connect(_on_player_detected)

func _physics_process(delta):
	if !is_active or !target:
		return
	
	# Простое движение к цели
	var direction = (target.global_position - global_position).normalized()
	var target_velocity = direction * speed
	
	# Плавное ускорение/торможение
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	
	# Поворот в сторону движения
	if velocity.length() > 0.1:
		look_at(global_position + velocity.normalized(), Vector3.UP)
	
	# Применяем движение
	move_and_slide()
	
	# Проверка контакта с игроком
	_check_player_collision()

func _on_player_detected(body):
	if body.is_in_group("player") and !is_active:
		target = body
		is_active = true
		print("Цель обнаружена!")

func _check_player_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("player"):
			# Вызываем стандартный сигнал игрока
			
			collision.get_collider().emit_signal("hit")
			print("Игрок поражен!")
