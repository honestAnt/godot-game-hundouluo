extends Button

func _ready():
    connect("mouse_entered", self, "_on_mouse_entered")
    connect("mouse_exited", self, "_on_mouse_exited")

func _on_mouse_entered():
    # 鼠标悬停效果
    modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited():
    # 恢复正常
    modulate = Color(1, 1, 1)