extends CharacterBody2D

# 敌人子弹脚本

# 子弹参数
@export var speed = 300
@export var damage = 10
var direction = Vector2.LEFT

# 节点引用
@onready var hit_area = $HitArea
@onready var life_timer = $LifeTimer
@onready var animated_sprite = $AnimatedSprite

func _ready():
	# 连接信号
	hit_area.body_entered.connect(_on_hit_body)
	life_timer.timeout.connect(_on_lifetime_end)
	
	# 启动生命周期计时器
	life_timer.start()

func _physics_process(delta):
	# 移动子弹
	velocity = direction * speed
	var collision = move_and_slide()
	if get_slide_collision_count() > 0:
		# 检查碰撞对象
		var collider = get_slide_collision(0).get_collider()
		if collider.is_in_group("player"):
			collider.take_damage(damage)
		
		# 销毁子弹
		queue_free()

func _on_hit_body(body):
	# 检查碰撞对象
	if body.is_in_group("player"):
		body.take_damage(damage)
	
	# 销毁子弹
	queue_free()

func _on_lifetime_end():
	# 子弹生命周期结束，销毁子弹
	queue_free()

func set_damage(value):
	damage = value
