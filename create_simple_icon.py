# 创建简单的图标文件
from PIL import Image, ImageDraw

# 创建一个512x512的黑色图像
img = Image.new('RGB', (512, 512), color = (0, 0, 0))

# 获取绘图对象
draw = ImageDraw.Draw(img)

# 绘制白色圆形
draw.ellipse((100, 100, 412, 412), fill=(255, 255, 255))

# 绘制黑色内圆
draw.ellipse((150, 150, 362, 362), fill=(0, 0, 0))

# 保存图像
img.save('icon.png')

print("图标文件已创建")