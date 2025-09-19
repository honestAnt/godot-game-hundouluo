extends Node2D

# 爆炸效果脚本

func _ready():
    # 播放爆炸动画
    $AnimationPlayer.play("explode")
    
    # 播放爆炸音效
    if has_node("/root/AudioManager"):
        get_node("/root/AudioManager").play_sound("explosion")