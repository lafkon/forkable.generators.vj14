#/bin/bash

 COLOR=../../../i/free/svg/vj14_offset_MASTER.svg

 XOFFSET=0
 YOFFSET=0
 BLEEDWIDTH=150
 BLEEDCOLOR=ffffff

 OUTDIR=.

 inkscape -background-color=FFFFFF \
          --export-width=400 \
          --export-png=$OUTDIR/offset_MASTER.png \
          $COLOR

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

 for LASER in `ls *.svg`
  do
     if [ ! -f $OUTDIR/${LASER%%.*}_OVERPRINT.png ]
      then

     cp $LASER ${LASER%%.*}__PRINT.svg
     MOD="translate($XOFFSET,$YOFFSET)"
     sed -i "0,/translate(0,0)/s//$MOD/" \
             ${LASER%%.*}__PRINT.svg

     sed -i "s/<\/svg>/${BLEED}&/g" \
             ${LASER%%.*}__PRINT.svg

     inkscape -background-color=FFFFFF \
              --export-width=400 \
              --export-png=$OUTDIR/${LASER%%.*}.png \
              ${LASER%%.*}__PRINT.svg

     rm ${LASER%%.*}__PRINT.svg

     composite -compose multiply \
               $OUTDIR/offset_MASTER.png \
               $OUTDIR/${LASER%%.*}.png \
               $OUTDIR/${LASER%%.*}_OVERPRINT.png
 
#    rm $OUTDIR/${LASER%%.*}.png

     else

     echo "thumbnails exists"

     fi
 done


# rm $OUTDIR/offset_MASTER.png


exit 0;
