extends Node2D

signal level_completed

# 关卡配置
var level_name = "主实验室"
var level_difficulty = 5
var boss_enabled = true

# 游戏状态
var player
var dialogue_box
var choice_panel
var current_checkpoint = 0
var boss_defeated = false
var escape_sequence_started = false
var secret_ending_available = false

# 故事管理器引用
onready var story_manager = get_node("/root/StoryManager")
onready var self_destruct_timer = $SelfDestructTimer

func _ready():
    # 初始化引用
    player = $Player
    dialogue_box = $UI/DialogueBox
    choice_panel = $UI/ChoicePanel
    
    # 连接信号
    dialogue_box.connect("dialogue_finished", self, "_on_dialogue_finished")
    choice_panel.connect("choice_made", self, "_on_choice_made")
    $BossArea.connect("body_entered", self, "_on_boss_area_entered")
    $EscapeArea.connect("body_entered", self, "_on_escape_area_entered")
    $SecretPortalArea.connect("body_entered", self, "_on_secret_portal_area_entered")
    self_destruct_timer.connect("timeout", self, "_on_self_destruct_timeout")
    
    # 显示开场对话
    _show_intro_dialogue()
    
    # 检查是否可以触发秘密结局
    secret_ending_available = story_manager.discovered_alien_tech and story_manager.saved_hostages