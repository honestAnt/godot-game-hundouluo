func _on_escape_area_entered(body):
    if body == player and escape_sequence_started:
        # 停止自毁计时器
        self_destruct_timer.stop()
        
        # 显示标准结局对话
        var ending_dialogue = story_manager.get_dialogue("ending_good")
        dialogue_box.show_dialogue(ending_dialogue)
        yield(dialogue_box, "dialogue_finished")
        
        # 推进剧情阶段
        story_manager.advance_story_phase()
        
        # 完成关卡
        emit_signal("level_completed")
        
        # 转到结束画面
        # get_tree().change_scene("res://src/scenes/ui/credits.tscn")

func _on_secret_portal_area_entered(body):
    if body == player and escape_sequence_started and secret_ending_available:
        # 停止自毁计时器
        self_destruct_timer.stop()
        
        # 显示秘密结局对话
        var secret_ending_dialogue = story_manager.get_dialogue("ending_secret")
        dialogue_box.show_dialogue(secret_ending_dialogue)
        yield(dialogue_box, "dialogue_finished")
        
        # 推进剧情阶段
        story_manager.advance_story_phase()
        
        # 完成关卡
        emit_signal("level_completed")
        
        # 转到秘密结局画面
        # get_tree().change_scene("res://src/scenes/ui/secret_ending.tscn")

func _on_self_destruct_timeout():
    # 自毁计时器超时，玩家未能逃脱
    # 游戏结束
    # get_tree().change_scene("res://src/scenes/ui/game_over.tscn")
    pass

func _on_choice_made(choice_index):
    # 处理选择结果
    pass

func _on_checkpoint_reached(checkpoint_id):
    current_checkpoint = checkpoint_id
    # 保存游戏状态
    # GameSave.save_checkpoint(level_name, checkpoint_id)

func _process(delta):
    # 如果自毁序列已启动，更新UI显示剩余时间
    if escape_sequence_started and self_destruct_timer.time_left > 0:
        var time_left = int(self_destruct_timer.time_left)
        $UI/HUD.update_timer(time_left)