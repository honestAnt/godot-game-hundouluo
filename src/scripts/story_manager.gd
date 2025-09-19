extends Node

# 剧情管理器
# 负责管理游戏的整体剧情线和对话内容

# 游戏主线剧情阶段
enum STORY_PHASE {
	INTRO,           # 游戏开始
	JUNGLE_COMPLETE, # 完成丛林关卡
	WATERFALL_COMPLETE, # 完成瀑布关卡
	BASE_EXTERIOR,   # 基地外围
	BASE_INTERIOR,   # 基地内部
	FINAL_BOSS,      # 最终Boss战
	ENDING           # 游戏结局
}

# 当前剧情阶段
var current_phase = STORY_PHASE.INTRO

# 玩家选择记录
var player_choices = {}

# 剧情分支状态
var discovered_alien_tech = false
var saved_hostages = false
var destroyed_weapon_cache = false

# 关卡对话内容
var dialogues = {
	"intro": [
		"年份：2633年",
		"地点：南美洲丛林地带",
		"任务：渗透并摧毁外星势力在地球的前哨基地",
		"你是精英特种兵，代号'魂斗罗'，被派遣执行这项危险任务。"
	],
	
	"level1_start": [
		"指挥部：'魂斗罗'，你已空降至目标区域外围。",
		"指挥部：根据情报，敌人在丛林中设立了多个哨站。",
		"指挥部：清除阻碍，向瀑布方向推进。"
	],
	
	"level1_mid": [
		"这些敌人...不像普通人类士兵...",
		"他们似乎被某种技术改造过，战斗能力远超常人。"
	],
	
	"level1_end": [
		"指挥部：干得好！你已清除了丛林区域的敌人。",
		"指挥部：情报显示，瀑布后面隐藏着敌人的一个入口。",
		"指挥部：继续前进，找到那个入口。"
	],
	
	"level2_start": [
		"我们必须沿着瀑布向上攀爬，才能到达敌人的基地。",
		"情报显示这里有敌人的巡逻队，小心行动。",
		"瀑布顶端有一个隐藏的入口，那里守卫着一个精英敌人。"
	],
	
	"level2_mid": [
		"这些敌人似乎在保护什么重要的东西...",
		"继续向上，我们快到达瀑布顶端了。"
	],
	
	"level2_boss": [
		"警告：检测到强大的敌人信号！",
		"这是他们的水域守卫者，击败它才能继续前进！"
	],
	
	"level2_end": [
		"守卫者已被击败，入口已经暴露。",
		"指挥部：进入基地，但要小心，里面可能有更多危险。"
	],
	
	"level3_start": [
		"这里是敌人基地的外围防御区域。",
		"指挥部：我们检测到多个防御系统和巡逻单位。",
		"指挥部：你需要找到控制室并关闭外围防御系统。"
	],
	
	"level3_choice": [
		"你发现了两条路径：",
		"左边：似乎通向控制室，但守卫森严。",
		"右边：可能是个迂回路线，看起来较为安全。"
	],
	
	"level3_left_path": [
		"你选择了直接突破防线。",
		"这条路径危险，但可能会发现更多关于敌人的情报。"
	],
	
	"level3_right_path": [
		"你选择了迂回路线。",
		"这条路径相对安全，但可能会错过一些重要情报。"
	],
	
	"level3_secret": [
		"你发现了一个隐藏的研究室！",
		"这里有关于外星技术的资料...",
		"他们正在研究如何将人类改造成生化战士！"
	],
	
	"level3_end": [
		"外围防御系统已关闭。",
		"指挥部：干得好！现在你可以进入基地内部了。",
		"指挥部：根据新情报，敌人正在基地深处进行某种实验。"
	],
	
	"level4_start": [
		"你已进入敌人基地内部。",
		"这里到处都是实验设备和改造舱。",
		"指挥部：找到中央控制室，那里应该有关于他们计划的情报。"
	],
	
	"level4_hostages": [
		"你发现了被囚禁的人类！",
		"他们似乎是被用来做实验的对象。",
		"你可以选择救出他们，但这会引起警报。"
	],
	
	"level4_weapon_cache": [
		"你发现了一个武器库！",
		"这里储存着大量先进武器。",
		"你可以选择摧毁它，但这会引起警报。"
	],
	
	"level4_boss": [
		"警告：检测到实验体逃脱！",
		"这是他们最新的生化战士原型，非常危险！"
	],
	
	"level4_end": [
		"你已经到达了中央控制室。",
		"指挥部：下载所有数据，然后前往最深处的主实验室。",
		"指挥部：根据数据，他们的领袖就在那里。"
	],
	
	"level5_start": [
		"这里是主实验室，敌人的最后防线。",
		"指挥部：小心，我们检测到一个极其强大的能量源。",
		"指挥部：这可能是他们的领袖或者某种超级武器。"
	],
	
	"level5_boss_intro": [
		"???：欢迎，人类战士。",
		"???：你比我预想的要强大，但这里将成为你的葬身之地。",
		"???：我们的计划已经无法阻止，地球将成为我们的新家园！"
	],
	
	"level5_boss_mid": [
		"外星领袖：你的抵抗是徒劳的！",
		"外星领袖：即使你击败了我，还有更多我们的同胞正在路上！"
	],
	
	"level5_boss_end": [
		"外星领袖：不...不可能...你怎么能...",
		"外星领袖：你以为这就结束了吗？这只是开始...",
		"[领袖倒下，但基地开始自毁程序]"
	],
	
	"ending_escape": [
		"指挥部：基地即将自毁！你必须立即撤离！",
		"[你开始向出口奔跑，身后的爆炸声越来越近]"
	],
	
	"ending_good": [
		"你成功逃出了基地，任务完成！",
		"指挥部：干得好，'魂斗罗'！你成功阻止了外星人的入侵计划。",
		"指挥部：但根据你获取的数据，这可能只是他们计划的一部分...",
		"[屏幕淡出]",
		"待续..."
	],
	
	"ending_secret": [
		"你成功逃出了基地，但在最后一刻发现了一个隐藏的传送门...",
		"这个传送门似乎通向外星人的母星...",
		"你决定踏入传送门，继续你的战斗...",
		"[屏幕淡出]",
		"真正的战斗才刚刚开始..."
	]
}

# 获取特定阶段的对话
func get_dialogue(key):
	if dialogues.has(key):
		return dialogues[key]
	else:
		return ["对话内容未找到"]

# 推进剧情阶段
func advance_story_phase():
	current_phase += 1
	
	# 根据不同阶段触发特定事件
	match current_phase:
		STORY_PHASE.JUNGLE_COMPLETE:
			print("丛林关卡完成")
		STORY_PHASE.WATERFALL_COMPLETE:
			print("瀑布关卡完成")
		STORY_PHASE.BASE_EXTERIOR:
			print("进入基地外围")
		STORY_PHASE.BASE_INTERIOR:
			print("进入基地内部")
		STORY_PHASE.FINAL_BOSS:
			print("最终Boss战开始")
		STORY_PHASE.ENDING:
			_determine_ending()

# 记录玩家选择
func record_choice(choice_id, value):
	player_choices[choice_id] = value
	
	# 根据选择更新剧情状态
	match choice_id:
		"discover_alien_tech":
			discovered_alien_tech = true
		"save_hostages":
			saved_hostages = true
		"destroy_weapons":
			destroyed_weapon_cache = true

# 确定游戏结局
func _determine_ending():
	# 根据玩家选择决定结局
	if discovered_alien_tech and saved_hostages:
		return "ending_secret"  # 发现秘密结局
	else:
		return "ending_good"    # 标准好结局