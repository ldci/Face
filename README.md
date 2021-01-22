# Face

This the open source code used for the paper *Lalauze-Pol R, Jouen F. Facial Growth in Children from 1 Month to 7 Years: A Biometric Approach by Image Processing. GSL J Pediatr. 2020; 1:105*.


# Required
First of all you need to install Red Language. Download a recent or the latest version (Automated builds, master branch). See
[Red Programming Language](http://www.red-lang.org).

Face also uses [redCV library](https://github.com/ldci/redCV) which is included in redCV/libs directory.

Face software requires [DLib c++ library](http://dlib.net) for facial landmarks recognition and  Python 3. For using dlib from Python just do `pip3 install dlib` in your terminal.

## Compilation
Very easy: just `red -c face.red`


# Using Face
You must **use command-line interface** since Face calls a python script. Change to application dir and just type `../face`.
 
Face processes 2-D images of faces for measuring facial heights, ratios and surfaces. You'll find in /publication  directory, our paper which gives all details about the used method.

## Basic Use

Load a source image e.g. /images/face1.png, and modify angle if necessary. Then save the modified image. This creates a copy of the source image, e.g. /images/face1C.png. Now you can detect the landmarks with DLib network and compute facial heights and surfaces. 

You can also load an image as a *processed image*. Do not use the copy image file name, but **the source image file name**. The mapping betwen both images is automatic. Now you can find landmarks and compute values.


