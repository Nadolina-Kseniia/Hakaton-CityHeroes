extends Skeleton3D

func _ready():
	# Получаем MeshInstance3D (должен быть дочерним к Skeleton3D)
	var mesh_instance = $Skeleton3D/MeshInstance3D
	
	# Создаем новый материал
	var material = StandardMaterial3D.new()
	
	# Загружаем текстуру (замените путь на ваш)
	material.albedo_texture = load("res://art/player_0.png")
	
	# Настраиваем материал
	material.metallic = 0.0
	material.roughness = 0.8
	material.cull_mode = StandardMaterial3D.CULL_BACK
	
	# Применяем материал
	mesh_instance.material_override = material
