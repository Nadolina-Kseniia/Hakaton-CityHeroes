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
	# Загружаем текстуру один раз
	var texture = load("res://art/player_0.png")
	add_to_group("player")
	# Создаем общий материал
	var shared_material = StandardMaterial3D.new()
	shared_material.albedo_texture = texture
	shared_material.metallic = 0.0
	shared_material.roughness = 1.0
	
	# Применяем к обоим мешам
	apply_material_to_all_meshes(shared_material)
	

func apply_material_to_all_meshes(material: StandardMaterial3D):
	var skeleton = $GeneralSkeleton
	for child in skeleton.get_children():
		if child is MeshInstance3D:
			child.material_override = material
			# Автоматическая привязка к скелету
			if child.skin == null:
				child.skin = Skin.new()
			child.skeleton = skeleton.get_path()

func _physics_process(delta):
	# Управление движением
	var direction = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)
	
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
		animation_player.speed_scale = 3  # Вдвое больше обычного бега
	
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
			animation_player.speed_scale = 1.5  # Нормальная скорость бега
		else:
			# Анимация покоя
			if animation_player.current_animation != "chicken_with_animation_1":
				animation_player.play("chicken_with_animation_1")
			animation_player.speed_scale = 1
	else:
		# В воздухе - продолжаем анимацию бега с удвоенной скоростью
		if animation_player.current_animation != "chicken_with_animation_2":
			animation_player.play("chicken_with_animation_2")
		animation_player.speed_scale = 3  # Удвоенная скорость

func die():
	set_physics_process(false)  # Отключаем управление
	hide()  # Скрываем модель
	hit.emit()  # Сигнал для UI
	# Не вызываем queue_free() сразу, чтобы сработали анимации/эффекты
	
	# Отложенное удаление через 0.5 сек
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_MobDetector_body_entered(_body):
	die()
	
func _on_body_entered(_body):
	if _body.is_in_group("mob"):
		die()
		# hit.emit()
		# queue_free()
		
