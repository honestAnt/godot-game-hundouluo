extends CharacterBody2D

# Boss状态
enum STATE {IDLE, ATTACK, DAMAGED, DEAD}
var current_state = STATE.IDLE
var health = 100
var max_health = 100
var phase = 1

# 攻击参数
var attack_cooldown = 3.0
var can_attack = true
var vulnerable = false

func _ready():
	start_idle()

func _physics_process(delta):
	match current_state:
		STATE.IDLE:
			pass
		STATE.ATTACK:
			perform_attack()
		STATE.DAMAGED:
			pass
		STATE.DEAD:
			pass
	
	update_health_bar()

func start_idle():
	current_state = STATE.IDLE
	# 空闲一段时间后攻击
	await get_tree().create_timer(randf_range(2.0, 4.0)).timeout
	if current_state == STATE.IDLE:
		start_attack()

func start_attack():
	current_state = STATE.ATTACK
	perform_attack()

func perform_attack():
	if can_attack:
		can_attack = false
		
		# 根据阶段使用不同攻击模式
		match phase:
			1:
				phase1_attack()
			2:
				phase2_attack()
			3:
				phase3_attack()
		
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
		start_idle()

func phase1_attack():
	# 发射环形子弹
	for i in range(8):
		var bullet = preload("res://src/scenes/bullet.tscn").instantiate()
		bullet.global_position = global_position
		var angle = i * PI/4
		bullet.set_direction(Vector2(cos(angle), sin(angle)))
		bullet.damage = 1
		bullet.speed = 200
		bullet.get_node("ColorRect").color = Color(1, 0, 0)
		get_parent().add_child(bullet)
		await get_tree().create_timer(0.1).timeout

func phase2_attack():
	# 发射追踪导弹
	for i in range(3):
		var missile = preload("res://src/scenes/bullet.tscn").instantiate()
		missile.global_position = global_position
		missile.set_direction(Vector2.RIGHT.rotated(randf_range(-PI/4, PI/4)))
		missile.damage = 2
		missile.speed = 300
		missile.homing = true
		missile.get_node("ColorRect").color = Color(0, 1, 1)
		get_parent().add_child(missile)
		await get_tree().create_timer(0.5).timeout

func phase3_attack():
	# 全屏爆炸攻击
	$Area2D/CollisionShape2D.disabled = false
	$AnimationPlayer.play("explosion_charge")
	await $AnimationPlayer.animation_finished
	$Area2D/CollisionShape2D.disabled = true

func take_damage(amount):
	if vulnerable:
		health -= amount
		if health <= 0:
			die()
		else:
			# 检查是否进入下一阶段
			if health < max_health * 0.66 and phase == 1:
				phase = 2
				start_phase_transition()
			elif health < max_health * 0.33 and phase == 2:
				phase = 3
				start_phase_transition()
			
			$AnimationPlayer.play("damaged")
			await $AnimationPlayer.animation_finished
			vulnerable = false

func start_phase_transition():
	# 阶段转换动画
	$AnimationPlayer.play("phase_transition")
	await $AnimationPlayer.animation_finished
	vulnerable = true

func die():
	current_state = STATE.DEAD
	$AnimationPlayer.play("death")
	await $AnimationPlayer.animation_finished
	queue_free()
	# 触发胜利条件
	get_tree().call_group("game", "boss_defeated")

func update_health_bar():
	# 暂时移除血条更新
	pass

func _on_vulnerable_timer_timeout():
	vulnerable = true

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(10)