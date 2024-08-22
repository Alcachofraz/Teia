import skimage

path='C:/Users/pedro/Documents/Projects/teia/znoise/'
img = skimage.io.imread(path + 'image.png')/255.0

j=1
for i in range(0,100):
    img = skimage.util.random_noise(img, mode="gaussian")
    if i%99==0:
        skimage.io.imsave(path+"noise"+str(j)+".png",skimage.util.img_as_ubyte(img))
        j+=1