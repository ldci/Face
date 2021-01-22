Red [
	Title:   "Faces Processing"
	Author:  "Francois Jouen"
	File: 	 %face.red
	Needs:	 View
]
;--Adapt to your configuration
home: select list-env "HOME"
appDir: rejoin [home "/Programmation/Red/Face"]
change-dir to-file appDir
landmarksFile: 	%config/landmarks.jpg
glossFile: 		%config/glossaire.txt
configFile: 	%config/config.txt 
resultFile: 	%detectedPoints.txt

;--required redCV libs
#include %redCV/libs/core/rcvCore.red
#include %redCV/libs/tools/rcvTools.red
#include %redCV/libs/matrix/rcvMatrix.red
#include %redCV/libs/imgproc/rcvImgProc.red
#include %redCV/libs/imgproc/rcvColorSpace.red

;--Dlib python script: python3 required!
prog: rejoin ["python3 " appDir "/FacePoints.py '"]

margins: 10x10
gsize:	450x500
gsize2: centerXY: gsize / 2
rotation: 	copy []
rot: 		0.0
sFactor: 	1.0
transl: 	0x0
nbPMax: 73
isFile?: isCorrectedImage?: isNumbered?: isSource?: false
isThermic?: isQuit?: true
colorSpace: 1
canvas: canvas1: canvas2: canvas3: none
img:	make image! 10x10
img0:	make image! 10x10
img1:	make image! 10x10
img2:	make image! 10x10
hsv:	make image! 10x10

filePath:  fileName: file!
ext: ""

imageName: imageCName: pointsFile: fileResult: thermCName: file!
glossaire: 		copy []
count: 			0
separator: 		tab
cfactor: 		14x0 		;--for landmark
listNPoint: 	copy []		;--number
listLPoints:	copy []		;--label	
listeMP: 		copy []
drawBlock: 		copy []
convex:			copy []

; variables pour les calculs
sLowFaceR:		0.0		;surface Lower Area right
sLowFaceL:		0.0		;surface Lower Area left
sMiddleFaceR:	0.0		;surface Median Area right
sMiddleFaceL:	0.0		;surface Median Area left
sSubNasalR:		0.0		;surface Sub Nasal right
sSubNasalL:		0.0		;surface Sub Nasal left 
sOrbitalR:		0.0		;surface Orbital right
sOrbitalL:		0.0		;surface Orbital left
sChinR:			0.0		;surface Chin right
sChinL:			0.0		;surface Chin left
sMandR: 		0.0		;surface Mandidulo-jugal right
sMandL: 		0.0		;surface Mandidulo-jugal left
sFacialTotal:	0.0		;surface Total Facial 
sFacialMiddle:	0.0		;surface Median Area
sFacialLow:		0.0		;surface Lower Area
sRightHemiface:	0.0		;surface Hemiface right 
sLeftHemiface:	0.0		;surface Hemiface left
hFacialSup:		0.0		;height Lower Facial Area
hFacialMiddle:	0.0		;height Median Facial Area
hFacialInf:		0.0		;height Lower FacialArea
hFacialTotal:	0.0		;height Total Facial Area

rVertical1:		0.0		;height ratio 
rVertical2:		0.0		;height ratio 
rVertical3:		0.0		;height ratio 

rOrbital1:		0.0		;Orbital Development ratio  
rOrbital2:		0.0		;Orbital Development ratio  
rOrbital3:		0.0		;Orbital Development ratio  
rOrbital4:		0.0		;Orbital Development ratio  
rOrbital5:		0.0		;Orbital Development ratio  

rHemiFace1:		0.0		;Hemiface ratio 
rHemiFace2:		0.0		;Hemiface ratio 
rHemiFace3:		0.0		;Hemiface ratio 

rMiddleFace1:	0.0		;Median Area ratio
rMiddleFace2:	0.0		;Median Area ratio
rMiddleFace3:	0.0		;Median Area ratio
rMiddleFace4:	0.0		;Median Area ratio
rMiddleFace5:	0.0		;Median Area ratio
rMiddleFace6:	0.0		;Median Area ratio

rLowFace1:		0.0		;Lower Area ratio
rLowFace2:		0.0		;Lower Area ratio
rLowFace3:		0.0		;Lower Area ratio
rLowFace4:		0.0		;Lower Area ratio
rLowFace5:		0.0		;Lower Area ratio
rLowFace6:		0.0		;Lower Area ratio

rChin1:			0.0		;Chin ratio
rChin2:			0.0		;Chin ratio
rChin3:			0.0		;Chin ratio
rChin4:			0.0		;Chin ratio
rChin5:			0.0		;Chin ratio

rMand1:			0.0		;Mandidular ratio
rMand2:			0.0		;Mandidular ratio
rMand3:			0.0		;Mandidular ratio
rMand4:			0.0		;Mandidular ratio
rMand5:			0.0		;Mandidular ratio

rNasal1:		0.0		;Sub-Nasal ratio
rNasal2:		0.0		;Sub-Nasal ratio
rNasal3:		0.0		;Sub-Nasal ratio
rNasal4:		0.0		;Sub-Nasal ratio
rNasal5:		0.0		;Sub-Nasal ratio

aRightEye:		0.0		;angle 
aLeftEye:		0.0		;angle 
aBichelion: 	0.0		;angle 
aBicanthal: 	0.0		;angle 

measures: [
	"All Landmarks" 
	"---------Heights---------"
	"Upper Vertical Axis" 
	"Median Vertical Axis"  
	"Lower Vertical Axis" 
	"Median line" 
	"---------Surfaces---------"
	"Ocular Surface" 
	"Jugal Surface" 
	"Chin Surface" 
	"Sub Nasal Area" 
	"Lower Facial Area" 
	"Median Facial Area" 
	"Hemiface"  
	"----------Angles-----------"
	"Bicanthal line" 
	"Bichelion" 
	"Eyes"
]

palette: ["RGB" "BGR" "RGB2HSV" "BGR2HSV" "RGB2HLS" "BGR2HLS" "Grayscale"]

;--points for computation
p1: p2: p3: p4: p5: p6: p7: p8: p9: p10: 0x0

;--Landmarks draw 
dBlock: 	[pen blue fill-pen pink triangle 7x7 14x0 21x7]		; defaut
dMblock:	[pen blue fill-pen yellow triangle 7x7 14x0 21x7] 	; median
dRBlock:	[pen blue fill-pen green triangle 7x7 14x0 21x7]	; right
dLBlock:	[pen blue fill-pen red triangle 7x7 14x0 21x7]		; left

smallFont: make font! [
			name: "Arial" 
			size: 9
			anti-alias?: yes
]

;--read landmarks glossary
readGlossary: does [
	glossaire: read/lines glossFile
	n: length? glossaire
	detail/data: 	copy []
	listNPoint: 	copy []		; numero
	listLPoints:	copy []		; label
	repeat i n [
		append detail/data glossaire/:i
		s: split glossaire/:i separator
		append listNPoint to-integer s/1
		append listLPoints s/3
	]
]

