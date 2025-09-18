extends CharacterBody2D

# 敌人参数
const SPEED = 100.0
const PATROL_DISTANCE = 200.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 3
var direction = -1  # 初始向左移动
var start_position
var can_attack = true
var attack_cooldown = 1.5

# 状态机
enum STATE {PATROL, CHASE, ATTACK}
var current_state = STATE.PATROL
var player = null
var bullet_scene = preload("res://src/scenes/bullet.tscn")

func _ready():
	start_position = global_position
	
	# 获取玩家引用
	await get_tree().process_frame
	player = get_node_or_null("/root/Minimal/Player")

func _physics_process(delta):
	# 添加重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	match current_state:
		STATE.PATROL:
			patrol_state(delta)
		STATE.CHASE:
			chase_state(delta)
		STATE.ATTACK:
			attack_state(delta)
	
	move_and_slide()
	
	# 更新敌人朝向
	if direction > 0:
		$EnemySprite.scale.x = 1
	else:
		$EnemySprite.scale.x = -1
	
	# 检查是否需要转向
	var floor_checker = $FloorChecker
	if floor_checker and not floor_checker.is_colliding() and is_on_floor():
		direction *= -1
		floor_checker.position.x *= -1

func patrol_state(delta):
	velocity.x = direction * SPEED
	
	# 检查是否超出巡逻范围
	if abs(global_position.x - start_position.x) > PATROL_DISTANCE:
		direction *= -1
	
	# 检查是否发现玩家
	if player and abs(player.global_position.x - global_position.x) < 300:
		current_state = STATE.CHASE

func chase_state(delta):
	if player:
		# 向玩家方向移动
		direction = 1 if player.global_position.x > global_position.x else -1
		velocity.x = direction * SPEED * 1.5
		
		# 如果足够近，切换到攻击状态
		if abs(player.global_position.x - global_position.x) < 150:
			current_state = STATE.ATTACK
		# 如果太远，回到巡逻状态
		elif abs(player.global_position.x - global_position.x) > 400:
			current_state = STATE.PATROL
	else:
		current_state = STATE.PATROL

func attack_state(delta):
	velocity.x = 0
	
	# 攻击逻辑
	if player:
		if can_attack:
			shoot_at_player()
			can_attack = false
			await get_tree().create_timer(attack_cooldown).timeout
			can_attack = true
			
		if abs(player.global_position.x - global_position.x) > 150:
			current_state = STATE.CHASE
	else:
		current_state = STATE.PATROL

func shoot_at_player():
	if player:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		
		# 计算朝向玩家的方向
		var shoot_direction = (player.global_position - global_position).normalized()
		bullet.set_direction(shoot_direction)
		bullet.damage = 1
		bullet.speed = 400
		
		# 改变子弹颜色为红色
		bullet.get_node("ColorRect").color = Color(1, 0.3, 0.3)
		
		get_parent().add_child(bullet)
		print("敌人射击!")

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()
	else:
		# 受伤闪烁效果
		modulate = Color(1, 0.5, 0.5)
		
		# 受伤时后退一点
		velocity.x = -direction * SPEED * 2
		
		await get_tree().create_timer(0.2).timeout
		modulate = Color(1, 1, 1)

func die():
	print("敌人被消灭!")
	
	# 死亡效果
	modulate = Color(1, 0, 0)
	call_deferred("disable_collision")
	
func disable_collision():
	$CollisionShape2D.disabled = true
	
	# 随机掉落武器
	if randf() < 0.3:  # 30%几率掉落武器
		var weapon_pickup = load("res://src/scripts/weapon_pickup.gd").new()
		weapon_pickup.weapon_type = randi() % 3
		weapon_pickup.global_position = global_position
		get_parent().add_child(weapon_pickup)
	
	# 死亡动画
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	tween.tween_callback(queue_free)