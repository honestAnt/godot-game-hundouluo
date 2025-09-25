extends Control

# HUD脚本

# 节点引用
@onready var score_label = $TopBar/MarginContainer/HBoxContainer/ScoreLabel
@onready var lives_icons = $TopBar/MarginContainer/HBoxContainer/LivesContainer/LivesIcons
@onready var level_label = $TopBar/MarginContainer/HBoxContainer/LevelLabel
@onready var weapon_icon = $TopBar/MarginContainer/HBoxContainer/WeaponContainer/WeaponIcon
@onready var ammo_label = $TopBar/MarginContainer/HBoxContainer/WeaponContainer/AmmoLabel

# 资源引用
var life_icon_texture = preload("res://src/assets/sprites/ui/life_icon.tres")

# 玩家引用
var player

func _ready():
    # 初始化HUD
    update_score(0)
    update_lives(3)
    update_level(1)
    
    # 获取玩家引用
    await get_tree().process_frame
    find_player()

func _process(delta):
    # 更新武器信息
    if player:
        update_weapon_info()

func find_player():
    # 查找场景中的玩家节点
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        player = players[0]

func update_score(score):
    score_label.text = "分数: " + str(score)

func update_lives(lives):
    # 清除现有生命图标
    for child in lives_icons.get_children():
        child.queue_free()
    
    # 添加新的生命图标
    for i in range(lives):
        var icon = TextureRect.new()
        icon.texture = life_icon_texture
        icon.custom_minimum_size = Vector2(20, 20)
        lives_icons.add_child(icon)

func update_level(level):
    level_label.text = "关卡: " + str(level)

func update_weapon_info():
    # 获取当前武器信息
    var weapon_type = player.current_weapon
    var ammo = player.weapon_ammo[weapon_type]
    
    # 更新武器图标
    match weapon_type:
        player.WeaponType.NORMAL:
            weapon_icon.texture = preload("res://src/assets/sprites/ui/weapon_normal.tres")
            ammo_label.text = "∞"  # 无限弹药
        player.WeaponType.MACHINE_GUN:
            weapon_icon.texture = preload("res://src/assets/sprites/ui/weapon_machine_gun.tres")
            ammo_label.text = str(ammo)
        player.WeaponType.SPREAD:
            weapon_icon.texture = preload("res://src/assets/sprites/ui/weapon_spread.tres")
            ammo_label.text = str(ammo)
        player.WeaponType.LASER:
            weapon_icon.texture = preload("res://src/assets/sprites/ui/weapon_laser.tres")
            ammo_label.text = str(ammo)
        player.WeaponType.FLAME:
            weapon_icon.texture = preload("res://src/assets/sprites/ui/weapon_flame.tres")
            ammo_label.text = str(ammo)
        player.WeaponType.MISSILE:
            weapon_icon.texture = preload("res://src/assets/sprites/ui/weapon_missile.tres")
            ammo_label.text = str(ammo)