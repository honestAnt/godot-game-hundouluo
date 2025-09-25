extends CharacterBody2D

# 敌人基础脚本

# 敌人类型
enum EnemyType { SOLDIER, TURRET, RUNNER, FLYING, BOSS }
@export var enemy_type: EnemyType = EnemyType.SOLDIER

# 基础参数
@export var max_health = 20
@export var speed = 100
@export var damage = 10
@export var score_value = 100
@export var detection_range = 300
@export var attack_range = 200
@export var attack_cooldown = 1.5

# 状态变量
var health = max_health
var gravity = 800
var facing_right = false
var can_attack = true
var is_dead = false
var player = null
var patrol_points = []
var current_patrol_point = 0
var ai_state = "patrol"  # patrol, chase, attack, idle

# 节点引用
@onready var sprite = $AnimatedSprite
@onready var attack_timer = $AttackTimer
@onready var detection_area = $DetectionArea
@onready var attack_area: Area2D = $AttackArea if has_node("AttackArea") else null
@onready var animation_player = $AnimationPlayer
@onready var shoot_position = $ShootPosition
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer if has_node("AudioPlayer") else null

# 预加载资源
var bullet_scene = preload("res://src/scenes/bullets/enemy_bullet.tscn")

func _ready():
	# 初始化敌人
	health = max_health
	
	# 连接信号
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_body_entered)
	
	# 添加到敌人组
	add_to_group("enemies")
	
	# 根据敌人类型设置参数
	_setup_enemy_type()

