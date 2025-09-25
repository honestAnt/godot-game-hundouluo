extends Area2D

# 武器拾取脚本

# 拾取类型
@export_enum("S", "L", "F", "H", "1UP") var pickup_type = "S"

# 武器名称映射
var weapon_names = {
    "S": "散弹枪",
    "L": "激光枪",
    "F": "火焰枪",
    "H": "追踪导弹",
    "1UP": "额外生命"
}

func _ready():
    # 连接信号
    body_entered.connect(_on_body_entered)
    
    # 设置动画
    $AnimatedSprite.animation = pickup_type

func _on_body_entered(body):
    if body.is_in_group("player"):
        # 根据拾取类型给予玩家相应的武器或生命
        if pickup_type == "1UP":
            # 增加生命
            var game_manager = get_node("/root/GameManager")
            game_manager.player_lives += 1
            
            # 更新HUD
            if body.has_method("heal"):
                body.heal(100)  # 恢复满血
        else:
            # 切换武器
            var weapon_index = 0
            
            match pickup_type:
                "S":
                    weapon_index = 1  # 散弹枪
                "L":
                    weapon_index = 2  # 激光枪
                "F":
                    weapon_index = 3  # 火焰枪
                "H":
                    weapon_index = 4  # 追踪导弹
            
            # 设置玩家武器
            if body.has_method("set_weapon"):
                body.set_weapon(weapon_index)
            else:
                body.current_weapon_index = weapon_index
                body.weapon_changed.emit(body.weapons[weapon_index])
        
        # 销毁拾取物
        queue_free()