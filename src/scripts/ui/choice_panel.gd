extends Panel

signal choice_made(choice_index)

var choice_button_scene = preload("res://src/scenes/ui/choice_button.tscn")

func _ready():
    visible = false

func show_choices(title, choices):
    # 设置标题
    $Title.text = title
    
    # 清除现有选项
    for child in $ChoicesContainer.get_children():
        child.queue_free()
    
    # 添加新选项
    for i in range(choices.size()):
        var choice = choices[i]
        var button = choice_button_scene.instance()
        button.text = choice
        button.connect("pressed", self, "_on_choice_button_pressed", [i])
        $ChoicesContainer.add_child(button)
    
    # 显示面板
    visible = true

func _on_choice_button_pressed(choice_index):
    # 发送选择信号
    emit_signal("choice_made", choice_index)
    
    # 隐藏面板
    visible = false