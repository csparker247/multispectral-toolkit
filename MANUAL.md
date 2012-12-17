multispectral-toolkit manual
============================
  
multispectral-toolkit is a set of tools created to automate the post-processing workflow for images
acquired using a multispectral imaging system. It was built in-house at the University of Kentucky
Center for Visualization and Virtual Environments and is tailored for use with images acquired using
MegaVision's EurekaVision imaging system.  
  
This manual is meant to serve as a rough guide for processing your own sets of images. Each script in
the toolkit operates under its own set of environment/input assumptions that can be slightly difficult
to understand by just looking at the code. The manual will attempt to lay out those assumptions so that
processing goes as painlessly as possible. Many of these assumptions are simply carryover from the
EurekaVision imaging workflow and are common across all scripts with minor variations. As such, it's
important that you understand what each script is attempting to do before you try to use it. Things will
go a lot smoother.  

_NOTE: All of the scripts in this toolkit should be nondestructive in that your original files are never
touched. Still, accidents happen, so always have a proper backup of all data before you use any of the
multispectral-toolkit scripts._  

## Terminology ##
  
In order to make describing things slightly easier, it's important to define the usage of certain terms.
All examples refer to what each term would represent if one was imaging each page in a copy of _The Iliad_.   

  * _Folio_ - A particular shot of a document. Most often this refers to a single page in a book.
  Some documents have pages/leafs that must be imaged in pieces. In the multispectral-toolkit, each of
  these pieces are treated as a separate folio. Some scripts simply refer to them as a page. Each folio
  should have a unique identifying number (see _FILE MANAGEMENT_). _(e.g. Page 53 in The Iliad)_  
  
  * _Volume_ - A collection of folios from the same source. Most often this refers to a particular book.
  Each volume should have a unique name (see _FILE MANAGEMENT_). _(e.g. The Iliad)_  
  
  * _Collection_ - A collection of volumes. This is considered the intended output of the multispectral-toolkit.
  It is easiest to think of it as a digital library. When you navigate to a particular digital collection,
  you will see folders for each volume imaged. Folios are collected inside of their corresponding volumes,
  regardless of the day on which they were imaged. _(e.g. A folder containing TheIliad, TheOdyssey, etc.)_  
  
## The "Standard" EurekaVision Workflow ##
  
The EurekaVision workflow is highly customizable, so the "standard" referred to by this documentation
represents the workflow used by the VisCenter during development of the multispectral-toolkit. The most
important aspects of this workflow are _FILE MANAGEMENT_, _FLATFIELDS_, and _METADATA_.  
  
_**FILE MANAGEMENT**_:  
The scripts in the multispectral-toolkit assume a very specific folder structure and file naming scheme.
It's usually much easier to match your file management to this scheme from the start rather than having
to go back and rename files later.  

The first aspect to this is the use of Daily folders. These are folders that contain a single day's
worth of shooting. There can be any number of these Daily folders and they can be named using any
organization scheme you please. The VisCenter uses `MVDaily_[YYYYMMDD]`. It really doesn't matter what
you pick or even if you're consistent in naming. As long as you can navigate your data, what's much more
important is what goes inside of these Daily folders. 
 
Each Daily folder should have a folder for each folio shot on that day. The names of the folio folders
should be the volume identifier, a dash, and the folio identifying number. _(e.g. The folio folder name
for the 53 page of The Iliad could be "Iliad-53")_ The volume identifier is, of course, variable, but
should remain consistent for all folios from a single volume. The '-' acts as a delimiter to separate
the volume ID from the folio ID, therefore dashes **should not** be used in the volume ID. We prefer
underscores for further volume differentiation. For example, in a collection of numbered volumes 1-5,
your folio folder names could be: `NPM_1-1`, `NPM_1-2`, `NPM_2-1`, etc. Any character preceding the `-`
will be used as part of the volume ID during file reorganization. However, folio IDs should ONLY be
numbers.  
 
Inside each folio folder should be a subdirectory named Mega and Processed. Mega houses a RAW DNG version
of each exposure for a particular folio. Processed contains a 16-bit TIFF version of the same.
multispectral-toolkit only ever works with the TIFFs in the Processed folder, so you can safely ignore
the DNGs in your post-processing workflow.
 
The TIFFs inside of the Processed folder also have their own naming conventions. Using the EurekaVision
imaging system, they will often automatically be named `[Volume ID]-[Folio ID #]_###.tif`. Note
the sequential numbering for each exposure and the file extension. multispectral-toolkit expects 14
exposures in this Processed folder, each exposed under specific circumstances and embedded with certain
metadata. This will be discussed in more detail in the _METADATA_ section. For filename purposes, these
sequential numbers should be `001-014`. The file extension should also be the three-letter `.tif` and not the
four-letter `.tiff` variant.
 
Thus, a completely compliant file path for a TIFF of the sixth exposure in a Processed folder might be:
`/Volumes/Multispectral/Dailies/MVDaily_20121214/Iliad-53/Processed/Iliad-53_006.tif` 
 
