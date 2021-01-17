import sys
import dlib

#python3 FacePoints.py fileName

predictor_path = "shape_predictor_68_face_landmarks.dat"
f = faces_folder_path = sys.argv[1]
print("Processing file: {}".format(f))
pointsFile = open("detectedPoints.txt", "w")
detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor(predictor_path)
#load image
img = dlib.load_rgb_image(f)
#upsample the image 1 time for a better detection
dets = detector(img, 1)
#Only one face (0) in image
for k, d in enumerate(dets):
		left = d.left()
		top = d.top()
		right = d.right()
		down = d.bottom()
# Get the landmarks/parts for the face in box d.
shape = predictor(img, d)
#write 68 points in file
for i in range (shape.num_parts):
	pointsFile.write("{} {} {}\n" .format(i, shape.part(i).x, shape.part(i).y))
pointsFile.close()


	
            