;--read selected landmarks
readConfig: does [
	confLM: read/lines configFile
	n: length? confLM
	i: 2 ; first line: "Vertex" 
	while [i <= n] [
		m: rejoin ["m" confLM/:i "/data: true"]
		do m
		i: i + 1
	]
]

;--save selected landmarks
saveConfig: does [
	write configFile rejoin ["Vertex" newline]
	i: 0 
	; which selected vertices?
	while [i < nbPMax] [
		m: to-word rejoin ["m" i]
		if select get m 'data [; ' 
			s: rejoin [form i lf]
			write/append configFile s
		]
		i: i + 1
	]
]	

;--73 landmarks from 0 to 72
generateMarks: func [nbPMax [integer!]][
	i: 0
	offs: canvas2/offset ; 512x86 
	listeMP: copy []
	while [i < nbPMax] [
		mp: to-word rejoin ["mp" i]
		mp: make face! [
				type: 'base 
				offset: 0x0
				size: 28x28
				color: glass 
				text: form i
				visible?: false
				extra: rejoin ["mp" form i]
				data: i
				options: [drag-on: 'down]
				font: smallFont
				
				actors: object [
					on-drag-start: func [face [object!] event [event!]][
						sb2/text: face/extra
						coordList/selected: face/data + 1
						idx: index? find listNPoint face/data ; which mark
						sb4/text: listLPoints/:idx			  ; mark label
					]
					on-drag: func [face [object!] event [event!]][
						;-- calculate mouse position
						sb3/text: form face/offset - offs + cfactor
					]	
					on-drop: function [face [object!] event [event!]][
						 coordList/data/(1 + face/data): rejoin [face/extra " : "  form face/offset - offs + cfactor]
						 coordList/selected: face/data + 1
					]	
				]
				draw: dBlock
		]
		append mainWin/pane mp
		append listeMP mp
	i: i + 1	
	]
]	

;--select or unselect all landmarks
setAllMarks: function [nbPMax [integer!] flag [logic!]] [
	i: 0
	while [i < nbPMax] [
		m: rejoin ["m" form i "/data: " flag]
		do m
		i: i + 1
	]
]

;--source image
getMarks: does [
	coordList/data: copy []
	result: read/lines resultFile 
	;--which selected vertices?
	i: 0
	while [i <= (nbPMax - 6)] [
		m: to-word rejoin ["m" i]
		mp: listeMP/(i + 1)
		str: split result/(i + 1) " "
		;--landmarks coordinates
		p: as-pair to-integer second str to-integer third str
		append coordList/data rejoin [mp/extra " : " form p]
		p: p + canvas2/offset - cfactor; modification pour affichage dans le canvas
		mp/offset: p 
		if select get m 'data [;'	
			mp/visible?: true
			either isNumbered? [mp/text: form i] [mp/text: none]
		]
		i: i + 1
	]
	;--supplementary landmarks
	while [i < nbPMax] [
		m: to-word rejoin ["m" i]
		mp: listeMP/(i + 1)
		case [
			i = 68 [p: 120x200]
			i = 69 [p: 225x150]
			i = 70 [p: 325x200]
			i = 71 [p: 225x250]
			i = 72 [p: 0x0]
		]
		append coordList/data rejoin [mp/extra " : " form p]
		if select get m 'data [;'
			mp/visible?: true
			either isNumbered? [mp/text: form i] [mp/text: none]
			p: p + canvas2/offset - cfactor; modification pour affichage dans le canvas
			mp/offset: p
		]
		i: i + 1
	]
	coordList/selected: 1
]
;--processed image
getMarks2: does [
	coordList/data: copy []
	result: read/lines pointsFile
	;--which selected vertices?
	i: 0
	while [i < nbPMax] [
		m: to-word rejoin ["m" i]
		mp: listeMP/(i + 1)
		str: split result/(i + 1) " "
		; les coordonnées calculées par le réseau
		p: as-pair to-integer second str to-integer third str
		append coordList/data rejoin [mp/extra " : " form p]
		p: p + canvas2/offset - cfactor; modification pour affichage dans le canvas
		mp/offset: p 
		if select get m 'data [;'	
			mp/visible?: true
			either isNumbered? [mp/text: form i] [mp/text: none]
			if any [i = 66 i = 69 i = 71 i = 28 i = 33 i = 51 i = 8] [mp/draw: dMblock]
			if any [i = 0 i = 2 i = 4 i = 6 i = 17 i = 19 i = 21 
					i = 36 i = 39 i = 40 i = 41 i = 31 i = 48 i = 68] [mp/draw: dRblock]
			if any [i = 70 i = 16 i = 14 i = 12 i = 10 i = 26 i = 24 i = 22 
					i = 45 i = 42 i = 47 i = 46 i = 35 i = 54 i = 70] [mp/draw: dLblock]
		]
		i: i + 1
	]
	coordList/selected: 1
	s: split coordList/data/1  ":"
	sb2/text: s/1
	sb3/text: s/2
]

;--show selected landmarks
showMarks: function [flag [logic!]] [
	i: 0
	while [i < nbPMax] [
		m: to-word rejoin ["m" i]
		if select get m 'data [
			;'
			mp: listeMP/(i + 1)
			mp/visible?: flag
		]
		i: i + 1
	]
]

;--save landmarks changes
saveMarks: does [
	if isFile? [ 
		either isCorrectedImage? [
			write pointsFile "";rejoin ["Points" newline]
			i: 0
			while [i < (nbPMax)] [
				s: split coordList/data/(i + 1)  ":"
				xy: to pair! second s
				s2: rejoin [form i " " xy/x " " xy/y newline]
				write/append pointsFile s2
			i: i + 1
			]
			sb1/text: "Landmarks are saved"
		] [Alert "Detect landmarks first" isCorrectedImage?: false]
	]
]

;--images
;--flag 0: source image 
;--flag 1: processed image 

