extends CharacterBody2D

# 玩家移动参数
const SPEED = 300.0
const JUMP_VELOCITY = -600.0

# 武器系统
enum WEAPON_TYPE {
	MACHINE_GUN = 0,
	SPREAD = 1, 
	LASER = 2,
	FLAMETHROWER = 3,
	HOMING = 4,
	BOMB = 5
}
var current_weapon = WEAPON_TYPE.MACHINE_GUN
var health = 5

# 获取重力值
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# 射击相关
var can_shoot = true
var shoot_cooldown = 0.2
var bullet_scene = preload("res://src/scenes/bullet.tscn")
var spread_scene = preload("res://src/scenes/spread.tscn")
var laser_scene = preload("res://src/scenes/laser.tscn")

func _ready():
	# 初始化
	pass

func _physics_process(delta):
	# 添加重力
	if not is_on_floor():
		velocity.y += gravity * delta

	# 处理跳跃
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 获取水平移动方向
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		# 翻转角色朝向
		if direction > 0:
			$PlayerSprite.scale.x = 1
		else:
			$PlayerSprite.scale.x = -1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# MacOS专用按键处理
	if OS.get_name() == "macOS":
		# 射击 (Command键)
		if (Input.is_key_pressed(KEY_META) or Input.is_key_pressed(KEY_CTRL)) and can_shoot:
			shoot()
			can_shoot = false
			await get_tree().create_timer(shoot_cooldown).timeout
			can_shoot = true
		
		# 切换武器 (Tab键)
		if Input.is_key_pressed(KEY_TAB):
			switch_weapon()
	else:
		# 其他系统保持原逻辑
		if Input.is_action_pressed("ui_ctrl") and can_shoot:
			shoot()
			can_shoot = false
			await get_tree().create_timer(shoot_cooldown).timeout
			can_shoot = true
			
		if Input.is_action_just_pressed("ui_tab"):
			switch_weapon()

	move_and_slide()
	
	# 更新UI
	update_ui()

func shoot():
	print("射击! 当前武器: ", get_weapon_name())
	
	# 设置子弹方向
	var shoot_direction = Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		if Input.is_action_pressed("ui_right"):
			shoot_direction = Vector2(1, -1).normalized()
		elif Input.is_action_pressed("ui_left"):
			shoot_direction = Vector2(-1, -1).normalized()
		else:
			shoot_direction = Vector2(0, -1)
	elif Input.is_action_pressed("ui_down"):
		if Input.is_action_pressed("ui_right"):
			shoot_direction = Vector2(1, 1).normalized()
		elif Input.is_action_pressed("ui_left"):
			shoot_direction = Vector2(-1, 1).normalized()
		else:
			shoot_direction = Vector2(0, 1)
	else:
		shoot_direction = Vector2(1 if not Input.is_action_pressed("ui_left") else -1, 0)
	
	# 根据武器类型创建不同的子弹
	match current_weapon:
		WEAPON_TYPE.MACHINE_GUN:
			var bullet = bullet_scene.instantiate()
			bullet.global_position = global_position
			bullet.set_direction(shoot_direction)
			bullet.damage = 1
			bullet.speed = 800
			get_parent().add_child(bullet)
		WEAPON_TYPE.SPREAD:
			# 散弹枪发射5发子弹
			for i in range(-2, 3):
				var spread_bullet = spread_scene.instantiate()
				spread_bullet.global_position = global_position
				var angle = shoot_direction.angle() + i * 0.15
				spread_bullet.set_direction(Vector2(cos(angle), sin(angle)))
				spread_bullet.damage = 1
				spread_bullet.speed = 700
				get_parent().add_child(spread_bullet)
		WEAPON_TYPE.LASER:
			# 激光枪发射穿透性子弹
			var laser = laser_scene.instantiate()
			laser.global_position = global_position
			laser.set_direction(shoot_direction)
			laser.damage = 3
			laser.speed = 1200
			laser.penetrating = true
			get_parent().add_child(laser)
		WEAPON_TYPE.FLAMETHROWER:
			# 火焰喷射器发射扇形火焰
			for i in range(8):  # 增加火焰数量
				var flame = bullet_scene.instantiate()
				flame.global_position = global_position
				var angle = shoot_direction.angle() + randf_range(-0.5, 0.5)  # 扩大散射角度
				flame.set_direction(Vector2(cos(angle), sin(angle)))
				flame.damage = 0.8  # 提高伤害
				flame.speed = 350  # 降低速度
				flame.lifetime = 1.2  # 延长存在时间
				flame.get_node("ColorRect").color = Color(1, randf_range(0.3, 0.7), 0)  # 随机火焰颜色
				flame.scale = Vector2(1.5, 1.5)  # 增大尺寸
				get_parent().add_child(flame)
				
			# 添加火焰粒子效果
			var particles = GPUParticles2D.new()
			particles.emitting = true
			particles.amount = 16
			particles.lifetime = 0.3
			particles.process_material.particle_flag_align_y = true
			particles.position = global_position
			get_parent().add_child(particles)
			particles.queue_free()  # 自动移除
		WEAPON_TYPE.HOMING:
			# 追踪导弹
			var missile = bullet_scene.instantiate()
			missile.global_position = global_position
			missile.set_direction(shoot_direction)
			missile.damage = 2
			missile.speed = 500
			missile.homing = true
			missile.get_node("ColorRect").color = Color(0, 1, 1)
			get_parent().add_child(missile)
		WEAPON_TYPE.BOMB:
			# 投掷炸弹
			var bomb = bullet_scene.instantiate()
			bomb.global_position = global_position
			bomb.set_direction(shoot_direction)
			bomb.damage = 5
			bomb.speed = 300
			bomb.explosive = true
			bomb.get_node("ColorRect").color = Color(1, 0, 0)
			get_parent().add_child(bomb)

func switch_weapon():
	current_weapon = (current_weapon + 1) % WEAPON_TYPE.size()
	print("切换武器到: ", get_weapon_name())

func get_weapon_name():
	match current_weapon:
		WEAPON_TYPE.MACHINE_GUN:
			return "机枪"
		WEAPON_TYPE.SPREAD:
			return "散弹枪"
		WEAPON_TYPE.LASER:
			return "激光枪"
		WEAPON_TYPE.FLAMETHROWER:
			return "火焰喷射器"
		WEAPON_TYPE.HOMING:
			return "追踪导弹"
		WEAPON_TYPE.BOMB:
			return "炸弹"
	return "未知武器"

func change_weapon(weapon_type):
	if weapon_type >= 0 and weapon_type < WEAPON_TYPE.size():
		current_weapon = weapon_type
		print("获得新武器: ", get_weapon_name())

func take_damage(amount):
	if health <= 0:
		return  # 已经死亡不再处理伤害
	
	health -= amount
	print("受到伤害! 剩余生命: ", health)
	
	if health <= 0:
		health = 0
		die()

func die():
	print("玩家死亡!")
	# 稍后会添加死亡动画和重生逻辑

func update_ui():
	# 更新UI标签
	var health_label = get_node_or_null("/root/Minimal/UI/HealthLabel")
	var weapon_label = get_node_or_null("/root/Minimal/UI/WeaponLabel")
	
	if health_label:
		health_label.text = "生命值: " + str(health)
	
	if weapon_label:
		weapon_label.text = "武器: " + get_weapon_name()