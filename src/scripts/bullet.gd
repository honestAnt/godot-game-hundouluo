extends Area2D

var speed = 800
var direction = Vector2.RIGHT
var damage = 1
var penetrating = false  # 是否穿透敌人

func _ready():
	# 连接信号
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# 5秒后自动销毁
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta
	
	# 添加拖尾效果
	if randf() < 0.3:  # 30%几率生成拖尾粒子
		var trail = ColorRect.new()
		trail.color = $ColorRect.color.darkened(0.2)
		trail.color.a = 0.7  # 半透明
		trail.size = $ColorRect.size * 0.8
		trail.position = global_position
		trail.position.x -= trail.size.x / 2
		trail.position.y -= trail.size.y / 2
		get_parent().add_child(trail)
		
		# 淡出并销毁拖尾
		var tween = get_tree().create_tween()
		tween.tween_property(trail, "color:a", 0.0, 0.2)
		tween.tween_callback(trail.queue_free)

func _on_body_entered(body):
	if body.has_method("take_damage") and body != get_parent().get_node_or_null("Player"):
		body.take_damage(damage)
		if not penetrating:
			queue_free()
	elif body is StaticBody2D:
		# 撞墙效果
		for i in range(5):
			var particle = ColorRect.new()
			particle.color = $ColorRect.color
			particle.size = Vector2(2, 2)
			particle.position = global_position
			get_parent().add_child(particle)
			
			# 随机方向弹射
			var particle_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			var particle_speed = randf_range(50, 150)
			
			var tween = get_tree().create_tween()
			tween.tween_property(particle, "position", 
				particle.position + particle_dir * particle_speed, 0.5)
			tween.parallel().tween_property(particle, "color:a", 0.0, 0.5)
			tween.tween_callback(particle.queue_free)
		
		queue_free()

func set_direction(dir):
	direction = dir
	rotation = dir.angle()