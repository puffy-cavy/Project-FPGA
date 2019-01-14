from PIL import Image
from collections import Counter
from scipy.spatial import KDTree
import numpy as np
def hex_to_rgb(num):
    h = str(num)
    return int(h[0:4], 16), int(('0x' + h[4:6]), 16), int(('0x' + h[6:8]), 16)
def rgb_to_hex(num):
    h = str(num)
    return int(h[0:4], 16), int(('0x' + h[4:6]), 16), int(('0x' + h[6:8]), 16)
# filename = input("What's the image name? ")
# new_w, new_h = map(int, input("What's the new height x width? Like 28 28. ").split(' '))
new_w = 512
new_h = 384
palette_hex = ['0x000000','0xffffff','0x747474','0xb7b7b7','0x37132a','0x6d3959','0xad809c','0xbe4e93','0xe196c4','0xeb58b3','0xba0545','0xf766a4','0xfd81c9']
print"number color:", len(palette_hex)
palette_rgb = [hex_to_rgb(color) for color in palette_hex]

pixel_tree = KDTree(palette_rgb)
im = Image.open("./sprite_originals/" + "kirby1" + ".png") #Can be many different formats.
im = im.convert("RGBA")
im = im.resize((new_w, new_h),Image.ANTIALIAS) # regular resize
pix = im.load()
pix_freqs = Counter([pix[x, y] for x in range(im.size[0]) for y in range(im.size[1])])
pix_freqs_sorted = sorted(pix_freqs.items(), key=lambda x: x[1])
pix_freqs_sorted.reverse()
print(pix)
outImg = Image.new('RGB', im.size, color='white')
outFile = open("./sprite_bytes/" + "kirby1" + '.txt', 'w')
i = 0
for y in range(im.size[1]):
    for x in range(im.size[0]):
        pixel = im.getpixel((x,y))
        #print(pixel)
        if(pixel[3] < 200):
            outImg.putpixel((x,y), palette_rgb[0])
            outFile.write("%x\n" % (0))
            print(i)
        else:
            index = pixel_tree.query(pixel[:3])[1]
            outImg.putpixel((x,y), palette_rgb[index])
            outFile.write("%x\n" % (index))
        i += 1
outFile.close()
outImg.save("./sprite_converted/" + "kirby1" + ".png")
