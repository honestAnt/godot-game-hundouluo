extends Node2D

func _ready():
    # 连接测试按钮
    $UI/TestControls/DamageButton.pressed.connect(_on_damage_button_pressed)
    $UI/TestControls/RageButton.pressed.connect(_on_rage_button_pressed)
    $UI/TestControls/DesperateButton.pressed.connect(_on_desperate_button_pressed)
    
    # 连接Boss血量变化
    $Boss/Health.hp_changed.connect(_on_boss_hp_changed)
    
    # 启动Boss攻击计时器
    $Boss/AttackTimer.start()

func _on_damage_button_pressed():
    # 对Boss造成100点伤害
    $Boss/Health.take_damage(100)

func _on_rage_button_pressed():
    # 强制进入狂暴模式
    $Boss/Health.current_health = $Boss/Health.health_max * 0.5
    $Boss._on_hp_changed($Boss/Health.current_health)

func _on_desperate_button_pressed():
    # 强制进入绝望模式
    $Boss/Health.current_health = $Boss/Health.health_max * 0.25
    $Boss._on_hp_changed($Boss/Health.current_health)

func _on_boss_hp_changed(new_hp):
    # 更新UI血条
    var percent = float(new_hp) / $Boss/Health.health_max * 100
    $UI/BossHealth.value = percent