import os.path
import sys

import numpy as np # linear algebra
import pandas as pd
import matplotlib.pyplot as plt
import cv2
#from sklearn.cluster import KMeans

script_path = os.path.abspath(__file__)
directory_path = script_path[:-len("PSS-color-changer.py")]

def rgb_to_hls(rgb):
    r = rgb[0]/255.0
    g = rgb[1]/255.0
    b = rgb[2]/255.0
    maxc = max(r, g, b)
    minc = min(r, g, b)
    sumc = (maxc+minc)
    rangec = (maxc-minc)
    l = sumc/2.0
    if minc == maxc:
        return 0.0, l, 0.0
    if l <= 0.5:
        s = rangec / sumc
    else:
        s = rangec / (2.0-maxc-minc)  # Not always 2.0-sumc: gh-106498.
    rc = (maxc-r) / rangec
    gc = (maxc-g) / rangec
    bc = (maxc-b) / rangec
    if r == maxc:
        h = bc-gc
    elif g == maxc:
        h = 2.0+rc-bc
    else:
        h = 4.0+gc-rc
    h = (h/6.0) % 1.0
    return [255.0*h, 255.0*l, 255.0*s]

def hls_to_space(hls, lightness_coeff = 1.0):
    r = hls[2]
    theta = hls[0]*np.pi/128.0
    return [r*np.cos(theta), r*np.sin(theta), (lightness_coeff/256.0)*r*hls[1]]

def lightness(color):
    return 0.2126 * color[0] + 0.7152 * color[1] + 0.0722 * color[2];

def change_rgb_color(color, k=0, order = [0,1,2,3]):
    k = k%4
    a = color[3]
    l = lightness(color)
    if k==order[0]:
        return [l,l,l,a]
    if k==order[1]:
        return [255,l,0,a]
    if k==order[2]:
        return [0,255,l,a]
    if k==order[3]:
        return [l,0,255,a]

def recolor_image(img, label, order = [0,1,2,3]):
    # change_col = np.vectorize(change_rgb_color)
    # img = change_col(img[:,:])
    height, width, depth = img.shape
    label_height, label_width = label.shape
    res = np.zeros(img.shape, np.uint8)
    assert height == label_height
    assert width == label_width
    for i in range(0, height):             #looping at python speed...
        for j in range(0, width):     #...
            res[i,j] = change_rgb_color(img[i,j], label[i,j], order)
    return res

def main():
    if sys.argv[1:] == [] or "-h" in sys.argv[1:] or "--help" in sys.argv[1:]:
        print("""Usage : pyhton3 PSS-color-changer.py image1 image2 ...
        [-n integer] [-l number] [-o 1123] [-s]
Cluster the colors into n (n<=4) colors depending on the hue and saturation of
the colors of an image. Then associate the shader predefined color (with same
lightness) on those clusters depending on the number of pixels in each cluster.
-n              : nombre de clusters.
-l              : lightness coefficient (1.0 by default)
--order         : color order (should have 4 digits).
-s              : save the file (False by default). If not toggle, plt.show() the
                  resulting images.
-h ou --help    : affiche ce message.""")
        return 0
    print(sys.argv)
    n = 3
    lightness_coeff = 1.0
    custom_order = False
    save_image = False
    order = []
    i = 1
    while i < len(sys.argv) and sys.argv[i] != "-n":
        i += 1
    if i < len(sys.argv)-1 and sys.argv[i] == "-n" :
        n = int(sys.argv[i+1])
        sys.argv = sys.argv[:i]+sys.argv[i+2:]
    i = 1
    while i < len(sys.argv) and sys.argv[i] != "-l":
        i += 1
    if i < len(sys.argv)-1 and sys.argv[i] == "-l" :
        lightness_coeff = float(sys.argv[i+1])
        sys.argv = sys.argv[:i]+sys.argv[i+2:]
    i = 1
    while i < len(sys.argv) and sys.argv[i] != "--order":
        i += 1
    if i < len(sys.argv)-1 and sys.argv[i] == "--order" :
        order_num = int(sys.argv[i+1])
        for v in [1000,100,10,1]:
            order.append((order_num//v)%(10))
        print(order)
        custom_order = True
        sys.argv = sys.argv[:i]+sys.argv[i+2:]
    order = np.array(order)

    i = 1
    while i < len(sys.argv) and sys.argv[i] != "-s":
        i += 1
    if i < len(sys.argv) and sys.argv[i] == "-s" :
        save_image = True
        sys.argv = sys.argv[:i]+sys.argv[i+1:]

    print("process images"+str(sys.argv[1:]))
    for arg in sys.argv[1:]:
        temp_image=cv2.imread(arg, cv2.IMREAD_UNCHANGED)
        assert temp_image is not None, "file could not be read, check with os.path.exists()"
        img = cv2.cvtColor(temp_image,cv2.COLOR_BGR2RGBA)
        img_hls = cv2.cvtColor(temp_image,cv2.COLOR_BGR2HLS)
        vectorized_hls = []#np.float32(img_hls.reshape((-1,3)))
        vectorized_rgba = np.float32(img.reshape((-1,4)))
        non_transparent_pix = (vectorized_rgba[:,3] > 32)
        nb_transparent = 0
        for i in range(0, vectorized_rgba.shape[0]):             #looping at python speed...
            if non_transparent_pix[i]: # considered not transparent
                rgb = vectorized_rgba[i,0:3]
                vectorized_hls.append(hls_to_space(rgb_to_hls(rgb), lightness_coeff))
            else:
                nb_transparent += 1
        print(nb_transparent)
        # now put lightness at 1.0

        criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 20, 1.0)
        attempts=10
        ret,label,center=cv2.kmeans(np.float32(np.array(vectorized_hls)),n,None,criteria,attempts,cv2.KMEANS_PP_CENTERS)

        if not custom_order:
            occ = [0 for i in range(0,n)]
            for i in range(0, label.shape[0]):             #looping at python speed...
                occ[label[i,0]] += 1
            order = np.flip(np.argsort(occ))

        # center = np.uint8(center)
        # res = center[label.flatten()]
        # result_image = res.reshape((img.shape))
        #color_image = recolor_image(img, label.reshape((img.shape[0:2])), order)
        height, width, depth = img.shape
        color_img = img.copy()
        k = 0
        for i in range(0, height):             #looping at python speed...
            for j in range(0, width):     #...
                if non_transparent_pix[i*width+j]:
                    color_img[i,j] = change_rgb_color(img[i,j], label[k], order)
                    k += 1

        if save_image:
            filename = arg[:len(arg)-4]+"_recolored.png"
            img = cv2.cvtColor(color_img,cv2.COLOR_RGBA2BGRA)
            cv2.imwrite(filename, img)
        else:
            figure_size = 15
            plt.figure(figsize=(figure_size,figure_size))
            plt.subplot(2,3,1),plt.imshow(img)
            plt.title('Original Image'), plt.xticks([]), plt.yticks([])
            # plt.subplot(3,3,2),plt.imshow(result_image)
            # plt.title('Segmented Image when n = %i' % n), plt.xticks([]), plt.yticks([])
            plt.subplot(2,3,2),plt.imshow(color_img)
            plt.title('Recolored Image when n = %i' % n), plt.xticks([]), plt.yticks([])
            plt.show()

if __name__ == '__main__':
    sys.exit(main())
