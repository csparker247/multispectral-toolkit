#!/bin/zsh

# applyflats - Flatfield multispectral images and create RGB versions of all folios.
# Run from inside the main flatfields folder. Requires the corresponding Daily folder as its only argument. For example:
# $ cd ~/MVDaily_20121203/FLATS_TODAY
# $ ~/source/multispectral-toolkit/applyflats.sh ~/MVDaily_20121203

echo
echo -------------------------------------------------------
echo Applyflats - The Multispectral Flatfielding Application
echo -------------------------------------------------------
echo "               Hit CTRL + C to exit."
echo

# Quit if no files/arguments given
if [ $# -eq 0 ]; then
	exit 0
fi

# Setup for applying flatfields to appropriate exposures for each page
# Checks wavelength of each flatfields image and send to array in format: wavelengths[638nm]="638nm"
declare -A wavelengths
for i in Processed/*.tif; do
  WAVELENGTH=$(exiv2 -pa $i | grep Exif.Photo.SpectralSensitivity|awk '{print substr($0, index($0,$4))}')
  wavelengths[$WAVELENGTH]=$i
done

# Initialize arrays
FLATFIELD_COMMANDS=""
RGB_COMMANDS=""
RGB_JPG_COMMANDS=""
declare -A rgb

# For everything in the shoot folder
for i in ${1}/*; do
  # Check to make sure it's a page's directory and not a random file
  if [[ -d "$i" ]]; then
    # Print name to stderr and clear out RGB arrays
    echo "$i" 1>&2
    export RED=""
    export GREEN=""
    export BLUE=""
    
    # Check for a Processed folder for the day
    if [[ -d "$i"/Processed ]]; then
      # In the flatfields folder, make a new folder for flatfield processed images, then a new folder for the page being processed
      mkdir -p flatfielded/$(basename "$i")
      # For every tif inside the page's processed folder...
      for j in "$i"/Processed/*.tif; do
        # Set flatfielded image filepath to new flatfielded folder
        OUTFILE="flatfielded/$(basename $i)/$(basename $j)"
        
        # Gets wavelength of file
        WAVELENGTH=$(exiv2 -pa $j | grep Exif.Photo.SpectralSensitivity|awk '{print substr($0, index($0,$4))}')
        
        # If it finds an RGB wavelength, stores file path for processing
        if [[ -n $WAVELENGTH && "$WAVELENGTH" =~ "638nm" ]]; then
          export RED=$OUTFILE
        elif [[ -n $WAVELENGTH && "$WAVELENGTH" =~ "535nm" ]]; then
          export GREEN=$OUTFILE
        elif [[ -n $WAVELENGTH && "$WAVELENGTH" =~ "465nm" ]]; then
          export BLUE=$OUTFILE
        else
          # echo "$WAVELENGTH not a primary color" 1>&2
        fi

		# If flatfielded output doesn't already exist...
        if [[ ! -e $OUTFILE ]]; then
          # And if the flatfields folder has a matching wavelength...
          if [[ -n $wavelengths[$WAVELENGTH] ]]; then
            # Build a flatten command and add it to the an array of flatfields commands
            FLATFIELD=$wavelengths[$WAVELENGTH]
            FLATFIELD_COMMANDS+="~/source/multispectral-toolkit/flatfield/flatten $FLATFIELD $j $OUTFILE\n"
          else
            echo "Skipping $j, no wavelength match in flatfields" 1>&2
          fi
        else
          echo "Skipping $j, $OUTFILE already exists" 1>&2
        fi
      done
	  
	  # If we found R,G, & B pictures...
      if [[ -n $RED && -n $GREEN && -n $BLUE ]]; then
        echo "Performing RGB for $(basename $i), was R:$RED G:$GREEN B:$BLUE" 1>&2
        # Add the three files to the rgb array as: rgb[pg1]="../Processed/red ../Processed/green ../Processed/blue
        rgb[$(basename "$i")]="$RED $GREEN $BLUE"
      else
        echo "Skipping RGB for $(basename $i), was R:$RED G:$GREEN B:$BLUE" 1>&2
      fi

    else
      echo "Skipping $i, no processed directory" 1>&2
    fi
  else
    echo "Skipping $i, not a directory" 1>&2
  fi
done

# Print list of pages (array keys) being processed
echo "RGB: ${(k)rgb}" 1>&2

# Setup new rgb working directory
mkdir -p rgb
# For every page stored in the rgb array...
for i in ${(k)rgb}; do
  # And if that page has not been processed...
  if [[ ! -e rgb/"$i".tif ]]; then
    # Add a convert command to combine the RGB files for that day into one
    # $rgb[$i] expands to be the "$RED $GREEN $BLUE" from the earlier step
    # i.e. For page of name pg1: $rgb[$i] becomes "$rgb[pg1]" which in turn becomes
    # "pg1/Processed/Red.tif pg1/Processed/Green.tif pg1/Processed/Blue.tif"
    RGB_COMMANDS+="convert $rgb[$i] -channel RGB -combine rgb/$i.tif && convert rgb/$i.tif rgb_jpg/$i.jpg\n"
  else
    echo "Skipping RGB for $i, file already exists" 1>&2
  fi
done


# Creates RGB_JPG commands using the same principles as the previous section
mkdir -p rgb_jpg
for i in ${(k)rgb}; do
  if [[ ! -e rgb_jpg/"$i".jpg ]]; then
    RGB_JPG_COMMANDS+="convert rgb/$i.tif rgb_jpg/$i.jpg\n"
  else
    echo "Skipping RGB JPG for $i, file already exists" 1>&2
  fi
done

# Run all accumulated commands at once
echo "Flatfielding..." 1>&2
echo $FLATFIELD_COMMANDS | parallel --eta -u -v -j 8
echo "RGB..." 1>&2
echo $RGB_COMMANDS | parallel --eta -u -v
echo "JPG..." 1>&2
echo $RGB_JPG_COMMANDS | parallel --eta -u -v -j 8
