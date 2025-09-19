extends StaticBody2D

# 自动门脚本

export var open_speed = 2.0
export var close_speed = 1.5
export var stay_open_time = 3.0

var is_open = false
var is_opening = false
var is_closing = false
var timer = 0.0
var original_position = Vector2.ZERO

func _ready():
    original_position = position
    $DetectionArea.connect("body_entered", self, "_on_body_entered")
    $DetectionArea.connect("body_exited", self, "_on_body_exited")

func _process(delta):
    if is_opening:
        position.y = lerp(position.y, original_position.y - 64, open_speed * delta)
        if position.y <= original_position.y - 64:
            is_opening = false
            is_open = true
            $CollisionShape2D.disabled = true
    elif is_closing:
        position.y = lerp(position.y, original_position.y, close_speed * delta)
        if position.y >= original_position.y - 1:
            position.y = original_position.y
            is_closing = false
            is_open = false
            $CollisionShape2D.disabled = false
    elif is_open:
        timer += delta
        if timer >= stay_open_time:
            close_door()

func _on_body_entered(body):
    if body.is_in_group("player") and not is_open and not is_opening:
        open_door()

func _on_body_exited(body):
    if body.is_in_group("player") and is_open:
        timer = stay_open_time - 1.0  # 开始关闭倒计时

func open_door():
    is_opening = true
    is_closing = false
    timer = 0.0

func close_door():
    if is_open and not is_closing:
        is_closing = true
        is_open = false
        timer = 0.0