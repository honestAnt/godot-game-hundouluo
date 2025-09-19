extends Control

# 关卡过渡画面脚本

# 节点引用
onready var level_label = $LevelLabel
onready var animation_player = $AnimationPlayer

func set_level(level_number):
    # 设置关卡编号
    level_label.text = "关卡 " + str(level_number)

func play_transition():
    # 播放过渡动画
    animation_player.play("fade_in_out")