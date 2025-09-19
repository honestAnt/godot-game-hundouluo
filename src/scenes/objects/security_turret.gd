extends StaticBody2D

# 安全炮塔脚本

export var fire_rate = 1.0
export var damage = 10
export var detection_range = 300

var time_since_last_shot = 0.0
var player = null

func _ready():
    $DetectionArea/CollisionShape2D.shape.radius = detection_range

func _process(delta):
    if player:
        time_since_last_shot += delta
        if time_since_last_shot >= fire_rate:
            shoot()
            time_since_last_shot = 0.0

func shoot():
    var bullet = preload("res://src/scenes/bullets/enemy_bullet.tscn").instance()
    bullet.global_position = $ShootPosition.global_position
    bullet.direction = (player.global_position - global_position).normalized()
    bullet.damage = damage
    get_parent().add_child(bullet)

func _on_DetectionArea_body_entered(body):
    if body.is_in_group("player"):
        player = body

func _on_DetectionArea_body_exited(body):
    if body == player:
        player = null