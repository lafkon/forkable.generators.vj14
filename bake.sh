#!/bin/bash

  SVGFOLDERS="i/free/svg"
      MASTER=${SVGFOLDERS}/vj14_offset_MASTER.svg
   OUTPUTDIR=o/free/svg

  SVGCOLLECT=allinone.svg


  for SVG in `find $SVGFOLDERS -name "*.svg" | grep -v $MASTER | sort`
   do
      # echo $SVG
      # ID=`basename $SVG | md5sum | tr -d "[a-z]" | cut -c 1-10`
      ID=`basename $SVG | cut -d "." -f 1`

# --------------------------------------------------------------------------- #
# SEPARATE SVG BODY FOR EASIER PARSING (BUG FOR EMPTY LAYERS SOLVED)
# --------------------------------------------------------------------------- #
# HACK:   WRITE ALL SVG INTO ONE FILE AND ADD UNIQ NUMBER TO THE BASETYPE
#      -> COMBINE TYPES FROM MULTIPLE SRC FILES

      sed 's/ / \n/g' $SVG | \
      sed '/^.$/d' | \
      sed -n '/<\/metadata>/,/<\/svg>/p' | sed '1d;$d' | \
      sed ':a;N;$!ba;s/\n/ /g' | \
      sed 's/<\/g>/\n<\/g>/g' | \
      sed 's/\/>/\n\/>\n/g' | \
      sed 's/\(<g.*inkscape:groupmode="layer"[^"]*"\)/QWERTZUIOP\1/g' | \
      sed ':a;N;$!ba;s/\n/ /g' | \
      sed 's/QWERTZUIOP/\n\n\n\n/g' | \
      sed "s/inkscape:label=[^-]*-/&$ID/" | \
      sed 's/display:none/display:inline/g' >> ${SVGCOLLECT%%.*}.tmp

# --------------------------------------------------------------------------- #
# COLLECT DEFS (CLIPMASKS,FILTERS,ETCPP) FOR HEADER AND UNIFY IDs
# --------------------------------------------------------------------------- #

    #  GREPDEFS=`cat $SVG | \
    #            sed 's/ /\n/g' | \
    #            sed -n '/<defs/,/\/defs>/p' | \
    #            sed '1d;$d' | \
    #            sed ':a;N;$!ba;s/\n/ /g'" "`$GREPDEFS

       cat $SVG | \
       sed 's/ /\n/g' | \
       sed -n '/<defs/,/\/defs>/p' | \
       sed '1d;$d' | \
       sed ':a;N;$!ba;s/\n/ /g' > defs.tmp
     
       for DEFID in `cat defs.tmp | \
                     sed 's/ /\n/g' | \
                     grep ^id | \
                     cut -d "\"" -f 2`
        do
            # echo $DEFID
            UNID=$ID`echo $DEFID | md5sum | cut -c 1-10`
            # echo $UNID
            sed -i "s/$DEFID/$UNID/g" defs.tmp
            sed -i "s/$DEFID/$UNID/g" ${SVGCOLLECT%%.*}.tmp
       done

       GREPDEFS=`cat defs.tmp`" "$GREPDEFS
       rm defs.tmp

  done


 #SVGHEADER=`tac $SVG | sed -n '/<\/metadata>/,$p' | tac`
  SVGHEADER=`tac $SVG | sed -n '/<\/metadata>/,$p' | tac | \
             sed '/<defs/,/\/defs>/d' | \
             sed '/<metadata/,/\/metadata>/d'`$GREPDEFS

  SVG=$SVGCOLLECT



# --------------------------------------------------------------------------- #
# WRITE LIST WITH LAYERS
# --------------------------------------------------------------------------- #

  LAYERLIST=layer.list ; if [ -f $LAYERLIST ]; then rm $LAYERLIST ; fi
  TYPESLIST=types.list ; if [ -f $TYPESLIST ]; then rm $TYPESLIST ; fi

  CNT=1
  for LAYER in `cat ${SVG%%.*}.tmp | \
                sed 's/ /ASDFGHJKL/g' | \
                sed '/^.$/d' | \
                grep -v "label=\"XX_"`
   do
       NAME=`echo $LAYER | \
             sed 's/ASDFGHJKL/ /g' | \
             sed 's/\" /\"\n/g' | \
             grep inkscape:label | grep -v XX | \
             cut -d "\"" -f 2 | sed 's/[[:space:]]\+//g'`
       echo $NAME >> $LAYERLIST
       CNT=`expr $CNT + 1`
  done

  cat $LAYERLIST | sed '/^$/d' | sort | uniq > $TYPESLIST



