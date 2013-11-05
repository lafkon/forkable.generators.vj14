#!/bin/bash


 for DWNLD in `find . -name "*.download"`
  do
      FILEPATH=`echo $DWNLD | \
                rev | \
                cut -d "/" -f 2- | \
                rev`

      cd $FILEPATH

       DWNLDURL=`cat \`basename $DWNLD\` | shuf -n 1`
      DWNLDFILE=`echo $DWNLDURL | \
                 rev | \
                 cut -d "/" -f 1 | \
                 rev`

      if [ ! -f $DWNLDFILE ]; then
           wget $DWNLDURL
      else
           echo $DWNLDFILE "already here"
      fi

      cd -

 done

exit 0;