loadImage: func [flag [integer!]] [
	tmp: request-file
	if not none? tmp [
		gsize: 450x500 
		coordList/data: copy []
		calcul/text: copy ""
		clear sb2/text
		clear sb3/text
		clear sb4/text
		showMarks false
		rotation: copy []
		canvas1/image: canvas1/draw: canvas2/image: canvas2/draw: none
		mainWin/text: rejoin ["CHArt/R2P2: Face [" to-string tmp "]"]
		filePath: first split-path tmp
		fileName: second split-path tmp
		imageName: to-string fileName	;--file without or with extension
		if not none? suffix? fileName [
			n: length? fileName
			nn: n - 4
			imageName: to-string copy/part fileName nn
		]
		;--create required files
		imageCName: to-file rejoin [filePath imageName "C.png"]
		pointsFile: to-file rejoin [filePath imageName "P.txt"]
		fileResult: to-file rejoin [filePath imageName "R.txt"]
		thermCName: to-file rejoin [filePath imageName "Therm.png"]
		prog: rejoin ["python3 " appDir "/FacePoints.py '" to-string imageCName "'" ]
		img0: load tmp
		hsv: rcvCloneImage img0
		
		if img0/size/x < img0/size/y [
			ratio: to-float img0/size/x / to-float img0/size/y
			gSize/x: to-integer gSize/y * ratio
		]
		
		if img0/size/x > img0/size/y [
			ratio: to-float img0/size/y / to-float img0/size/x
			gSize/y: to-integer gSize/x * ratio
		]
		img1: rcvResizeImage hsv gSize / 2 
		transl: (canvas1/size - img1/size) / 2
		bl: compose [translate (transl)image img1]
		canvas1/draw: reduce [bl]
		if flag = 0 [
			img2: rcvResizeImage hsv gSize; image source
			; rotation can be used
			centerXY: img2/size / 2 
			sl/data: 50%
			rot: 0.0
			rotF/text: "0 degree"
			transl: (canvas2/size - img2/size) / 2
			rotation: compose [scale (sFactor) (sFactor) 
							   translate (transl) 
							   rotate (rot) (centerXY) 
							   image img2
			]
			canvas2/draw: reduce [rotation]	
		]
		if flag = 1 [
			img2: load imageCName ; image modifiée pas de rotation
			canvas2/image: img2
		]
		count: flag
		if flag = 0 [
			sl/visible?: rotF/visible?: isSource?: true
			bm/visible?: bp/visible?: true
			isCorrectedImage?: isCorrectedImage: false
			sb1/text: copy "Loaded file: source  image "
			append append append sb1/text "[" form img0/size " pixels]"
			append append append sb1/text "[" form img2/size " pixels]"
		]
		if flag = 1 [
			getMarks2 
			sl/visible?: rotF/visible?: isSource?: false
			bm/visible?: bp/visible?: false
			isCorrectedImage?: isCorrectedImage: true
			sb1/text: copy "Loaded file: processed image "
			append append append sb1/text "[" form img2/size " pixels]"
		]
		isFile?: true
	]
]

saveCorrectedImage: does [
	either isFile? [
		img: to-image canvas2
		save/as imageCName img 'png ;'
		sb1/text: copy "Image  "
		fName:  second split-path imageCName
		append append sb1/text  to-string fName " saved" 
		isCorrectedImage: true
		
	] [Alert "Load source image !"]
]

processCorrectedImage: does [
	if isFile? [
		either isCorrectedImage [
			sb1/text: "Patience! Landmarks identification" 
			do-events/no-wait
			isCorrectedImage?: false
				if isSource? [
					;--source image: calculate and save 73 landmarks
					t1: now/time/precise
					if count = 0 [call/wait prog getMarks] 
					t2: now/time/precise
					elapsed: round/to (third t2 - third t1) 0.01
					isCorrectedImage?: true
					saveMarks
					sb1/text: rejoin ["Landmarks identified and saved in " form elapsed " sec"]
				] 
			getMarks2
			count: count + 1
			isCorrectedImage?: true
			img2: load imageCName
			canvas2/draw: none
			canvas2/image: none
			canvas2/image: img2
			sl/visible?: rotF/visible?: isSource?: false
			bm/visible?: bp/visible?: false
		]
		[Alert "Save Image First"]
	]
]

;--general function to calculate surface of convex polygons
contourArea: function [hull [block!] return: [float!]
][
	b: copy hull
	n: length? b
	append b first b
	sum1: sum2: 0.0
	repeat i n [
		sum1: sum1 + (b/(i)/x * b/(i + 1)/y)
		sum2: sum2 + (b/(i)/y * b/(i + 1)/x)
	]
	absolute (sum1 - sum2) / 2.0
]

;--distances and angles functions
getEuclidianDistance: function [p1 [pair!] p2 [pair!] return: [float!]]
[
	x2: (p1/x - p2/x) * (p1/x - p2/x)
	y2: (p1/y - p2/y) * (p1/y - p2/y)
	sqrt (x2 + y2) 
]

;--get angle in degrees from points coordinates
GetAngle: function [pa1 [pair!] pa2 [pair!] return: [float!]][		
	rho: getEuclidianDistance pa1 pa2		; rho
	uY: to-float pa1/y - pa2/y				; uY ->
	uX: to-float pa1/x - pa2/x				; uX ->	
	costheta: uX / rho
	sinTheta: uY / rho
	tanTheta: costheta / sinTheta 
	theta: arccosine costheta
	theta
]

;--show all landmarks
getAllPoints: does [
	clear sb4/text
	calcul/text: copy ""
	clear drawBlock
	clear detail/data
	n: length? glossaire
	repeat i n [append detail/data glossaire/:i]
	img2: load imageCName 
	canvas2/image: draw img2 drawBlock
	getMarks2
]

;-------------------- Angles ------------------------
;--eyes angulation
getEyesAngles: func [return: [block!]] [
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "D9" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "D10" 	[p2: p append detail/data glossaire/:i]
		if s/2 = "G9" 	[p3: p append detail/data glossaire/:i]
		if s/2 = "G10"  [p4: p append detail/data glossaire/:i]
		i: i + 1
	]
	reduce [round/to 180.0 - GetAngle p1 p2 0.01 round/to 0.0 + GetAngle p3 p4 0.01]
]

;--show eyes angles and result
showEyesAngle: does [	
	showMarks false
	clear drawBlock
	clear detail/data
	aRightEye: first getEyesAngles
	either aRightEye > 0.0 [label: " : mongoloïd"] [label: " : anti-mongoloïd"]
	append append append append calcul/text "Right Eye: " form aRightEye  label lf
	drawBlock: compose [line-width 2 pen green line (p1) (p2)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
	aLeftEye: second getEyesAngles 
	either aLeftEye > 0.0 [label: " : mongoloïd"] [label: " : anti-mongoloïd"]
	append append append append calcul/text "Left Eye: " form aLeftEye  label lf 
	drawBlock: compose [line-width 2 pen red line (p3) (p4)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p3) 3.0 circle (p4) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
]

;--buccal line 
getCommisural: func [return: [float!]] [
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "D14" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "G14"  [p2: p append detail/data glossaire/:i]
		i: i + 1
	]
	showMarks false
	either p2/y >= p1/y [round/to negate 180.0 - GetAngle p1 p2 0.01] 
						[round/to 180.0 - GetAngle p1 p2 0.01]
]

;--show result
showCommisuralAngle: does [
	clear drawBlock
	clear detail/data
	aBichelion: getCommisural
	append append append calcul/text "Buccal line deviation  from horizontal:  " form aBichelion lf
	drawBlock: compose [line-width 2 pen yellow line (p1) (p2)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock 
]

;--canthal line
getCanthal: func [return: [float!]] [
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "D9" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "G9"   [p2: p append detail/data glossaire/:i]
		i: i + 1
	]
	
	either p2/y >= p1/y [round/to negate 180.0 - GetAngle p1 p2 0.01] 
						[round/to 180.0 - GetAngle p1 p2 0.01]
	
]

