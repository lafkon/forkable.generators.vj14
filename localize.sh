#!/bin/bash


 for DWNLD in `find . -name "*.download"`
  do
      FILEPATH=`echo $DWNLD | \
                rev | \
                cut -d "/" -f 2- | \
                rev`

      cd $FILEPATH

       DWNLDURL=`cat \`basename $DWNLD\` | \
                 shuf -n 1`
      DWNLDFILE=`echo $DWNLD | \
                 rev | \
                 cut -d "/" -f 1 | \
                 rev`

#     if [ ! -f $DWNLDFILE ]; then
      if [ `ls ${DWNLDFILE%%.*}.* | wc -l` -le 1 ]; then

       while [ `curl --silent --head "$DWNLDURL" | \
                grep HTTP | grep 200 | wc -l` -lt 1 ];
        do
            echo "$DWNLDURL does not exist"
            DWNLDURL=`cat \`basename $DWNLD\` | \
                      shuf -n 1`
       done

            wget $DWNLDURL

      else
           echo $DWNLDFILE "already here"
      fi

      cd - > /dev/null
      echo

 done

exit 0;
