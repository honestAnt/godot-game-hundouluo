extends Area2D

# 武器类型 (0=机枪, 1=散弹枪, 2=激光枪)
var weapon_type = 1
var rotation_speed = PI  # 每秒旋转PI弧度（半圈）
var hover_height = 5
var hover_speed = 2

func _ready():
	# 连接信号
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# 根据武器类型显示对应的武器精灵
	var weapon_sprite = get_node_or_null("WeaponSprite")
	if not weapon_sprite:
		weapon_sprite = Sprite2D.new()
		weapon_sprite.name = "WeaponSprite"
		add_child(weapon_sprite)
		
	if weapon_sprite:
		match weapon_type:
			0: # 机枪
				# 创建机枪精灵
				var machine_gun = Polygon2D.new()
				machine_gun.color = Color(1, 1, 0) # 黄色
				machine_gun.polygon = PackedVector2Array([-10, -5, 10, -5, 10, 5, -10, 5])
				
				var barrel = Polygon2D.new()
				barrel.color = Color(0.8, 0.8, 0) # 深黄色
				barrel.polygon = PackedVector2Array([-2, -2, 5, -2, 5, 2, -2, 2])
				barrel.position = Vector2(12, 0)
				
				machine_gun.add_child(barrel)
				weapon_sprite.add_child(machine_gun)
				
			1: # 散弹枪 - 已经在场景中创建
				pass
				
			2: # 激光枪
				# 创建激光枪精灵
				var laser_gun = Polygon2D.new()
				laser_gun.color = Color(0, 1, 1) # 青色
				laser_gun.polygon = PackedVector2Array([-10, -5, 10, -5, 10, 5, -10, 5])
				
				var barrel = Polygon2D.new()
				barrel.color = Color(0, 0.8, 0.8) # 深青色
				barrel.polygon = PackedVector2Array([-2, -2, 8, -2, 8, 2, -2, 2])
				barrel.position = Vector2(12, 0)
				
				laser_gun.add_child(barrel)
				weapon_sprite.add_child(laser_gun)

func _physics_process(delta):
	# 旋转效果
	rotation += rotation_speed * delta
	
	# 上下浮动效果
	position.y += sin(Time.get_ticks_msec() / 1000.0 * hover_speed) * hover_height * delta

func _on_body_entered(body):
	if body.has_method("change_weapon"):
		body.change_weapon(weapon_type)
		
		# 获取武器颜色
		var weapon_color = Color(1, 1, 0)  # 默认黄色
		match weapon_type:
			0: # 机枪
				weapon_color = Color(1, 1, 0)  # 黄色
			1: # 散弹枪
				weapon_color = Color(0, 1, 0)  # 绿色
			2: # 激光枪
				weapon_color = Color(0, 1, 1)  # 青色
		
		# 拾取效果
		for i in range(8):
			var particle = ColorRect.new()
			particle.color = weapon_color
			particle.size = Vector2(3, 3)
			particle.position = global_position
			get_parent().add_child(particle)
			
			# 向四周散开
			var angle = i * PI / 4
			var particle_dir = Vector2(cos(angle), sin(angle))
			var particle_speed = randf_range(50, 100)
			
			var tween = get_tree().create_tween()
			tween.tween_property(particle, "position", 
				particle.position + particle_dir * particle_speed, 0.5)
			tween.parallel().tween_property(particle, "color:a", 0.0, 0.5)
			tween.tween_callback(particle.queue_free)
		
		queue_free()