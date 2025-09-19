func _on_boss_area_entered(body):
    if body == player and not boss_defeated:
        # 显示Boss对话
        var boss_intro_dialogue = story_manager.get_dialogue("level5_boss_intro")
        dialogue_box.show_dialogue(boss_intro_dialogue)
        yield(dialogue_box, "dialogue_finished")
        
        # 生成最终Boss
        var boss = preload("res://src/scenes/boss.tscn").instance()
        boss.position = Vector2(1500, 600)
        boss.boss_type = "alien_leader"  # 外星领袖类型
        boss.health = 200  # 更高的生命值
        add_child(boss)
        boss.connect("health_changed", self, "_on_boss_health_changed")
        boss.connect("defeated", self, "_on_boss_defeated")

func _on_boss_health_changed(current_health, max_health):
    # 当Boss生命值降至一半时触发对话
    if current_health <= max_health / 2 and not boss_defeated:
        var boss_mid_dialogue = story_manager.get_dialogue("level5_boss_mid")
        dialogue_box.show_dialogue(boss_mid_dialogue)

func _on_boss_defeated():
    boss_defeated = true
    
    # 显示Boss被击败对话
    var boss_end_dialogue = story_manager.get_dialogue("level5_boss_end")
    dialogue_box.show_dialogue(boss_end_dialogue)
    yield(dialogue_box, "dialogue_finished")
    
    # 开始自毁序列
    _start_self_destruct_sequence()

func _start_self_destruct_sequence():
    escape_sequence_started = true
    
    # 显示逃脱对话
    var escape_dialogue = story_manager.get_dialogue("ending_escape")
    dialogue_box.show_dialogue(escape_dialogue)
    yield(dialogue_box, "dialogue_finished")
    
    # 启动自毁计时器
    self_destruct_timer.start()
    
    # 如果玩家发现了秘密，显示秘密传送门
    if secret_ending_available:
        $SecretPortalArea/CollisionShape2D.disabled = false
    else:
        $SecretPortalArea/CollisionShape2D.disabled = true