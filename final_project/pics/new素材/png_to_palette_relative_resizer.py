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
#new_w, new_h = map(int, input("What's the new height x width? Like 28 28. ").split(' '))
new_w = 256
new_h = 256
palette_hex = ['0x000000', '0xE0F8F8', '0xF8F8F8', '0x707078', '0x686868', '0x601010', '0xE07868', '0x883800', '0xC84800', '0xf84808', '0xD87000', '0xF0A878', '0x734C10', '0xF0B800', '0xF8C800', '0xF8D088', '0xF8F800', '0xF0F890', '0x287800', '0x389800', '0x68F800', '0x185808', '0xB8F8A8', '0x20B080', '0x007048', '0x009060', '0x50E0B0', '0xB8F8F8', '0x88E0F8', '0x2888E0', '0x60B8F0', '0x0048E0', '0xF868C8', '0xF8D0F0', '0xF898D8', '0xF8A8E0', '0xF82088', '0xFA90C0', '0x880020', '0xE05078', '0xB00028', '0xD80858', '0xF878A8' ]

print "len of palette", len(palette_hex)
for i in range(len(palette_hex)):
    print "assign color[",i , "] = 24'h" + palette_hex[i][2:]
palette_rgb = [hex_to_rgb(color) for color in palette_hex]

pixel_tree = KDTree(palette_rgb)
im = Image.open("SPRITES"+ ".png") #Can be many different formats.
im = im.convert("RGBA")
im = im.resize((new_w, new_h),Image.ANTIALIAS) # regular resize
pix = im.load()
pix_freqs = Counter([pix[x, y] for x in range(im.size[0]) for y in range(im.size[1])])
pix_freqs_sorted = sorted(pix_freqs.items(), key=lambda x: x[1])
pix_freqs_sorted.reverse()
# print(pix)
outImg = Image.new('RGB', im.size, color='white')
outFile = open("SPRITES" + '.txt', 'w')
i = 0
for y in range(im.size[1]):
    for x in range(im.size[0]):
        pixel = im.getpixel((x,y))
        # print(pixel)
        if(pixel[3] < 200):
            outImg.putpixel((x,y), palette_rgb[0])
            outFile.write("%x\n" % (0))
            # print(i)
        else:
            index = pixel_tree.query(pixel[:3])[1]
            outImg.putpixel((x,y), palette_rgb[index])
            outFile.write("%x\n" % (index))
        i += 1
outFile.close()
outImg.save("SPRITES_converted" + ".png")


assign color[ 0 ] = 24'h000000
assign color[ 1 ] = 24'hE0F8F8
assign color[ 2 ] = 24'hF8F8F8
assign color[ 3 ] = 24'h707078
assign color[ 4 ] = 24'h686868
assign color[ 5 ] = 24'h601010
assign color[ 6 ] = 24'hE07868
assign color[ 7 ] = 24'h883800
assign color[ 8 ] = 24'hC84800
assign color[ 9 ] = 24'hf84808
assign color[ 10 ] = 24'hD87000
assign color[ 11 ] = 24'hF0A878
assign color[ 12 ] = 24'h734C10
assign color[ 13 ] = 24'hF0B800
assign color[ 14 ] = 24'hF8C800
assign color[ 15 ] = 24'hF8D088
assign color[ 16 ] = 24'hF8F800
assign color[ 17 ] = 24'hF0F890
assign color[ 18 ] = 24'h287800
assign color[ 19 ] = 24'h389800
assign color[ 20 ] = 24'h68F800
assign color[ 21 ] = 24'h185808
assign color[ 22 ] = 24'hB8F8A8
assign color[ 23 ] = 24'h20B080
assign color[ 24 ] = 24'h007048
assign color[ 25 ] = 24'h009060
assign color[ 26 ] = 24'h50E0B0
assign color[ 27 ] = 24'hB8F8F8
assign color[ 28 ] = 24'h88E0F8
assign color[ 29 ] = 24'h2888E0
assign color[ 30 ] = 24'h60B8F0
assign color[ 31 ] = 24'h0048E0
assign color[ 32 ] = 24'hF868C8
assign color[ 33 ] = 24'hF8D0F0
assign color[ 34 ] = 24'hF898D8
assign color[ 35 ] = 24'hF8A8E0
assign color[ 36 ] = 24'hF82088
assign color[ 37 ] = 24'hFA90C0
assign color[ 38 ] = 24'h880020
assign color[ 39 ] = 24'hE05078
assign color[ 40 ] = 24'hB00028
assign color[ 41 ] = 24'hD80858
assign color[ 42 ] = 24'hF878A8

