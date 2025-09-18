extends Panel

signal dialogue_finished

var current_text = ""
var typing_speed = 0.05
var is_typing = false
var character_avatars = {
    "player": preload("res://assets/avatars/player.png"),
    "npc": preload("res://assets/avatars/npc.png")
}

@onready var audio_player = $AudioStreamPlayer

func show_dialogue(text, character="player"):
    $Avatar.texture = character_avatars.get(character, null)
    current_text = text
    show()
    $Label.text = ""
    is_typing = true
    for i in range(text.length()):
        $Label.text += text[i]
        _on_character_typed()
        await get_tree().create_timer(typing_speed).timeout
    is_typing = false

func _on_character_typed():
    audio_player.pitch_scale = randf_range(0.9, 1.1)
    audio_player.play()

func _input(event):
    if event.is_action_pressed("ui_accept"):
        if is_typing:
            # 快速完成当前打字效果
            $Label.text = current_text
            is_typing = false
        else:
            emit_signal("dialogue_finished")
            hide()