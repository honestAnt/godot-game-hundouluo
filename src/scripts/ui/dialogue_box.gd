extends Panel

signal dialogue_finished
signal dialogue_next

var dialogue_lines = []
var current_line = 0
var is_typing = false

@onready var dialogue_text = $MarginContainer/VBoxContainer/DialogueText
@onready var continue_button = $MarginContainer/VBoxContainer/HBoxContainer/ContinueButton
@onready var animation_player = $MarginContainer/VBoxContainer/DialogueText/AnimationPlayer

func _ready():
    # 初始化时隐藏对话框
    visible = false
    
    # 连接按钮信号
    continue_button.pressed.connect(_on_continue_pressed)
    
    # 连接动画完成信号
    animation_player.animation_finished.connect(_on_animation_finished)

func show_dialogue(lines):
    # 设置对话内容
    dialogue_lines = lines
    current_line = 0
    
    # 显示对话框
    visible = true
    
    # 显示第一行对话
    _show_next_line()

func _show_next_line():
    if current_line < dialogue_lines.size():
        # 获取当前行文本
        var line = dialogue_lines[current_line]
        
        # 设置文本内容
        dialogue_text.text = line
        dialogue_text.percent_visible = 0
        
        # 播放文本显示动画
        is_typing = true
        animation_player.play("text_reveal")
        
        # 发送下一行对话信号
        emit_signal("dialogue_next", current_line)
        
        # 增加行计数
        current_line += 1
    else:
        # 所有对话显示完毕
        visible = false
        emit_signal("dialogue_finished")

func _on_continue_pressed():
    if is_typing:
        # 如果正在打字，则立即显示全部文本
        dialogue_text.percent_visible = 1.0
        animation_player.stop()
        is_typing = false
    else:
        # 否则显示下一行对话
        _show_next_line()

func _on_animation_finished(anim_name):
    if anim_name == "text_reveal":
        is_typing = false

func _input(event):
    # 按空格键或回车键继续对话
    if visible and event is InputEventKey and event.pressed:
        if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
            _on_continue_pressed()
            get_tree().set_input_as_handled()