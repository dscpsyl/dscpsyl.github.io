So you’re bored and you notice that you have so much stuff around your house. You wonder how much you spent on everything and if you made the wise decision to do so. Maybe you could’ve been a millionaire if you had invested that money instead of buying that toaster who is now tucked away in the back of your kitchen, never to see the light of your LED bulb again. You realize that the world is ending and you need to keep track of everything you own for your insurance to pay you back what you deserve. Or you realize that nothing is real and language is much better off in binary instead. Regardless, you stumble upon the magic of data matrices: small, elegant, and stores up to a whopping 3116 ASCII characters. You realize it is time to adopt them into your life.

## Goals

Today, we will be using [OpenCv2](https://opencv.org) and [Pylibdmtx](https://pypi.org/project/pylibdmtx/) to create a script that will read a data matrix from the camera and print out the data. We will also create a function that allows us to encode any data of our choice into a matrix. Finally, this will all happen on command line prompts.

## Prerequisites

- IDE (Visual Code Studio will be used in this post)
- Basic Knowledge of OpenCv2
- Good Understanding of the Python Language
- Python3 Installed

## Let’s get Started!

This program will return a string of the decoded message and write to the cwd the encoded matrix png file. You can modify it to return the decoded message or write the file somewhere else but I will not be doing that I this is my code and I’m too lazy. This code will also be completed with it looking very “debug-y”. There will be sliders and multiple video outputs as an end result. You can clean them up if you want but I find that having them here helps resolve issues on a case by case basis. Anyways, enough useless talking.

## Modules

For this we will need a few modules. First and foremost, opencv2 for python. This will allow us to process the raw video feed. Then, pylibdmtx for encoding and decoding the matrix. Specifically, we will want to import decode and encode from pylibdmtx. This is a python wrapper of libdmtx that, while very basic, works with both PIL and OpenCv2 for Python and is enough for our needs as most of the work will be handled by OpenCv2.

~~~python
from pylibdmtx.pylibdmtx import decode, encode
import cv2
~~~

Speaking of PIL, we will need to import Image from that too as while the wrapper works with OpenCv2, there are some bugs and errors that I don’t find with PIL. After that, it’s numpy so OpenCv2 can run and a few other miscellaneous modules to help us along the way.

~~~python
import numpy as np
import sys
import time
import os
from PIL import Image
~~~

## The Easy Part

Let’s get the 2 easy stuff out of the way.

### Command Line Prompt

First, we’ll create a simple prompt to give to the user that will call each function. If they don’t input a valid response, we’ll recurse and call the function again.

~~~python
def initPrompt():
    whatToDo = input("Would you like to read a Data Matrix or Create one? (r/c): ")
    if whatToDo == "r":
        readingDecode()
    elif whatToDo == "c":
        writtingEncode()
    else:
        print("That is not a valid option. Please try again...")
        initPrompt()

initPrompt()
~~~

### Encoding Data Matrix

Here is the second easy part. When the user chooses to encode the matrix, we’ll ask for the string they want to encode, encode it using pylibdmtx, use PIL to covert the bytes into a png file, and save that file to the cwd.

~~~python
def writtingEncode():
    data = input("What would you like to encode?: ")
    encoded = encode(data)
    img = Image.frombytes('RGB', (encoded.width, encoded.height), encoded.pixels)
    img.save("datamtx" + ".png")
    print("Encoded image is saved at the dir of this script.")
~~~

## The Hard Part

Here is the hard part and it will be split into two sections: defining the functions and creating the logic. We will first define the functions, some with variables that might not exist yet until we finish the logic so please be patient and we’ll get there when we get there.

### Empty Function

This is the easiest part of this program. OpenCv2’s trackbar require a function to pass to and we’ll use this one. It won’t do anything other than as a place holder for the trackbar to be happy.

~~~python
    def empty(a):
        pass
~~~

### Flip

Now the fun begins. Some camera need their cameras to be flipped. As pylibdmtx is very basic, it sometimes does not detect and flip the image by itself. If the user selects this option, we’ll let OpenCv2 flip it for us.

~~~python
    def flip():
        global flipRequired
        a = input("Does your camera need to be fliped? (y,n): ")
        if a == "y":
            flipRequired = True
        elif a == "n":
            flipRequired = False
        else:
            print("That is not a valid input. Please Try Again...")
            flip()
~~~

### Contours

Let’s get into OpenCv2. We will need to find counters from our video stream to detect where our data matrix is. We will be using this to find squares. For this function, we will pass three variables that will be created in our logic: frame, frameContour, and frameThresh. We will also want to access our global variable square. Now, let’s find the contours of our image from the frame variable. We will be using RETR_EXTERNAL as our retrieval mode and CHAIN_APPROX_NONE as no approximation for our contours. Let’s also quickly define square as False.

~~~python
def getContours(frame, frameContour, frameThresh):
        global square
        contours, hierarchy = cv2.findContours(frame,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_NONE) 
        square = False
~~~

Now, because OpenCv2 will try and find every single shape and display it, our computer is going to die. So we will need to filter it out. For this, we will filter by area and ignore all small shapes and other margin of errors from inaccuracies. To do this, let’s cycle through the found contours and get their area.

~~~python
for cnt in contours:
   cntArea = cv2.contourArea(cnt)
~~~

We will now get our area threshold from a trackbar in the logic. Then we will compare the areas and if it is bigger, we will draw it out onto the frameContour variable.

~~~python
areaThresh = cv2.getTrackbarPos("AreaThresh", parametersWindowName)
        if cntArea > areaThresh:
            cv2.drawContours(frameContour, contours, -1, (255,0,255), 3) 
~~~

After we draw it, we will need to define what shape it is. For that, we’ll grab its perimeter and approximate the number of sides. We will then use this along with the area and try to pass it onto our shape detection function. If it doesn’t work, let’s just continue and not worry about it.

~~~python
parami = cv2.arcLength(cnt, True)
approx = cv2.approxPolyDP(cnt, 0.02 * parami, True)
try: 
  shapeInfo(approx, cntArea)
except:
  continue
~~~

### Classifying Shapes

Speaking of the shape function, let’s go ahead and create that now. We will access the global variables square, upperLeft, upperRight, lowerLeft, and lowerRight to help us classify and locate it. All of these variables, besides square, should be initialized but with no value assigned to it.

~~~python
def shapeInfo(approx, cntArea):
        global square, upperLeft, upperRight, lowerLeft, lowerRight
~~~

For debugging purposes, we will create a bounding rectangle around the contour, grab its points, and draw the rectangle. We will then define our four global variables with these points as well.

~~~python
cv2.rectangle(frameContour,(x,y),(x+w, y+h),(0,255,0), 3)
upperLeft = [y, x]
lowerLeft = [y+h, x]
upperRight = [y, x+w]
lowerRight = [y+h, x+w]
~~~

We will then grab the number of points from the approx variable and, with the area, let’s print out some useful importation for the user.

~~~python
points = str(len(approx))
cv2.putText(frameContour, "Points: " + points, (x+w+20, y+h+20), cv2.FONT_HERSHEY_COMPLEX, .7, (0,255,0), 3)
cv2.putText(frameContour, "Area: " + str(cntArea), (x+w+20, y+h+45), cv2.FONT_HERSHEY_SIMPLEX, .7, (0,255,0), 3)
~~~

Now, we will try and classify the shape. Using our shape dictionary in our logic, we’ll try and print out the shape for our user. Then we’ll update the global square variable if a square has been found.

~~~python
try:
  cv2.putText(frameContour,"Shape: " + shapeDict[len(approx)], (x+w+20, y+60), cv2.FONT_HERSHEY_COMPLEX, .7, (0,255,0), 3)
  if shapeDict[len(approx)] == "Square":
      print("Found a square at [" + str(x) + "," + str(y) + "]")
      square = True
~~~

### Knowing When and Where to Stop

If we were to leave it at this, our decoding would take place the instant a square above the threshold is detected. That is not slow enough for anything to be clearly visible nor usable. So we will say that the square has to be in frame for 200 frames before a snapshot is taken. We will use the global counter variable.

~~~python
def processWrite(square, frameThresh, frameCanny, flipRequired):
    global counter, upperLeft, upperRight, lowerLeft, lowerRight
    if square == True:
        counter = counter + 1 
    if square == False:
        counter = 0
~~~

Once the counter has reached 200, it is time for the transformation to begin. We will first also use the four global corner variables to define the bounding box of our data matrix. We need to change it to a float32 type to make things a bit easier. Now we will grab the shape of our frame and also convert that to a float32 type.

~~~python
if counter > 200:
   try:  
   rows,cols = frameCanny.shape
   cornerPoints = np.float32([[upperLeft[1],upperLeft[0]],[upperRight[1],upperRight[0]],[lowerLeft[1],lowerLeft[0]],[lowerRight[1],lowerRight[0]]])
   docEdge = np.float32([[0,0],[rows,0],[0,rows],[rows,rows]])
~~~

Now we will get a transformation matrix from these points and use it to crop our image so that pylibdmtx won’t have so much noise to shuffle through. It is also here that we will be using out frameCrop variable to flip the image if necessary.

~~~python
Matrix = cv2.getPerspectiveTransform(cornerPoints,docEdge)
frameCrop = cv2.warpPerspective(frameThresh,Matrix,(cols,rows))
if flipRequired == True:
  frameCrop = cv2.flip(frameCrop, 1)
~~~

We will then write this into a temporary file on the disk and wait for once second to make sure it is fully written. Then we will call our decoding function.

~~~python
cv2.imwrite("frame.jpg", frameCrop)
time.sleep(1)
~~~

### Decoding

Let’s follow similar procedures as our Encoding The Matrix section. We will grab the newly written file and decode it. Because pylibdmtx also prints out some extra data and labels for the user to see, we will need to parse through it and only print the decoded text. Finally we will remove the temporary file and reset the counter to 0.

~~~python
    def processDecode():
        global counter
        img = cv2.imread("frame.jpg")
        result = decode(img)
        strResult = str(result[0]).split("'")
        print(strResult[1])
        counter = 0
        os.remove("frame.jpg")
~~~

### Image Outputs

For debug purposes, we will need to output multiple types of feeds so we can adjust our parameters. While we can create a separate window for everything, we can use numpy and lists to stack each feed next to each other and output it cleanly into a single window. The code explanation is outside the scope of this program and has no effect on our goals. We will be skipping it but feel free to look over it and understand how the lists are being created and manipulated.

~~~python
    def stackImages(scale,imgArray):
        rows = len(imgArray)
        cols = len(imgArray[0])
        rowsAvailable = isinstance(imgArray[0], list)
        width = imgArray[0][0].shape[1]
        height = imgArray[0][0].shape[0]
        if rowsAvailable:
            for x in range ( 0, rows):
                for y in range(0, cols):
                    if imgArray[x][y].shape[:2] == imgArray[0][0].shape [:2]:
                        imgArray[x][y] = cv2.resize(imgArray[x][y], (0, 0), None, scale, scale)
                    else:
                        imgArray[x][y] = cv2.resize(imgArray[x][y], (imgArray[0][0].shape[1], imgArray[0][0].shape[0]), None, scale, scale)
                    if len(imgArray[x][y].shape) == 2: imgArray[x][y]= cv2.cvtColor( imgArray[x][y], cv2.COLOR_GRAY2BGR)
            imageBlank = np.zeros((height, width, 3), np.uint8)
            hor = [imageBlank]*rows
            hor_con = [imageBlank]*rows
            for x in range(0, rows):
                hor[x] = np.hstack(imgArray[x])
            ver = np.vstack(hor)
        else:
            for x in range(0, rows):
                if imgArray[x].shape[:2] == imgArray[0].shape[:2]:
                    imgArray[x] = cv2.resize(imgArray[x], (0, 0), None, scale, scale)
                else:
                    imgArray[x] = cv2.resize(imgArray[x], (imgArray[0].shape[1], imgArray[0].shape[0]), None,scale, scale)
                if len(imgArray[x].shape) == 2: imgArray[x] = cv2.cvtColor(imgArray[x], cv2.COLOR_GRAY2BGR)
            hor= np.hstack(imgArray)
            ver = hor
        return ver
~~~

### Logic

Finally, it is time for the logic. Well, I say logic but it’s really just the process to call all the functions we made. The hard work is mostly done now. Let’s start by defining a few things we made references to in our functions. The four corner points, the shape dictionary, and so on.

~~~python
    upperLeft = None
    lowerLeft = None
    upperRight = None
    lowerRight = None

    shapeDict = { 2: "Circle", 8: "Circle", 9: "Circle", 4: "Square", 3: "Triangle", 5: "Triangle", 6: "Triangle" }
    counter = 0
    flipRequired = None
~~~

Next, we’re gonna call our flip function to determine if we need to reflect our feed. Then we’ll start the video capture.

~~~python
    flip() 
    inputCam = cv2.VideoCapture(0)
~~~

Remember all those parameters we created throughout our functions? We will be creating sliders for them. These sliders will be grouped into a new window. For each of them, we will pass them to the empty function that was created at the very beginning.

~~~python
    parametersWindowName = "Parameters"
    cv2.namedWindow(parametersWindowName)
    cv2.resizeWindow(parametersWindowName, 720, 480)
    cv2.createTrackbar("Threshold1", parametersWindowName, 100, 255, empty)
    cv2.createTrackbar("Threshold2", parametersWindowName, 100, 255, empty)
    cv2.createTrackbar("AreaThresh", parametersWindowName, 10000, 99999, empty)
    cv2.createTrackbar("Threshold3", parametersWindowName, 100, 255, empty)
    cv2.createTrackbar("Threshold4", parametersWindowName, 100, 255, empty)
~~~

The first number is the default value the parameter starts with. You will have to tweak these settings to find the most optimal ones for you. The second number is the max value each slider goes up to.

Now for the fun part. We will loop the collection of the camera input and for every frame, we will grab the current slider values.

~~~python
ret, frame = inputCam.read()
frame = cv2.flip(frame, 1)
threshold1 = cv2.getTrackbarPos("Threshold1", parametersWindowName)
threshold2 = cv2.getTrackbarPos("Threshold2", parametersWindowName)
threshold3 = cv2.getTrackbarPos("Threshold3", parametersWindowName)
threshold4 = cv2.getTrackbarPos("Threshold4", parametersWindowName)
~~~

Now, we will do some pre-processing on the images. We will blur it a bit, grayscale it, find the edges with canny edge detection, and threshold it. We will also dilate it a bit to get rid of anything small that we can overlook.

~~~python
frameBlur = cv2.GaussianBlur(frame, (7,7), 1)
frameGray = cv2.cvtColor(frameBlur, cv2.COLOR_BGR2GRAY)
frameCanny = cv2.Canny(frameGray, threshold1, threshold2)
ret, frameThresh = cv2.threshold(frameGray, threshold3, threshold4, cv2.THRESH_BINARY)
kernel = np.ones((4,4))
frameDial = cv2.dilate(frameCanny, kernel, iterations=1)
~~~

For this, we will work with two copies of the frame so we can see the difference. We will copy the frame image into the variable frameContour. We will then call our contour function and finally our process function.

~~~python
frameContour = frame.copy()
getContours(frameDial, frameContour, frameThresh)
processWrite(square, frameThresh, frameCanny, flipRequired)
~~~

With all that done, we will finally display everything to the user. Let’s call the stack image function to put everything into a window, and set the quit key to “q”.

~~~python
imgStack = stackImages(0.3,([frame, frameThresh, frameContour], 
[frameGray, frameCanny, frameDial]))
cv2.imshow('video', imgStack)
if cv2.waitKey(1) & 0xFF == ord('q'):
    sys.exit(0)
~~~

## Conclusion

Congratulations! You can now read and write data matrices where ever you go! Keep track of everything that you have and send secret messages to those who wonder how such a small grid can fit about 500 words. Just make sure to test out your code and adjust the parameters as you see fit. This script is very expandable and because of how we set the functions and you can use it within your own code as well. Now your next challenge is to write a script that systematically decodes layers of data matrices with a single push of a button to create the most elaborate ARG anyone has ever seen.
