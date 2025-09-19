extends KinematicBody2D

# 移动平台脚本

export var move_speed = 50
export var move_distance = 200
export var move_direction = Vector2.RIGHT

var start_position = Vector2.ZERO
var move_timer = 0.0
var move_duration = 0.0

func _ready():
    start_position = position
    move_duration = move_distance / move_speed

func _physics_process(delta):
    move_timer += delta
    if move_timer > move_duration * 2:
        move_timer = 0.0
    
    var progress = sin((move_timer / move_duration) * PI)
    position = start_position + (move_direction * move_distance * progress)