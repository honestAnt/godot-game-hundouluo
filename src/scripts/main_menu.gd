extends CanvasLayer

func _ready():
    $StartButton.connect("pressed", self, "_on_start_pressed")
    SoundManager.play_music("res://assets/music/main_theme.ogg")
    
func _exit_tree():
    SoundManager.stop_music()
    
func _on_start_pressed():
    get_tree().change_scene("res://scenes/levels/level_1.tscn")