# --------------------------------------------------------------------------- #
# GENERATE CODE FOR FOR-LOOP TO EVALUATE COMBINATIONS
#---------------------------------------------------------------------------- #

  KOMBILIST=kombinationen.list ; if [ -f $KOMBILIST ]; then rm $KOMBILIST ; fi

  # RESET (IMPORTANT FOR 'FOR'-LOOP)
  LOOPSTART=""
  VARIABLES=""
  LOOPCLOSE=""  

  CNT=0  
  for BASETYPE in `cat $TYPESLIST | cut -d "-" -f 1 | sort | uniq`
   do
      LOOPSTART=${LOOPSTART}"for V$CNT in \`grep $BASETYPE $TYPESLIST \`; do "
      VARIABLES=${VARIABLES}'$'V${CNT}" "
      LOOPCLOSE=${LOOPCLOSE}"done; "

      CNT=`expr $CNT + 1`
  done

# --------------------------------------------------------------------------- #
# EXECUTE CODE FOR FOR-LOOP TO EVALUATE COMBINATIONS
# --------------------------------------------------------------------------- #

 #echo ${LOOPSTART}" echo $VARIABLES >> $KOMBILIST ;"${LOOPCLOSE}
  eval ${LOOPSTART}" echo $VARIABLES >> $KOMBILIST ;"${LOOPCLOSE}




# --------------------------------------------------------------------------- #
# WRITE SVG FILES ACCORDING TO POSSIBLE COMBINATIONS
# --------------------------------------------------------------------------- #

  for KOMBI in `cat $KOMBILIST | sed 's/ /DHSZEJDS/g'`

   do

      KOMBI=`echo $KOMBI | sed 's/DHSZEJDS/ /g'`

      LAYER="";GREPLAYERS=""
      for LAYERNAME in `echo $KOMBI`
       do
          LAYER=`cat ${SVG%%.*}.tmp | \
                 grep "label=\"$LAYERNAME\"" | \
                 sed 's/ /\n/g' | \
                 grep inkscape:label | \
                 cut -d "\"" -f 2 | \
                 sed ':a;N;$!ba;s/\n/ /g'`
  
          GREPLAYERS=$GREPLAYERS" "$LAYER 
      done

      GREPLAYERS=`echo $GREPLAYERS | \
                  sed 's/ /\n/g' | \
                  shuf | \
                  sed ':a;N;$!ba;s/\n/ /g'`

      NAME=vj14
      OSVG=$OUTPUTDIR/${NAME}_`echo ${GREPLAYERS} | \
                               md5sum | cut -c 1-7`.svg

    #  if [ -f $OSVG ];then echo $OSVG "exists"; 
    #  else echo $OSVG "not exist"; 
    #  fi

      echo "$SVGHEADER"                                  >  $OSVG
      echo '<g transform="translate(0,0)">'              >> $OSVG

  # ----------------------------------------------------------------------- #
        CNT=1 # MAKE SURE TO GET THE LAST OF MULTIPLE APPEARANCES
    for LAYERNAME in `echo $GREPLAYERS`
     do
        grep "label=\"$LAYERNAME\"" ${SVG%%.*}.tmp | \
        head -n $CNT | tail -1                           >> $OSVG
        CNT=`expr $CNT + 1`
    done
  # ----------------------------------------------------------------------- #

      echo "</g>"                                        >> $OSVG
      echo "</svg>"                                      >> $OSVG
  
  done



# --------------------------------------------------------------------------- #
# REMOVE TEMP FILES
# --------------------------------------------------------------------------- #
  rm ${SVG%%.*}.tmp $KOMBILIST $LAYERLIST $TYPESLIST




exit 0;


