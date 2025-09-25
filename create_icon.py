import numpy as np
from PIL import Image, ImageDraw

# 创建512x512黑色背景
img = Image.new('RGB', (512, 512), 'black')
draw = ImageDraw.Draw(img)

# 绘制白色外圆
draw.ellipse([(0, 0), (512, 512)], fill='white')

# 绘制黑色内圆
draw.ellipse([(100, 100), (412, 412)], fill='black')

# 保存为PNG
img.save('icon.png')
print("图标文件已创建: icon.png")