showCanthalAngle: does [
	clear drawBlock
	clear detail/data
	aBicanthal: getCanthal
	append append append calcul/text "Canthal line deviation from horizontal:  " form aBicanthal lf
	showMarks false
	drawBlock: compose [line-width 2 pen yellow line (p1) (p2)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
]

;---------------- Height -------------------------
;--Upper Facial Height
getVerticalAxisSup: func [return: [float!]] [
	drawBlock: copy []
	n: length? glossaire
	i: 1
	detail/data: copy []
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "M1" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "M2"   [p2: p append detail/data glossaire/:i]
		i: i + 1
	]
	
	getEuclidianDistance p2 p1
]
showVerticalAxisSup: does [
	clear drawBlock
	clear detail/data
	hFacialSupr: getVerticalAxisSup
	showMarks false
	drawBlock: compose [line-width 2 pen yellow line (p1) (p2)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
]


;--Median Facial Height
getVerticalAxisMiddle: func [return: [float!]] [
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "M2" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "M3"   [p2: p append detail/data glossaire/:i]
		if s/2 = "M4"   [p3: p append detail/data glossaire/:i]
		if s/2 = "M5"   [p4: p append detail/data glossaire/:i]
		i: i + 1
	]
	getEuclidianDistance p4 p1
]

showVerticalAxisMiddle: does [
	clear drawBlock
	clear detail/data
	hFacialMiddle: getVerticalAxisMiddle
	showMarks false
	drawBlock: compose [line-width 2 pen yellow line (p1) (p2) (p3) (p4)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p4) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
]

;--Lower Facial Height
getVerticalAxisInf: func [return: [float!]] [
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "M5" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "M6"   [p2: p append detail/data glossaire/:i]
		i: i + 1
	]
	getEuclidianDistance p2 p1
]

showVerticalAxisInf: does [
	clear drawBlock
	clear detail/data
	hFacialInf: getVerticalAxisInf
	showMarks false
	drawBlock: compose [line-width 2 pen yellow line (p1) (p2)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
]

;--Facial Height
getVerticalAxis: func [return: [float!]] [
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "M1" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "M2" 	[p2: p append detail/data glossaire/:i]
		if s/2 = "M3" 	[p3: p append detail/data glossaire/:i]
		if s/2 = "M4" 	[p4: p append detail/data glossaire/:i]
		if s/2 = "M5" 	[p5: p append detail/data glossaire/:i]
		if s/2 = "M6"   [p6: p append detail/data glossaire/:i]
		i: i + 1
	]
	getEuclidianDistance p6 p1
]

showVerticalAxis: does [
	clear drawBlock
	clear detail/data
	hFacialTotal: getVerticalAxis
	showMarks false
	drawBlock: compose [line-width 2 pen orange line (p1) (p2) (p3) (p4) (p5) (p6)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0 circle (p5) 3.0 circle (p6) 3.0
		]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
]

;-------------------- Surfaces ------------------------------
;--Right Lower Facial Area
getRightLowFace: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "M5" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "D3"   [p2: p detail/data glossaire/:i]
		if s/2 = "D4"   [p3: p append detail/data glossaire/:i]
		if s/2 = "D5"   [p4: p append detail/data glossaire/:i]
		if s/2 = "M6"   [p5: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append append convex p1 p2 p3 p4 p5
	contourArea convex
]

;--Left Lower Facial Area
getLeftLowFace: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "M5" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "G3"   [p2: p append detail/data glossaire/:i]
		if s/2 = "G4"   [p3: p append detail/data glossaire/:i]
		if s/2 = "G5"   [p4: p append detail/data glossaire/:i]
		if s/2 = "M6"   [p5: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append append convex p1 p2 p3 p4 p5
	contourArea convex
]

