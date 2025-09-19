extends Area2D

# 攀爬区域脚本

func _ready():
    connect("body_entered", self, "_on_body_entered")
    connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
    if body.is_in_group("player"):
        body.set_climbing(true)

func _on_body_exited(body):
    if body.is_in_group("player"):
        body.set_climbing(false)