func _physics_process(delta):
	if is_dead:
		return
	
	var enemy_velocity = velocity
	
	# 根据敌人类型处理AI
	match enemy_type:
		EnemyType.SOLDIER:
			_handle_soldier_ai(delta, enemy_velocity)
		EnemyType.TURRET:
			_handle_turret_ai(delta, enemy_velocity)
		EnemyType.RUNNER:
			_handle_runner_ai(delta, enemy_velocity)
		EnemyType.FLYING:
			_handle_flying_ai(delta, enemy_velocity)
		EnemyType.BOSS:
			_handle_boss_ai(delta, enemy_velocity)
	
	# 更新动画
	_update_animation()
	
	# 应用移动
	if enemy_type != EnemyType.FLYING and enemy_type != EnemyType.TURRET:
		enemy_velocity.y += gravity * delta
	
	set_velocity(enemy_velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()
	velocity = enemy_velocity

func _setup_enemy_type():
	match enemy_type:
		EnemyType.SOLDIER:
			max_health = 20
			speed = 100
			attack_cooldown = 1.5
		EnemyType.TURRET:
			max_health = 30
			speed = 0
			attack_cooldown = 2.0
		EnemyType.RUNNER:
			max_health = 15
			speed = 150
			attack_cooldown = 1.0
		EnemyType.FLYING:
			max_health = 25
			speed = 120
			attack_cooldown = 1.8
			gravity = 0
		EnemyType.BOSS:
			max_health = 200
			speed = 80
			attack_cooldown = 3.0
	
	health = max_health

func _handle_soldier_ai(delta, enemy_velocity):
	match ai_state:
		"patrol":
			_patrol(enemy_velocity)
			
			# 检查是否发现玩家
			if player and _can_see_player():
				ai_state = "chase"
		
		"chase":
			if player and _can_see_player():
				# 朝向玩家
				facing_right = player.global_position.x > global_position.x
				
				# 移动向玩家
				var direction = 1 if facing_right else -1
				enemy_velocity.x = direction * speed
				
				# 检查是否在攻击范围内
				if global_position.distance_to(player.global_position) <= attack_range:
					ai_state = "attack"
			else:
				# 失去玩家，回到巡逻
				ai_state = "patrol"
		
		"attack":
			enemy_velocity.x = 0
			
			if player and _can_see_player() and can_attack:
				if global_position.distance_to(player.global_position) <= attack_range:
					_attack()
				else:
					ai_state = "chase"
			elif not player or not _can_see_player():
				ai_state = "patrol"

func _handle_turret_ai(delta, enemy_velocity):
	velocity = Vector2.ZERO
	
	if player and _can_see_player():
		# 朝向玩家
		facing_right = player.global_position.x > global_position.x
		
		# 如果在攻击范围内且可以攻击
		if global_position.distance_to(player.global_position) <= attack_range and can_attack:
			_attack()

func _handle_runner_ai(delta, enemy_velocity):
	match ai_state:
		"patrol":
			_patrol(enemy_velocity)
			
			# 检查是否发现玩家
			if player and _can_see_player():
				ai_state = "chase"
		
		"chase":
			if player and _can_see_player():
				# 朝向玩家
				facing_right = player.global_position.x > global_position.x
				
				# 移动向玩家，跑得更快
				var direction = 1 if facing_right else -1
				enemy_velocity.x = direction * speed * 1.5
				
				# 检查是否在攻击范围内
				if global_position.distance_to(player.global_position) <= attack_range / 2:
					ai_state = "attack"
			else:
				# 失去玩家，回到巡逻
				ai_state = "patrol"
		
		"attack":
			if player and _can_see_player():
				# 冲向玩家
				facing_right = player.global_position.x > global_position.x
				var direction = 1 if facing_right else -1
				enemy_velocity.x = direction * speed * 2
				
				# 如果在极近距离且可以攻击
				if global_position.distance_to(player.global_position) <= attack_range / 3 and can_attack:
					_attack()
				elif global_position.distance_to(player.global_position) > attack_range:
					ai_state = "chase"
			else:
				ai_state = "patrol"

func _handle_flying_ai(delta, enemy_velocity):
	match ai_state:
		"patrol":
			_fly_patrol(enemy_velocity)
			
			# 检查是否发现玩家
			if player and _can_see_player():
				ai_state = "chase"
		
		"chase":
			if player and _can_see_player():
				# 计算到玩家的方向
				var direction = (player.global_position - global_position).normalized()
				enemy_velocity = direction * speed
				
				# 朝向玩家
				facing_right = player.global_position.x > global_position.x
				
				# 检查是否在攻击范围内
				if global_position.distance_to(player.global_position) <= attack_range:
					ai_state = "attack"
			else:
				# 失去玩家，回到巡逻
				ai_state = "patrol"
		
		"attack":
			if player and _can_see_player():
				# 保持一定距离
				var direction = (player.global_position - global_position).normalized()
				var distance = global_position.distance_to(player.global_position)
				
				if distance < attack_range / 2:
					# 太近，后退
					enemy_velocity = -direction * speed / 2
				elif distance > attack_range:
					# 太远，前进
					enemy_velocity = direction * speed
				else:
					# 保持位置，轻微移动
					enemy_velocity = Vector2.ZERO
				
				# 朝向玩家
				facing_right = player.global_position.x > global_position.x
				
				# 攻击
				if can_attack:
					_attack()
			else:
				ai_state = "patrol"

func _handle_boss_ai(delta, enemy_velocity):
	# Boss AI会在专门的Boss脚本中实现
	pass

func _patrol(enemy_velocity):
	if patrol_points.is_empty():
		velocity.x = 0
		return
	
	# 移动到当前巡逻点
	var target = patrol_points[current_patrol_point]
	var direction = sign(target.x - global_position.x)
	
	if direction == 0:
		velocity.x = 0
	else:
		enemy_velocity.x = direction * speed
		facing_right = direction > 0
	
	# 检查是否到达目标点
	if abs(global_position.x - target.x) < 10:
		current_patrol_point = (current_patrol_point + 1) % patrol_points.size()

func _fly_patrol(enemy_velocity):
	if patrol_points.is_empty():
		velocity = Vector2.ZERO
		return
	
	# 移动到当前巡逻点
	var target = patrol_points[current_patrol_point]
	var direction = (target - global_position).normalized()
	
	enemy_velocity = direction * speed
	facing_right = direction.x > 0
	
	# 检查是否到达目标点
	if global_position.distance_to(target) < 10:
		current_patrol_point = (current_patrol_point + 1) % patrol_points.size()

func _can_see_player():
	if not player:
		return false
	
	# 检查玩家是否在视线内
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	query.exclude = [self]
	query.collision_mask = collision_mask
	var result = space_state.intersect_ray(query)
	
	if result and result.collider == player:
		return true
	
	return false

func _attack():
	can_attack = false
	attack_timer.start(attack_cooldown)
	
	match enemy_type:
		EnemyType.SOLDIER, EnemyType.TURRET, EnemyType.FLYING:
			# 射击攻击
			var bullet = bullet_scene.instantiate()
			bullet.global_position = shoot_position.global_position
			
			# 设置子弹方向
			var direction = (player.global_position - global_position).normalized()
			bullet.direction = direction
			
			# 添加到场景
			get_parent().add_child(bullet)
			if audio_player:
				# 加载并播放射击音效
				var shoot_sound = load("res://src/assets/sounds/shoot.wav")
				if shoot_sound:
					audio_player.stream = shoot_sound
					audio_player.play(0.0)
		
		EnemyType.RUNNER:
			# 近战攻击
			if animation_player.has_animation("attack"):
				animation_player.play("attack")
			if audio_player:
				# 加载并播放近战音效
				var melee_sound = load("res://src/assets/sounds/melee.wav")
				if melee_sound:
					audio_player.stream = melee_sound
					audio_player.play(0.0)
			
			# 检查是否击中玩家
			if attack_area and attack_area.overlaps_body(player):
				player.take_damage(damage)
		
		EnemyType.BOSS:
			# Boss攻击在专门的Boss脚本中实现
			pass

func _update_animation():
	# 更新精灵朝向
	sprite.flip_h = !facing_right
	
	# 更新射击位置
	if facing_right:
		shoot_position.position.x = abs(shoot_position.position.x)
	else:
		shoot_position.position.x = -abs(shoot_position.position.x)
	
	# 设置动画
	if is_dead:
		sprite.animation = "die"
		return
	
	match enemy_type:
		EnemyType.SOLDIER, EnemyType.RUNNER:
			if velocity.x != 0:
				sprite.animation = "run"
			else:
				sprite.animation = "idle"
		
		EnemyType.TURRET:
			sprite.animation = "idle"
		
		EnemyType.FLYING:
			sprite.animation = "fly"
		
		EnemyType.BOSS:
			if velocity.x != 0:
				sprite.animation = "walk"
			else:
				sprite.animation = "idle"

func _on_attack_timer_timeout():
	can_attack = true

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_detection_body_exited(body):
	if body == player:
		player = null

func _on_attack_area_body_entered(body):
	if body.is_in_group("player") and enemy_type == EnemyType.RUNNER:
		# 跑步敌人接触玩家时立即攻击
		if can_attack:
			_attack()

func take_damage(amount):
	if is_dead:
		return
	
	health -= amount
	
	if health <= 0:
		die()
	else:
		# 受伤动画
		if animation_player.has_animation("hit"):
			animation_player.play("hit")
		if audio_player:
			# 加载并播放受伤音效
			var hit_sound = load("res://src/assets/sounds/hit.wav")
			if hit_sound:
				audio_player.stream = hit_sound
				audio_player.play(0.0)

func die():
	is_dead = true
	velocity = Vector2.ZERO
	
	# 禁用碰撞
	$CollisionShape2D.disabled = true
	
	# 播放死亡动画
	sprite.animation = "die"
	if audio_player:
		# 加载并播放死亡音效
		var die_sound = load("res://src/assets/sounds/die.wav")
		if die_sound:
			audio_player.stream = die_sound
			audio_player.play(0.0)
	
	# 添加分数
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").add_score(score_value)
	
	# 随机掉落物品
	_drop_item()
	
	# 延迟移除
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _drop_item():
	# 随机掉落武器或物品
	var drop_chance = randf()
	
	if drop_chance < 0.3:  # 30%几率掉落物品
		var pickup_scene = load("res://src/scenes/weapon_pickup.tscn")
		var pickup = pickup_scene.instantiate()
		pickup.global_position = global_position
		
		# 随机武器类型
		var weapon_types = ["M", "S", "L", "F", "R"]
		pickup.weapon_type = weapon_types[randi() % weapon_types.size()]
		
		get_parent().add_child(pickup)

func set_patrol_points(points):
	patrol_points = points
	if not patrol_points.empty():
		current_patrol_point = 0
