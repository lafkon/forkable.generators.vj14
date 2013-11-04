#!/bin/bash


 for DWNLD in `find . -name "*.download"`
  do
      FILEPATH=`echo $DWNLD | \
                rev | \
                cut -d "/" -f 2- | \
                rev`

      cd $FILEPATH
      echo `cat \`basename $DWNLD\` | shuf -n 1`
      cd -

 done

exit 0;
