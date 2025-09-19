extends Area2D

# 水流区域脚本

export var current_strength = 100
export var current_direction = Vector2.DOWN

func _ready():
    connect("body_entered", self, "_on_body_entered")
    connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
    if body.is_in_group("player"):
        body.set_water_current(current_direction * current_strength)

func _on_body_exited(body):
    if body.is_in_group("player"):
        body.set_water_current(Vector2.ZERO)