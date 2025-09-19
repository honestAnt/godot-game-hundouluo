extends Node2D

# Boss关卡脚本

signal level_completed

onready var boss = $Boss
onready var hazards = $Hazards

func _ready():
    boss.connect("boss_defeated", self, "_on_boss_defeated")

func _on_boss_defeated():
    # Boss被击败后，等待3秒再触发关卡完成
    yield(get_tree().create_timer(3.0), "timeout")
    emit_signal("level_completed")

func activate_hazards():
    # 激活所有竞技场危险物
    for hazard in hazards.get_children():
        hazard.activate()

func deactivate_hazards():
    # 停用所有竞技场危险物
    for hazard in hazards.get_children():
        hazard.deactivate()