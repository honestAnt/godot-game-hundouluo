extends Button

func _ready():
    connect("mouse_entered", _on_hover)
    
func _on_hover():
    modulate = Color(1.2, 1.2, 1.2)