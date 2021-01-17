Red [
	Title:   "Red Computer Vision: Time Series"
	Author:  "Francois Jouen"
	File: 	 %rcvTS.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


;************** Time Series Routines *************************

rcvTSStats: routine [
	 signal 		[vector!]
     blk	 	 	[block!]
     op				[integer!]
     /local
     headS tailS 		[byte-ptr!]
     unit		        [integer!]
     sum sum2 a b num   [float!]
     length mean sd		[float!]
     mini maxi val		[float!]
     s					[series!] 
     f 
     
][
	 block/rs-clear blk
	 sum: 0.0
	 sum2: 0.0
	 mean: 0.0
	 sd: 0.0
	 maxi: 0.0
	 mini: 100000.00
	 length: (as float! vector/rs-length? signal)
	 headS: vector/rs-head signal
	 tailS: vector/rs-tail signal
	 s: GET_BUFFER(signal)
	 unit: GET_UNIT(s)
	 while [headS < tailS][
	 	switch op [
	 		0 [val: as float! vector/get-value-int as int-ptr! headS unit]
	 		1 [val: vector/get-value-float headS unit]
	 	]
	 	either val >= maxi [maxi: val] [maxi: maxi]
	 	either val < mini [mini: val] [mini: mini]
		sum: sum + val
		sum2: sum2 + (val * val)
		headS: headS + unit
	]
	mean: sum / length
	a: Sum * Sum
	b: a / length
	num: (sum2 - b);
    if num < 0.0 [num: 0.0 - num]
    sd: sqrt (Num / (length - 1.0)) 
    f: float/box mean
    block/rs-append blk as red-value! f 
    f: float/box sd
    block/rs-append blk as red-value! f
    f: float/box mini
    block/rs-append blk as red-value! f
    f: float/box maxi
    block/rs-append blk as red-value! f
]
