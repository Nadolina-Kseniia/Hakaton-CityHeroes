extends CharacterBody3D

signal hit

@export var speed = 14
@export var jump_impulse = 20
@export var bounce_impulse = 16
@export var fall_acceleration = 75

@onready var animation_player = $AnimationPlayer
var is_moving = false
var was_on_floor = true


func _ready():
	var skeleton = $GeneralSkeleton
	var model = $GeneralSkeleton/Character  # Путь к вашей модели
	
	# Привязываем модель к скелету
	if model is Node3D:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = load("res://path_to_your_mesh.mesh")
		skeleton.add_child(mesh_instance)
		mesh_instance.skin = Skin.new()
		mesh_instance.skeleton = skeleton.get_path()
		
		# Настройка материала
		var material = StandardMaterial3D.new()
		material.albedo_texture = load("res://textures/player_texture.png")
		mesh_instance.material_override = material
		
		# Удаляем старую модель
		model.queue_free()

func _physics_process(delta):
	# Управление движением
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	
	is_moving = direction.length() > 0
	
	# Поворот персонажа
	if is_moving:
		direction = direction.normalized()
		basis = Basis.looking_at(direction)
	
	# Управление анимациями
	manage_animations()
	
	# Применение скорости
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	# Прыжок
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += jump_impulse
		# Увеличиваем скорость анимации при прыжке
		animation_player.speed_scale = 8  # Вдвое больше обычного бега
	
	# Гравитация
	velocity.y -= fall_acceleration * delta
	move_and_slide()
	
	# Проверка столкновений с мобами
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				velocity.y = bounce_impulse
				break
	
	# Наклон при прыжке
	rotation.x = PI / 6 * velocity.y / jump_impulse
	was_on_floor = is_on_floor()

func manage_animations():
	if is_on_floor():
		if is_moving:
			# Анимация бега
			if animation_player.current_animation != "chicken_with_animation_2":
				animation_player.play("chicken_with_animation_2")
			animation_player.speed_scale = 4  # Нормальная скорость бега
		else:
			# Анимация покоя
			if animation_player.current_animation != "chicken_with_animation_1":
				animation_player.play("chicken_with_animation_1")
			animation_player.speed_scale = 1
	else:
		# В воздухе - продолжаем анимацию бега с удвоенной скоростью
		if animation_player.current_animation != "chicken_with_animation_2":
			animation_player.play("chicken_with_animation_2")
		animation_player.speed_scale = 8  # Удвоенная скорость

func die():
	hit.emit()
	queue_free()

func _on_MobDetector_body_entered(_body):
	die()
