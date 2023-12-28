#!/bin/bash
if [ $getlmdzor = 1 -a ! -d $MODEL/modipsl ] ; then
   echo '##########################################################'
   echo  Download a slightly modified version of  LMDZ
   echo '##########################################################'
   cd $MODEL
   echo myget src_archives/unstable/modipsl.$version.tar.g
   myget src_archives/unstable/modipsl.$version.tar.gz
   echo install_lmdz.sh wget_OK `date`
   gunzip modipsl.$version.tar.gz
   tar xvf modipsl.$version.tar
   \rm modipsl.$version.tar
fi
