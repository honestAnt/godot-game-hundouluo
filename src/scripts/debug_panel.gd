extends Panel

func _ready():
    $VBoxContainer/BtnReload.connect("pressed", self, "_on_reload_pressed")
    $VBoxContainer/BtnTestDamage.connect("pressed", self, "_on_test_damage_pressed")
    $VBoxContainer/BtnAddScore.connect("pressed", self, "_on_add_score_pressed")
    $VBoxContainer/BtnToggleDebug.connect("pressed", self, "_on_toggle_pressed")

func _input(event):
    if event.is_action_pressed("debug_toggle"):
        visible = not visible
        get_tree().set_input_as_handled()

func _on_reload_pressed():
    get_tree().reload_current_scene()

func _on_test_damage_pressed():
    if has_node("/root/UI"):
        get_node("/root/UI").health -= 1

func _on_add_score_pressed():
    if has_node("/root/UI"):
        get_node("/root/UI").score += 1000

func _on_toggle_pressed():
    visible = not visible