One last note: If you find files aren't getting processed, check for special characters in the paths to
your files. Spaces, punctuation, and other special characters can cause issues. A good rule of thumb is
to only use the A\-Z characters, numbers, underscores, and dashes.  
  
  
_**FLATFIELDS**_:  
If you are unfamiliar with flat-field correction, I suggest learning a bit about it from its [Wikipedia page](http://en.wikipedia.org/wiki/Flat-field_correction).
For the EurekaVision workflow, flatfields are shots of a blank or all-white scene, exposed in the same
exposure conditions in which subsequent imaging will occur. These flatfields then represent "control"
images that can correct for exposure variations (caused by lens vignetting or uneven lighting) when applied
to images shot under the same exposure conditions. Applying a flatfield to itself would create an all-white
image.  
 
The multispectral-toolkit assumes that each Daily folder will also contain a corresponding flatfields folder.
This flatfields folder should have the prefix `FLATS_`. Any characters following the underscore are
ignored, though it is usually most useful to include a date that matches the date of the Daily folder.
The subdirectory structure of this folder should match that of a folio folder and should include a
Processed directory. The images contained in a Daily's `FLATS_` folder will be stored as the flatfields
for all other images inside of that Daily folder.
 
In order for flatfielding to be effective, it is important that flatfields always match the exposure
environment in which imaging occurs. Any variation in exposure times, position of light source, and
even zoom should come with a corresponding reacquisition of flatfield images. It is usually easiest to
treat these changes as the time to switch to a new Dailies folder, acquiring a new set of flatfields
appropriately.
 
One last note: Flatfields should also be numbered 001-014, corresponding to the exposure sequence for
folio images. See the _METADATA_ section for more information.  
  
  
_**METADATA**_:  
Each image acquired using the "Standard" EurekaVision workflow is embedded with metadata in EXIF tags. For
the multispectral-toolkit, the most relevant information is the exposure information, particularly the
wavelength used to expose the image. The VisCenter workflow involves exposing a set of images exposed
under a particular sequence of wavelengths. Though exposure times may very across exposure environments,
the order in which particular wavelengths are acquired does not change. For example, in a good data set, the
second image will always represent an image acquired under 365nm (Ultraviolet) light. See the N-Shot list
below for more information.  
 
This is why file numbering inside of folios and flatfields is so important. During the flatfielding process
implemented by `mstk.sh` and `apply_flats.sh`, an image is matched to its corresponding wavelength flatfield
by checking against this embedded metadata. However, during the multispectral rendering process, when images
are lined up from lowest wavelength to highest, this check is not implemented and a particular link between
wavelength and file ordering is assumed.  
 
This Wavelength-File Order correlation is referred to in MegaVision's PhotoShoot software as an N-shot
table. The "Standard" N-shot table that the multispectral-toolkit operates under is as follows:  
  
* 001 \- NONE \- Used to quickly identify the start of a new exposure set. Not used by multispectral\-toolkit.
* 002 \- 365nm UV  
* 003 \- 465nm Blue  
* 004 \- 505nm Cyan  
* 005 \- 535nm Green  
* 006 \- 592nm Amber  
* 007 \- 625nm Red-Orange  
* 008 \- 638nm Red  
* 009 \- 700nm IR700  
* 010 \- 730nm IR730  
* 011 \- 780nm IR780  
* 012 \- 850nm IR850  
* 013 \- 940nm IR940  
* 014 \- 450nm Royal Blue    
  
  
## The Scripts ##
### mstk.sh ###
  
`mstk.sh` is a script written to fully automate the post-processing of multispectral images. Many of the scripts
in the multispectral-toolkit were written to perform very specific post-processing functions. However, A\-Z processing
of a full data set required lots of manual oversight by the user. Scripts needed to be called individually, from very
specific file locations with very specific arguments. Often, too, the outputs of these scripts required some level of
file management before the next step in the process could be performed. Completely unattended post-processing of a full
data set was impossible.  
  
The goal of `mstk.sh` is to minimize the need for this oversight as much as possible. It offers standardized
file management and script output so that the processing of any data set will produce predictable and usable
results. It is also meant to simplify post-processing such that a minimally trained user could oversee the
processing of data sets.  
  
**Running mstk.sh**  
  
`mstk.sh` should be run from inside the folder containing all of the Daily folders to be processed. It needs no
arguments to run.  
  
  `$ ~/source/multispectral-toolkit/mstk.sh`  
  
Upon running `mstk.sh`, you will be asked to choose an Output Location. This is where all processed images and files
will be placed. You can manually type the path to a location or you can drag-and-drop a folder onto the Terminal
window. If this is not a valid location or if the directory is not writable, you will be asked to select a new location.
_NOTE: As of now, only the directory is checked for writable flags; its root volume is not checked. If you encounter
unwritable file errors, ensure you have full permissions to write to the directory._  
  
`mstk.sh` will then ask for copyright information. This information will be embedded into all image files at the end of
the processing procedure. `mstk.sh` will only attempt to write copyright information to files whose EXIF copyright field does
not already match the pattern created during this input phase. Make sure to double-check the spelling! Processing will begin
after copyright information has been confirmed. _NOTE: Unlike many of the other steps in the multispectral-toolkit where the
`mstk.sh` versions of script are specialized versions of preexisting utilities, the copyrighting functions of `mstk.sh` are
shared with `copyrighter.sh`. If you find you need to cancel the copyright procedure in the middle of post-processing, it
is usually better to run `copyrighter.sh` in your output folder than to rerun `mstk.sh`._