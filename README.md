multispectral-toolkit
=====================

A set of tools for organizing and processing multispectral data.


**Latest Updates**

* 6.20.2013 - Changes to enable multispectral-only output. Updated documentation to reflect changes since v2.0.
* 5.17.2013 - summarize.sh now tries to match pages to their flatfield when multiple flatfields are detected.
* 5.16.2013 - Version 2.0 release to master.
* 5.14.2013 - applyflats.sh ignores flatfield folders. copyrighter.sh ignores folder structure, has preset copyright options
* 5.13.2013 - Add preset flags to mstk.sh. applyflats.sh and spectralize.sh now lets user select output types that are kept after processing.
* 5.11.2013 - First working version of summarize.sh, preprocessing report application.
* 5.10.2013 - spectralize.sh autodetects wavelength order of files.
* 5.9.2013 - Branch for v2.0. Sync spectralize.sh, applyflats.sh with their mstk counterparts. 
* 1.15.2013 - despot now uses in-painting via OpenCV. Spot isolation needs a lot of work.
* 12.20.2012 - mstk.sh: Flatfielded images and PNGs are now created using pngflatten. flatten currently being kept for applyflats.sh support.
* 12.13.2012 - First version of mstk and its subscripts. mstk takes a folder of dailies and outputs a fully processed collection.


**Installation**

* Check MANUAL.md for installation instructions  


**Known Issues/Special Notes**

* Making flatten and pngflatten requires OpenCV to be installed.
* ImageMagick should be compiled with TIFF support.
* Despot can cause irregularities when rendering RGB and Multispectral images. As such, the original flats are always kept. Use with caution.

**Other Software**

This repo is developed and maintained on OSX. As such, all external software below is installed via homebrew.

* OpenCV - http://opencv.org/
* ImageMagick - http://www.imagemagick.org/
* Exiv2 - http://www.exiv2.org/
* teem - http://teem.sourceforge.net/
* GNU parallel - http://www.gnu.org/software/parallel/
* flatfield project - https://github.com/csparker247/flatfield

