from PIL import Image, ImageDraw
img = Image.new('RGB', (512, 512), 'blue')
draw = ImageDraw.Draw(img)
draw.ellipse((100, 100, 412, 412), fill='red')
img.save('assets/icons/app_icon.png')