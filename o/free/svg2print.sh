#/bin/bash

# ---------------------------------- #
# LASER PRINTER AT CONSTANT VARIABLE #
# ---------------------------------- #
# XOFFSET=-16
# YOFFSET=-21
# SCALE=1.025
# BLEEDWIDTH=150
# ---------------------------------- #

# ---------------------------------- #
# COLM'S INKJET                      #
# ---------------------------------- #
  XOFFSET=-19
  YOFFSET=-18
  SCALE=1.03
  BLEEDWIDTH=150
# ---------------------------------- #

  BLEEDCOLOR=ffffff
  MOD="translate($XOFFSET,$YOFFSET) scale($SCALE)"
  INFO=info-7.layer
  OUTPUTDIR=PRINT


  COLORPRINT=../../i/free/svg/vj14_offset_MASTER.svg

#inkscape -background-color=FFFFFF \
#         --export-dpi=300 \
#         --export-png=$OUTPUTDIR/offset_MASTER.png \
#         $COLORPRINT

 LASTLAYER=`cat $INFO | \
            sed ':a;N;$!ba;s/\n/ /g' | \
            sed 's/"/\\\"/g' | sed 's,/,\\\/,g'`

#---------------------------------------------------------------------------- #

#---------------------------------------------------------------------------- #
# INFO ONLY LAYER
#---------------------------------------------------------------------------- #
# INFOSVG=info.svg
# SVGHEADER=`tac $COLORPRINT | sed -n '/<\/metadata>/,$p' | tac`
# SVGHEADER=`tac $COLORPRINT | sed -n '/<\/metadata>/,$p' | tac | \
#            sed '/<defs/,/\/defs>/d' | \
#            sed '/<metadata/,/\/metadata>/d'`
# echo $SVGHEADER                                         >  $INFOSVG
# echo "<g transform=\"translate($XOFFSET,$YOFFSET)\">"   >> $INFOSVG
# echo "<g transform=\"$MOD\">"                           >> $INFOSVG
# echo ${LASTLAYER} | sed 's,\\\/,/,g' | sed 's/\\\"/"/g' >> $INFOSVG 
# echo "</g></svg>"                                       >> $INFOSVG
#
# inkscape -background-color=FFFFFF \
#          --export-dpi=300 \
#          --export-png=${INFOSVG%%.*}.png \
#          $INFOSVG





for SVG in `ls svg/*.svg`
 do

#---------------------------------------------------------------------------- #
 BLEED=`echo '<g style="display:inline"
           inkscape:label="XX_BLEED"
           id="bleed"
           inkscape:groupmode="layer">
     <path
       inkscape:connector-curvature="0"
       id="bleedpath"
       d="m -24.87,-34.87107 1067.3622,10 64,1515.18887 -1131.3622,58 z"
       style="fill:none;stroke:#'$BLEEDCOLOR';stroke-width:'$BLEEDWIDTH'"
       sodipodi:nodetypes="ccccc" /></g>' | \
        sed ':a;N;$!ba;s/\n/ /g' | sed 's/"/\\\"/g' | sed 's,/,\\\/,g'`
#---------------------------------------------------------------------------- #


  cp $SVG ${SVG%%.*}__PRINT.svg
  sed -i "0,/translate(0,0)/s//$MOD/" \
          ${SVG%%.*}__PRINT.svg

  tac ${SVG%%.*}__PRINT.svg | \
  sed "0,/<\/g>/s//$LASTLAYER&/" | \
  tac > ${SVG%%.*}__PRINT.svg.tmp
  mv ${SVG%%.*}__PRINT.svg.tmp ${SVG%%.*}__PRINT.svg

  sed -i "s/<\/svg>/${BLEED}&/g" \
          ${SVG%%.*}__PRINT.svg


  PNG=$OUTPUTDIR/`basename $SVG | cut -d "." -f 1`.png
  
  if [ ! -f ${PNG%%.*}.jpg ]; then

  inkscape --export-dpi=300 \
           --export-background=ffffff \
           --export-png=$PNG \
           ${SVG%%.*}__PRINT.svg

  convert -quality 60 \
          -colorspace gray \
          -brightness-contrast 50x10 \
          $PNG ${PNG%%.*}_COLLAGE.jpg
  mv ${PNG%%.*}_COLLAGE.jpg ${PNG%%.*}.jpg


  rm $PNG

  else

  echo "does exist"

  fi

# composite -compose multiply \
#           -quality 60 \
#           ${PNG%%.*}_COLLAGE.jpg \
#           ${INFOSVG%%.*}.png \
#           ${PNG%%.*}.jpg



# composite -compose multiply \
#           -resize 800 \
#           $OUTPUTDIR/offset_MASTER.png \
#           ${PNG%%.*}.jpg \
#           ${PNG%%.*}_SIMULATION.jpg



  rm ${SVG%%.*}__PRINT.svg

# --------------------------------------------------------------------------- #

done


# rm $OUTPUTDIR/offset_MASTER.png ${INFOSVG%%.*}.png $INFOSVG

exit 0;
