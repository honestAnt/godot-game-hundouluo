# 魂斗罗复刻项目 (Contra Remake)

## 项目简介

这是一个使用Godot 4引擎开发的红白机经典游戏《魂斗罗》(Contra)的复刻版本。项目完整实现了原版游戏的核心玩法，包括横版射击、多种武器系统、敌人AI以及Boss战斗等特色内容。

## 目录结构

```
godot-game-hundouluo/
├── assets/                  # 游戏资源文件
│   ├── animations/          # 动画资源
│   ├── icons/               # 图标资源
│   └── sprites/             # 精灵图资源
│       ├── boss.png         # Boss角色贴图
│       ├── enemies/         # 敌人贴图
│       ├── player/          # 玩家角色贴图
│       └── weapons/         # 武器贴图
├── src/                     # 源代码目录
│   ├── animations/          # 动画资源文件
│   ├── assets/              # 项目资源
│   ├── bullets/             # 子弹系统
│   │   ├── Bullet.gd        # 基础子弹脚本
│   │   ├── Bullet.tscn      # 基础子弹场景
│   │   ├── CircleBullet.gd  # 全屏弹幕脚本
│   │   └── CircleBullet.tscn # 全屏弹幕场景
│   ├── dialogue/            # 对话系统
│   ├── scenes/              # 游戏场景
│   │   ├── boss.tscn        # Boss战斗场景
│   │   ├── levels/          # 关卡场景
│   │   ├── main.tscn        # 主场景
│   │   ├── player.tscn      # 玩家场景
│   │   └── ui/              # UI场景
│   ├── scripts/             # 游戏脚本
│   │   ├── boss.gd          # Boss行为脚本
│   │   ├── Health.gd        # 血量系统脚本
│   │   ├── player.gd        # 玩家控制脚本
│   │   ├── game_manager.gd  # 游戏管理脚本
│   │   └── ui/              # UI脚本
│   └── test/                # 测试场景
│       ├── BossTestScene.gd # Boss测试脚本
│       └── BossTestScene.tscn # Boss测试场景
└── project.godot            # Godot项目文件
```

## 核心系统说明

### 玩家系统
- 8方向移动与射击
- 多种武器切换机制
- 跳跃与卧倒动作
- 生命系统与无敌帧

### 武器系统
- 机枪(M): 连发子弹
- 散弹(S): 多方向射击
- 激光(L): 穿透型射线
- 火焰(F): 范围伤害

### 敌人系统
- 基础敌人: 固定位置射击
- 巡逻敌人: 沿路径移动
- 飞行敌人: 空中攻击
- 精英敌人: 特殊攻击模式

### Boss系统
- 三阶段状态机
  - 正常模式: 扇形弹幕攻击
  - 狂暴模式: 冲刺攻击
  - 绝望模式: 全屏弹幕+自爆
- 血量触发状态转换
- 独特攻击模式与动画

### 关卡系统
- 多样化地形设计
- 检查点系统
- 武器收集点
- 隐藏区域

## 如何运行

1. 安装Godot 4.x版本
2. 克隆本仓库
3. 使用Godot打开project.godot文件
4. 点击运行按钮或按F5启动游戏

## 控制方式

- 方向键: 移动
- Z键: 射击
- X键: 跳跃
- 下+X: 卧倒
- ESC: 暂停菜单

## 开发团队

- 程序设计: [honestAnt + AI]
- 美术资源: 基于原版魂斗罗素材
- 音效: 基于原版魂斗罗音效

## 许可证

本项目仅用于学习和研究目的，不得用于商业用途。
所有原始游戏资源的版权归原始版权所有者所有。

## Disclaimer

⚠️ **Important Notice**

This project is provided for demonstration and educational purposes only. Please consider the following before using this code:

1. **No Warranty**: This software is provided "as is" without warranty of any kind, either express or implied. The entire risk as to the quality and performance of the software is with you.

2. **Use at Your Own Risk**: The authors and contributors are not responsible for any damage, loss, or security issues that may occur from using this software.

3. **Production Use**: While efforts have been made to ensure quality, this code may not be suitable for production environments without thorough testing and security review.

4. **Third-party Dependencies**: This project relies on third-party libraries and tools. Please review their respective licenses and terms of use.

5. **Modification**: Users are encouraged to review and modify the code according to their specific requirements and security standards.

6. **Support**: This project is provided without any guarantee of support or maintenance.

7. **Attribution**: When referencing or reproducing content from this project, please retain the original source address and give proper attribution to the original authors.

By using this software, you agree to these terms and acknowledge that you understand the risks involved.