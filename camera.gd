extends Camera3D

# 1. Объявляем экспорт переменной правильного типа
@export var player : CharacterBody3D  # Только тип, без присваивания

# 2. Настройки камеры
@export var camera_offset = Vector3(-5, 25, 15)
@export var follow_speed = 5.0

func _ready():
	# 3. Автопоиск игрока, если не назначен вручную
	if !player:
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	
	# 4. Первоначальная позиция
	if player:
		global_position = player.global_position + camera_offset

func _process(delta):
	if !is_instance_valid(player):
		return
	
	# 5. Плавное следование
	var target_pos = player.global_position + camera_offset
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	look_at(player.global_position + Vector3(0, 0, 0), Vector3.UP)