;--Lower Facial Area
showLowFace: does [
	clear drawBlock
	clear detail/data
	r: getRightLowFace
	showMarks false
	drawBlock: compose [line-width 2 pen green polygon (p1) (p2) (p3) (p4) (p5) 
						pen off pen yellow line (p1) (p5)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0  circle (p5) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
	r: getLeftLowFace
	showMarks false
	drawBlock: compose [line-width 2 pen red polygon (p1) (p2) (p3) (p4) (p5) 
						pen off pen yellow line (p1) (p5)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0  circle (p5) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
]

;--Right Median Facial Area
getRightMiddleFace: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "M2" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "D7"   [p2: p append detail/data glossaire/:i]
		if s/2 = "D1"   [p3: p append detail/data glossaire/:i]
		if s/2 = "D2"   [p4: p append detail/data glossaire/:i]
		if s/2 = "D3"   [p5: p append detail/data glossaire/:i]
		if s/2 = "M5"   [p6: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append append append convex p1 p2 p3 p4 p5 p6
	contourArea convex
]

;--Left Median Facial Area
getLeftMiddleFace: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "M2" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "G7"   [p2: p append detail/data glossaire/:i]
		if s/2 = "G1"   [p3: p append detail/data glossaire/:i]
		if s/2 = "G2"   [p4: p append detail/data glossaire/:i]
		if s/2 = "G3"   [p5: p append detail/data glossaire/:i]
		if s/2 = "M5"   [p6: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append append append convex p1 p2 p3 p4 p5 p6
	contourArea convex
]

;--Median Facial Area
showMiddleFace: does [
	clear drawBlock
	clear detail/data
	r: getRightMiddleFace
	showMarks false
	drawBlock: compose [line-width 2 pen green polygon (p1) (p2) (p3) (p4) (p5) (p6)
						pen off pen yellow line (p1) (p6)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0  circle (p5) 3.0 circle (p6) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
	l: getLeftMiddleFace
	drawBlock: compose [line-width 2 pen red polygon (p1) (p2) (p3) (p4) (p5) (p6)
						pen off pen yellow line (p1) (p6)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0  circle (p5) 3.0 circle (p6) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
]

;--Right Orbital Area
getRightOrbital: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "D8" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "D7"   [p2: p append detail/data glossaire/:i]
		if s/2 = "D6"   [p3: p append detail/data glossaire/:i]
		if s/2 = "D9"   [p4: p append detail/data glossaire/:i]
		if s/2 = "D12"  [p5: p append detail/data glossaire/:i]
		if s/2 = "D11"  [p6: p append detail/data glossaire/:i]
		if s/2 = "D10"  [p7: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append append append append convex p1 p2 p3 p4 p5 p6 p7
	contourArea convex
]

;--Left Orbital Area
getLeftOrbital: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "G8" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "G7"   [p2: p append detail/data glossaire/:i]
		if s/2 = "G6"   [p3: p append detail/data glossaire/:i]
		if s/2 = "G9"   [p4: p append detail/data glossaire/:i]
		if s/2 = "G12"  [p5: p append detail/data glossaire/:i]
		if s/2 = "G11"  [p6: p append detail/data glossaire/:i]
		if s/2 = "G10"  [p7: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append append append append convex p1 p2 p3 p4 p5 p6 p7
	contourArea convex
]

;--Right SubNasal Area						
getRightSubNasal: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "M5" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "D13"  [p2: p append detail/data glossaire/:i]
		if s/2 = "D14"  [p3: p append detail/data glossaire/:i]
		if s/2 = "S1"  	[p4: p append detail/data glossaire/:i]
		if s/2 = "M6"   [p5: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append append convex p1 p2 p3 p4 p5
	contourArea convex
]

;--Left SubNasal Area	
getLeftSubNasal: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "M5" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "G13"  [p2: p append detail/data glossaire/:i]
		if s/2 = "G14"  [p3: p append detail/data glossaire/:i]
		if s/2 = "S1"  	[p4: p append detail/data glossaire/:i]
		if s/2 = "M6"   [p5: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append append convex p1 p2 p3 p4 p5
	contourArea convex
]
;--SubNasal Area	
showSubnasal: does [
	clear drawBlock
	clear detail/data
	r: getRightSubNasal
	showMarks false
	drawBlock: compose [line-width 2 pen green polygon (p1) (p2) (p3) (p4)  pen yellow line (p1) (p4)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0 circle (p4) 3.0]
		append drawBlock d
	]
	g13: p3
	canvas2/image: draw img2 drawBlock
	l: getLeftSubNasal
	d13: p3
	drawBlock: compose [line-width 2 pen red polygon (p1) (p2) (p3) (p4) pen yellow line (p1) (p4)
	pen off pen yellow line (g13) (d13)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0 circle (p5) 3.0 ]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
]

;--Right Chin Area	
getRightChin: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "S1" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "D14"  [p2: p append detail/data glossaire/:i]
		if s/2 = "D5"   [p3: p append detail/data glossaire/:i]
		if s/2 = "M6"  	[p4: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append convex p1 p2 p3 p4
	contourArea convex
]

;--Left Chin Area
getLeftChin: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "S1" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "G14"  [p2: p append detail/data glossaire/:i]
		if s/2 = "G5"   [p3: p append detail/data glossaire/:i]
		if s/2 = "M6"  	[p4: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append convex p1 p2 p3 p4
	contourArea convex
]

;--Chin Area
showChin: does [
	clear drawBlock
	clear detail/data
	r: getRightChin
	showMarks false
	drawBlock: compose [line-width 2 pen green polygon (p1) (p2) (p3) (p4)  pen yellow line (p1) (p4)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0 ]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
	l: getLeftChin
	drawBlock: compose [line-width 2 pen red polygon (p1) (p2) (p3) (p4) pen yellow line (p1) (p4)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0 ]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
]

;--Right Mandibular Area
getRightMand: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "D3" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "D4" 	[p2: p append detail/data glossaire/:i]
		if s/2 = "D5"   [p3: p append detail/data glossaire/:i]
		if s/2 = "D14"  [p4: p append detail/data glossaire/:i]
		if s/2 = "D13"  [p5: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append append convex p1 p2 p3 p4 p5
	contourArea convex
]

;--Left Mandibular Area
getLeftMand: func [return: [float!]] [
	clear convex
	n: length? glossaire
	i: 1
	while [i <= n] [
		s: split glossaire/:i separator
		pointNum: 1 + to-integer s/1
		s2: split coordList/data/(pointNum)  ":"
		p: to pair! second s2 
		if s/2 = "G3" 	[p1: p append detail/data glossaire/:i]
		if s/2 = "G4" 	[p2: p append detail/data glossaire/:i]
		if s/2 = "G5"   [p3: p append detail/data glossaire/:i]
		if s/2 = "G14"  [p4: p append detail/data glossaire/:i]
		if s/2 = "G13"  [p5: p append detail/data glossaire/:i]
		i: i + 1
	]
	append append append append append convex p1 p2 p3 p4 p5
	contourArea convex
]
;--Mandibular Area
showMand: does [
	clear drawBlock
	clear detail/data
	r: getRightMand
	showMarks false
	drawBlock: compose [line-width 2 pen green polygon (p1) (p2) (p3) (p4) (p5)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0 circle (p5) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
	l: getLeftMand
	drawBlock: compose [line-width 2 pen red polygon (p1) (p2) (p3) (p4) (p5)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0 circle (p5) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
]

;-------------------------- Computations ---------------------------

showRatio: function [s1 [string!]  s2 [string!] rValue [float!] lValue [float!] ratio [float!]][
	append calcul/text rejoin [s1 form rValue lf] 
	append calcul/text rejoin [s2 form lValue lf]
	append calcul/text rejoin ["Ratio: " form round/to ratio 0.001 lf]
	append calcul/text lf
]


showMedianLine: does [
	hFacialSup: getVerticalAxisSup
	hFacialMiddle: getVerticalAxisMiddle
	hFacialInf: getVerticalAxisInf
	hFacialTotal: getVerticalAxis ;hFacialSup + hFacialMiddle + hFacialInf
	rVertical1: round/to hFacialSup / hFacialTotal 0.001
	append calcul/text rejoin ["Upper Facial Height / Total :  " form rVertical1 lf]
	rVertical2: round/to hFacialMiddle / hFacialTotal 0.001
	append calcul/text rejoin ["Median Facial Height / Total  :  " form rVertical2 lf]
	rVertical3: round/to hFacialInf / hFacialTotal 0.001
	append calcul/text rejoin ["Lower Facial Height /Total  :  " form rVertical3 lf]
	showVerticalAxis
]

showOrbitalR: does [
	drawBlock: copy []
	detail/data: copy []
	sFacialLow: getLeftLowFace + getRightLowFace
	sFacialMiddle: getRightMiddleFace + getLeftMiddleFace
	sFacialTotal: sFacialLow + sFacialMiddle
	detail/data: copy []
	showMarks false
	sOrbitalR: getRightOrbital
	drawBlock: compose [line-width 2 pen green polygon (p1) (p2) (p3) (p4) (p5) (p6) (p7)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0 circle (p5) 3.0 circle (p6) 3.0
			circle (p7) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
	sOrbitalL: getLeftOrbital
	drawBlock: compose [line-width 2 pen red polygon (p1) (p2) (p3) (p4) (p5) (p6) (p7)]
	if cbPoints/data [
		d: compose [pen orange fill-pen orange circle (p1) 3.0 circle (p2) 3.0
			circle (p3) 3.0 circle (p4) 3.0 circle (p5) 3.0 circle (p6) 3.0
			circle (p7) 3.0]
		append drawBlock d
	]
	canvas2/image: draw img2 drawBlock
	rOrbital1: round/to sOrbitalR / sFacialTotal 0.001
	rOrbital2: round/to sOrbitalR / sFacialMiddle 0.001
	rOrbital3: round/to sOrbitalL / sFacialTotal 0.001
	rOrbital4: round/to sOrbitalL / sFacialMiddle 0.001
	rOrbital5: round/to sOrbitalR / sOrbitalL 0.001
	;detail/data: copy []
	showRatio "Right Orbital Surface : " "Facial Surface: " sOrbitalR sFacialTotal rOrbital1
	showRatio "Right Orbital Surface: " "Median Area Surface: " sOrbitalR sFacialMiddle rOrbital2
	showRatio "Left Orbital Surface: " "Facial Surface: " sOrbitalL sFacialTotal rOrbital3
	showRatio "Left Orbital Surface: " "Median  Area Surface: " sOrbitalL sFacialMiddle rOrbital4
	showRatio "Right Orbital Developement: " 
			  "Left Orbital Developement: " sOrbitalR  sOrbitalL rOrbital5
]

showHemiFaceR: does [
	drawBlock: copy []
	detail/data: copy []
	sFacialLow: getLeftLowFace + getRightLowFace
	sFacialMiddle: getRightMiddleFace + getLeftMiddleFace
	sFacialTotal: sFacialLow + sFacialMiddle
	sLowFaceR: getRightLowFace
	showMarks false
	sLowFaceL: getLeftLowFace
	sMiddleFaceR: getRightMiddleFace
	sMiddleFaceL: getLeftMiddleFace
	sRightHemiface:	sLowFaceR + sMiddleFaceR
	sLeftHemiface:	sLowFaceL + sMiddleFaceL
	rHemiFace1: round/to sRightHemiface / sFacialTotal 0.001
	rHemiFace2: round/to sLeftHemiface / sFacialTotal 0.001
	rHemiFace3: round/to sRightHemiface / sLeftHemiface 0.001
	showLowFace
	showMiddleFace
	showRatio "Right Hemi Surface: " "Facial Surface: " sRightHemiface sFacialTotal rHemiFace1
	showRatio "Left Hemi Surface: " "Facial Surface: " sLeftHemiface sFacialTotal rHemiFace2
	showRatio "Right Hemi Surface: " "Left Hemi Surface: " sRightHemiface sLeftHemiface rHemiFace3
]

showMidFaceR: does [
	sFacialLow: getLeftLowFace + getRightLowFace
	sFacialMiddle: getRightMiddleFace + getLeftMiddleFace
	sFacialTotal: sFacialLow + sFacialMiddle
	sMiddleFaceR: getRightMiddleFace
	sMiddleFaceL: getLeftMiddleFace
	drawBlock: copy []
	detail/data: copy []
	showMarks false
	showMiddleFace
	rMiddleFace1:	round/to sFacialMiddle / sFacialTotal 0.001
	rMiddleFace2:	round/to sMiddleFaceR / sFacialTotal 0.001
	rMiddleFace3:	round/to sMiddleFaceR / sFacialMiddle 0.001
	rMiddleFace4:	round/to sMiddleFaceL / sFacialTotal 0.001
	rMiddleFace5:	round/to sMiddleFaceL / sFacialMiddle 0.001
	rMiddleFace6:	round/to sMiddleFaceR / sMiddleFaceL 0.001
	showRatio "Median Area: " "Facial Surface: " sFacialMiddle sFacialTotal rMiddleFace1
	showRatio "Right Median Area: " "Facial Surface: " sMiddleFaceR sFacialTotal rMiddleFace2
	showRatio "Right Median Area: " "Median Area: " sMiddleFaceR sFacialMiddle rMiddleFace3	
	showRatio "Left Median Area: " "Facial Surface: " sMiddleFaceL sFacialTotal rMiddleFace4
	showRatio "Left Median Area: " "Median Area: " sMiddleFaceL sFacialMiddle rMiddleFace5						
	showRatio "Right Median Area: " "Left Median Area: " sMiddleFaceR sMiddleFaceL rMiddleFace6
]

showLowFaceR: does [
	drawBlock: copy []
	detail/data: copy []
	sFacialLow: getLeftLowFace + getRightLowFace
	sFacialMiddle: getRightMiddleFace + getLeftMiddleFace
	sFacialTotal: sFacialLow + sFacialMiddle
	sLowFaceR: getRightLowFace
	sLowFaceL: getLeftLowFace
	showMarks false
	showLowFace
	rLowFace1:	round/to sFacialLow / sFacialTotal 0.001
	rLowFace2:	round/to sLowFaceR / sFacialTotal 0.001
	rLowFace3:	round/to sLowFaceR / sFacialLow 0.001
	rLowFace4:	round/to sLowFaceL / sFacialTotal 0.001
	rLowFace5:	round/to sLowFaceL / sFacialLow 0.001
	rLowFace6:	round/to sLowFaceR / sLowFaceL 0.001
	showRatio "Lower Area: " "Facial Surface: " sFacialLow sFacialTotal rLowFace1
	showRatio "Right Lower Area: " "Facial Surface: " sLowFaceR sFacialTotal rLowFace2
	showRatio "Right Lower Area: " "Lower Area: " sLowFaceR sFacialLow rLowFace3	
	showRatio "Left Lower Area: " " Facial Surface: " sLowFaceL sFacialTotal rLowFace4
	showRatio "Left Lower Area: " "Lower Area: " sLowFaceL sFacialLow rLowFace5						
	showRatio "Right Lower Area: " "Left Lower Area: " sLowFaceR sLowFaceL rLowFace6
]

showChinR: does [
	drawBlock: copy []
	detail/data: copy []
	sFacialLow: getLeftLowFace + getRightLowFace
	sFacialMiddle: getRightMiddleFace + getLeftMiddleFace
	sFacialTotal: sFacialLow + sFacialMiddle
	sChinR: getRightChin
	sChinL: getLeftChin
	showMarks false
	showChin
	rChin1: round/to sChinR / sFacialTotal 0.001
	rChin2: round/to sChinR / sFacialLow 0.001
	rChin3: round/to sChinL / sFacialTotal 0.001
	rChin4: round/to sChinL / sFacialLow 0.001
	rChin5: round/to sChinR / sChinL 0.001
	showRatio "Right Sub-Chin: " "Facial Surface : " sChinR sFacialTotal rChin1
	showRatio "Right Sub-Chin: " "Lower Area: " sChinR sFacialLow rChin2
	showRatio "Left Sub-Chin: " "Facial Surface : " sChinL sFacialTotal rChin3
	showRatio "Left Sub-Chin: " "Lower Area: " sChinL sFacialLow rChin4
	showRatio "Right Sub-Chin: " "Left Sub-Chin: " sChinR sChinL rChin5
]

showMandR: does [
	drawBlock: copy []
	detail/data: copy []
	sFacialLow: getLeftLowFace + getRightLowFace
	sFacialMiddle: getRightMiddleFace + getLeftMiddleFace
	sFacialTotal: sFacialLow + sFacialMiddle
	sMandR: getRightMand
	sMandL: getLeftMand
	showMarks false
	showMand
	rMand1: round/to sMandR / sFacialTotal 0.001
	rMand2: round/to sMandR / sFacialLow 0.001
	rMand3: round/to sMandL / sFacialTotal 0.001
	rMand4: round/to sMandL / sFacialLow 0.001
	rMand5: round/to sMandR / sMandL 0.001
	showRatio "Right Mandibulo-jugal: " "Facial Surface : " sMandR sFacialTotal rMand1
	showRatio "Right Mandibulo-jugal: " "Lower Area: " sMandR sFacialLow rMand2
	showRatio "Left Mandibulo-jugal: " "Facial Surface : " sMandL sFacialTotal rMand3
	showRatio "Left Mandibulo-jugal: " "Lower Area: " sMandL sFacialLow rMand4
	showRatio "Right Mandibulo-jugal: " "Left Mandibulo-jugal: " sMandR sMandL rMand5
]

showNasalR: does [
	sFacialLow: getLeftLowFace + getRightLowFace
	sFacialMiddle: getRightMiddleFace + getLeftMiddleFace
	sFacialTotal: sFacialLow + sFacialMiddle
	drawBlock: copy []
	detail/data: copy []
	sSubNasalR: getRightSubNasal sSubNasalL: getLeftSubNasal showSubnasal
	rNasal1: round/to sSubNasalR / sFacialTotal 0.001
	rNasal2: round/to sSubNasalR / sFacialLow 0.001
	rNasal3: round/to sSubNasalL / sFacialTotal 0.001
	rNasal4: round/to sSubNasalL / sFacialLow 0.001
	rNasal5: round/to sSubNasalR / sSubNasalL 0.001
	showRatio "Right Sub Nasal : " "Facial Surface : " sSubNasalR sFacialTotal rNasal1
	showRatio "Right Sub Nasal : " "Lower Area: " sSubNasalR sFacialLow rNasal2
	showRatio "Left Sub Nasal : " "Facial Surface : " sSubNasalR sFacialTotal rNasal3
	showRatio "Left Sub Nasal : " "Lower Area: " sSubNasalR sFacialLow rNasal4
	showRatio "Right Sub Nasal : " "Left Sub Nasal : " sSubNasalR  sSubNasalL rNasal5
]

exportResults: does [
	sb1/text: "Computing ..."
	do-events/no-wait
	showMedianLine
	showOrbitalR
	showMandR
	showChinR
	showNasalR
	showLowFaceR
	showMidFaceR
	showHemiFaceR
	showCanthalAngle
	showCommisuralAngle
	showEyesAngle
	
	write fileResult rejoin[to-string fileName separator]
	; hauteurs
	write/append fileResult rejoin [rVertical1 separator]
	write/append fileResult rejoin [rVertical2 separator]
	write/append fileResult rejoin [rVertical3 separator]
	;surfaces orbitales
	write/append fileResult rejoin [rOrbital1 separator]
	write/append fileResult rejoin [rOrbital2 separator]
	write/append fileResult rejoin [rOrbital3 separator]
	write/append fileResult rejoin [rOrbital4 separator]
	write/append fileResult rejoin [rOrbital5 separator]
	;surfaces jugales
	write/append fileResult rejoin [rMand1 separator]
	write/append fileResult rejoin [rMand2 separator]
	write/append fileResult rejoin [rMand3 separator]
	write/append fileResult rejoin [rMand4 separator]
	write/append fileResult rejoin [rMand5 separator]
	;surfaces mentonnières
	write/append fileResult rejoin [rChin1 separator]
	write/append fileResult rejoin [rChin2 separator]
	write/append fileResult rejoin [rChin3 separator]
	write/append fileResult rejoin [rChin4 separator]
	write/append fileResult rejoin [rChin5 separator]
	;surfaces sous nasales
	write/append fileResult rejoin [rNasal1 separator]
	write/append fileResult rejoin [rNasal2 separator]
	write/append fileResult rejoin [rNasal3 separator]
	write/append fileResult rejoin [rNasal4 separator]
	write/append fileResult rejoin [rNasal5 separator]
	;surfaces Etage inférieur
	write/append fileResult rejoin [rLowFace1 separator]
	write/append fileResult rejoin [rLowFace2 separator]
	write/append fileResult rejoin [rLowFace3 separator]
	write/append fileResult rejoin [rLowFace4 separator]
	write/append fileResult rejoin [rLowFace5 separator]
	write/append fileResult rejoin [rLowFace6 separator]
	;surfaces Median Area
	write/append fileResult rejoin [rMiddleFace1 separator]
	write/append fileResult rejoin [rMiddleFace2 separator]
	write/append fileResult rejoin [rMiddleFace3 separator]
	write/append fileResult rejoin [rMiddleFace4 separator]
	write/append fileResult rejoin [rMiddleFace5 separator]
	write/append fileResult rejoin [rMiddleFace6 separator]
	;surfaces Hemiface
	write/append fileResult rejoin [rHemiFace1 separator]
	write/append fileResult rejoin [rHemiFace2 separator]
	write/append fileResult rejoin [rHemiFace3 separator]
	;angles
	write/append fileResult rejoin [aBicanthal separator]
	write/append fileResult rejoin [aBichelion separator]
	write/append fileResult rejoin [aRightEye separator]
	write/append fileResult rejoin [aLeftEye separator lf]
	sb1/text: "Results saved"
	
]
showResults: does [
	rcalcul/text: copy " "
	rr: read/lines fileResult
	n: length? rr
	repeat i n [append append rcalcul/text rr/:i newline]
	;rcalcul/text: form read/lines fileResult
	view/flags resultWin ['modal 'no-buttons]
]

;-------------------- Windows ------------------------

markWin: layout [
	title "LandMarks"
	origin margins space margins
	button "All Landmarks"		[setAllMarks nbPMax true]
	button "Clear Landmarks"	[setAllMarks nbPMax false]
	button "Save Landmarks"		[saveConfig]
	pad 280x0 	
	button "Close Window" 		[unview/only markWin]
	return
	space 10x5
	m0: check 40 "0"  
	m1: check 40 "1" m2: check 40 "2" m3: check 40 "3" 
	m4: check 40 "4" m5: check 40 "5" m6: check 40 "6" m7: check 40 "7" 
	m8: check 40 "8" m9: check 40 "9" m10: check 40 "10" m11: check 40 "11" 
	m12: check 40 "12" m13: check 40 "13" m14: check 40 "14" m15: check 40 "15" 
	return
	m16: check 40 "16" m17: check 40 "17" m18: check 40 "18" m19: check 40 "19" 
	m20: check 40 "20" m21: check 40 "21" m22: check 40 "22" m23: check 40 "23" 
	m24: check 40 "24" m25: check 40 "25" m26: check 40 "26" m27: check 40 "27" 
	m28: check 40 "28" m29: check 40 "29" m30: check 40 "30" m31: check 40 "31" 
	return
	m32: check 40 "32" m33: check 40 "33" m34: check 40 "34" m35: check 40 "35" 
	m36: check 40 "36" m37: check 40 "37" m38: check 40 "38" m39: check 40 "39" 
	m40: check 40 "40" m41: check 40 "41" m42: check 40 "42" m43: check 40 "43" 
	m44: check 40 "44" m45: check 40 "45" m46: check 40 "46" m47: check 40 "47" 
	return
	m48: check 40 "48" m49: check 40 "49" m50: check 40 "50" m51: check 40 "51" 
	m52: check 40 "52" m53: check 40 "53" m54: check 40 "54" m55: check 40 "55" 
	m56: check 40 "56" m57: check 40 "57" m58: check 40 "58" m59: check 40 "59" 
	m60: check 40 "60" m61: check 40 "61" m62: check 40 "62" m63: check 40 "63" 
	return
	m64: check 40 "64" m65: check 40 "65" m66: check 40 "66" m67: check 40 "67" 
	m68: check 40 cyan "68" m69: check 40 cyan "69" m70: check 40  cyan "70" 
	m71: check cyan 40 "71" m72: check cyan 40 "72"
	return 
	pad 90x10
	canvas3:  base 640x480 landmarksFile
]

quitRequested: does [
	view/flags confirmWin ['modal 'no-buttons]
	if isQuit? [
		if exists? %hsv.png [call/wait "rm hsv.png"]
		if exists? %tempo.png [call/wait "rm tempo.png"]
		quit
	]
]

openExcel: does [
	tmp: request-file/filter ["Excel Files" "*.xlsx"] 
	if not none? tmp [call rejoin [open tmp]]
]

resultWin: layout [
	title "Results"
	pad 380x0 button "Close Window" [unview/only resultWin]
	return
	rcalcul: area 500x128 
]

captureWin: layout [
	title "Capture"
	button "Save Capture"	[
			either isThermic? [
				fn: request-file/save/filter/file ["Thermal Images" "*.png"] thermCName]
			[fn: request-file/save]
			if not none? fn [save/as fn to-image canvas 'png] ;'only png	
	]
	pad 220x0
	button "Close window" [unview/only captureWin]
	return
	canvas: base 450x500
]

confirmWin: layout [
	title "Confirmation"
	pad 45x0
	text 180 "Quit Face Program?"
	return
	pad 40x0 
	Button "Yes" [isQuit?: true  unview/only confirmWin]
	button "No" [isQuit?: false unview/only confirmWin]	
]

mainWin: layout [
	title "CHArt/R2P2: Face"
	origin margins space margins
	style rect: base 255.255.255.240 28x28 loose draw [pen navy line-width 2 box 0x0 16x10]
	style rHLine: base red 460x3 loose
	style rVLine: base red 3x510 loose
	button "Source Image"			[loadImage 0]
	button "Save Image "			[saveCorrectedImage]
	button "Find landmarks"			[processCorrectedImage]
	button "Save landmarks"			[saveMarks if isCorrectedImage? [getMarks2]]
	button "Compute"				[if (isFile? and isCorrectedImage?) [exportResults showResults readGlossary]]
	button "Processed Image"		[loadImage 1]
	button "Landmarks Selection"	[view markWin] 										 
	button "Quit" 		  			[quitRequested]
	return
	text "Color Space" 70
	drop-down 100 data palette
	select 1
	on-change [
		if isFile? [
			colorSpace: face/selected
			;unless isCorrectedImage? [
				switch colorSpace [
					1 [hsv: rcvCloneImage img0]
					2 [rcv2BGRA img0 hsv]
					3 [rcvRGB2HSV img0 hsv]
					4 [rcvBGR2HSV img0 hsv]
					5 [rcvRGB2HLS img0 hsv]
					6 [rcvBGR2HLS img0 hsv]
					7 [rcv2Gray/average img0 hsv]
				]
				either cbc/data [img1: rcvResizeImage hsv gSize / 2]
								[img1: rcvResizeImage img0 gSize / 2]
				img2: rcvResizeImage hsv gSize
				transl: (canvas1/size - img1/size) / 2
				bl: compose [translate (transl)image img1]
				canvas1/draw: reduce [bl]
				canvas2/draw: reduce [rotation]	
			;]
		]
	]
	cbc: check 30  true
	sb2: field 50
	sb3: field 60
	coordList: drop-list 125 data [] ; pb avec text-list 100x510 data [] event/picked
	sb4: field 150
	check "Numbering" false 	[isNumbered?: face/data getMarks2]
	check "Axes" true 			[hLine/visible?: vLine/visible?: face/data]	
	cbPoints: check "Landmarks" true
	return
	canvas1: base gsize2  white
	drop-down 180 data measures
	select 1
	on-change [ 
		if (isFile? and isCorrectedImage?) [
			switch face/selected [
					1	[getAllPoints]
					3	[showVerticalAxisSup]
					4	[showVerticalAxisMiddle]
					5	[showVerticalAxisInf]
					6	[showMedianLine]
					8	[showOrbitalR]		
					9	[showMandR]	
					10  [showChinR]
					11	[showNasalR]
					12	[showLowFaceR]
					13	[showMidFaceR]	
					14	[showHemiFaceR]
					16	[showCanthalAngle]
					17	[showCommisuralAngle]
					18	[showEyesAngle]
			]
			sb1/text: form face/data/(face/selected)
		]
	]
	button "All" [if (isFile? and isCorrectedImage?) [getAllPoints]]
	at 240x115 detail: text-list 260x220 
	on-change [
		if (isFile? and isCorrectedImage?) [
			s: split face/data/(face/selected) separator
			pointNum: to-integer s/1
			pointCode: s/2
			pointLabel: s/3
			coordList/selected: pointNum + 1
			s: split coordList/data/(pointNum + 1) ":"
			p: to pair! second s
			sb2/text: rejoin ["mp" pointNum]
			sb3/text: to-string p
			sb4/text: form pointLabel
			p: p - 7x0
			curs/offset: p + canvas2/offset
		]
	]
	
	
	at 240x340 calcul: area 260x255
	at 10x340
	sl: slider 222 [
		if isFile? [
			rot: to integer! face/data * 360 - 180
			rotF/text: form rot
			either rot = 0 [append rotF/text " degree"] [append rotF/text " degrees"] 
			rotation/7: rot
		]
	]
	at 10x370 
	bm: button 50 "-" [
		if isFile? [
			rot: rot - 1
			rotF/text: form rot
			either rot = 0 [append rotF/text " degree"] [append rotF/text " degrees"] 
			rotation/7: rot
			sl/data: sl/data - 0.28%
		]
	]
	at 60x372 rotF: field 120 center  "0 degrees" 
	at 180x370 bp: button 50 "+" [
		if isFile? [
			rot: rot + 1 
			rotF/text: form rot
			either rot = 0 [append rotF/text " degree"] [append rotF/text " degrees"] 
			rotation/7: rot
			sl/data: sl/data + 0.28%
		]
	]
	canvas2: base gsize white cursor hand			
	return
	sb1: field 490 
	
	button "RGB Capture" [
		if isFile? [
			canvas/draw: none
			canvas/image: draw img2 drawBlock
			isThermic?: false
			view/flags captureWin ['modal 'no-buttons]
		]
	]
	
	button "Thermal Capture" [ 
		if isFile? [
			canvas/draw: none
			canvas/image: draw img2 drawBlock
			img: canvas/image
			dst: rcvCloneImage img
			rcvRGB2HSV img dst
			canvas/image: dst
			isThermic?: true
			view/flags captureWin ['modal 'no-buttons] 
		]
	]	
	pad 100x0 button "Excel File" [call "open Classeur1.xlsx"]
	at canvas2/offset curs: rect
	at canvas2/offset + as-pair -5 gsize/y / 2 hLine: rHLine
	at canvas2/offset + as-pair gsize/x / 2 -5 vLine: rVLine			
	do [sl/data: 50% 
		hLine/visible?: vLine/visible?: true
	   	coordList/enabled?: false
	   	calcul/text: copy ""
	]
]

readConfig 
readGlossary
generateMarks nbPMax 
view/flags mainWin ['no-buttons]


