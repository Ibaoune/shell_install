#=========================================================================
if [ $ioipsl = 1 ] ; then
#=========================================================================
   echo OK ioipsl=$ioipsl
   echo '##########################################################'
   echo 'Installing MODIPSL, the installation package manager for the '
   echo 'IPSL models and tools'
   echo '##########################################################'
   echo `date`

   cd $MODEL/modipsl
   \rm -rf lib/*
   cd util
   cp AA_make.gdef AA_make.orig
   F_C="$compiler -c " ; if [ "$compiler" = "$gfortran" -o "$compiler" = "mpif90" ] ; then F_C="$compiler -c -cpp " ; fi
   if [ "$compiler" = "pgf90" ] ; then F_C="$compiler -c -Mpreprocess" ; fi
   sed -e 's/^\#.*.g95.*.\#.*.$/\#/' AA_make.gdef > tmp
   sed -e "s:F_L = g95:F_L = $compiler:" -e "s:F_C = g95 -c -cpp:F_C = $F_C": \
   -e 's/g95.*.w_w.*.(F_D)/g95      w_w = '"$OPTIMGCM"'/' \
   -e 's:g95.*.NCDF_INC.*.$:g95      NCDF_INC= '"$ncdfdir"'/include:' \
   -e 's:g95.*.NCDF_LIB.*.$:g95      NCDF_LIB= -L'"$ncdfdir"'/lib -lnetcdff -lnetcdf:' \
   -e 's:g95      L_O =:g95      L_O = -Wl,-rpath='"$ncdfdir"'/lib:' \
   -e "s:-fmod=:-$fmod:" -e 's/-fno-second-underscore//' \
   -e 's:#-Q- g95      M_K = gmake:#-Q- g95      M_K = make:' \
   tmp >| AA_make.gdef

   if [ $pcmac == 1 ]
   then
       cp AA_make.gdef tmp
       sed -e 's/rpath=/rpath,/g' tmp > AA_make.gdef
   fi


 # We use lines for g95 even for the other compilers to run ins_make
   if [ "$use_shell" = "ksh" ] ; then
     ./ins_make $o_ins_make
   else # bash
     sed -e s:/bin/ksh:/bin/bash:g ins_make > ins_make.bash
     if [ "`grep jeanzay AA_make.gdef`" = "" ] ; then # Bidouille pour compiler sur ada des vieux modipsl.tar
         echo 'Warning jean-zay not in AA_make.gdef'
         echo 'Think about updating'
         exit 1
     fi

     chmod u=rwx ins_make.bash
     ./ins_make.bash $o_ins_make
   fi # of if [ "$use_shell" = "ksh" ]

   echo install_lmdz.sh MODIPSL_OK `date`

   cd $MODEL/modipsl/modeles/IOIPSL/src
   ioipsllog=`pwd`/ioipsl.log

   echo '##########################################################'
   echo 'Compiling IOIPSL, the interface library with Netcdf'
   echo '##########################################################'
   echo `date`
   echo log file : $ioipsllog

   if [ "$use_shell" = "bash" ] ; then
     cp Makefile Makefile.ksh
     sed -e s:/bin/ksh:/bin/bash:g Makefile.ksh > Makefile
   fi
 # if [ "$pclinux" = 1 ] ; then
     # Build IOIPSL modules and library
     $make clean
     $make > $ioipsllog 2>&1
     if [ "$compiler" = "$gfortran" -o "$compiler" = "mpif90" ] ; then # copy module files to lib
       cp -f *.mod ../../../lib
     fi
     # Build IOIPSL tools (ie: "rebuild", if present)
     if [ -f $MODEL/modipsl/modeles/IOIPSL/tools/rebuild ] ; then
       cd $MODEL/modipsl/modeles/IOIPSL/tools
       # adapt Makefile & rebuild script if in bash
       if [ "$use_shell" = "bash" ] ; then
         cp Makefile Makefile.ksh
         sed -e s:/bin/ksh:/bin/bash:g Makefile.ksh > Makefile
         cp rebuild rebuild.ksh
         sed -e 's:/bin/ksh:/bin/bash:g' \
             -e 's:print -u2:echo:g' \
             -e 's:print:echo:g' rebuild.ksh > rebuild
       fi
       $make clean
       $make > $ioipsllog 2>&1
     fi
# fi # of if [ "$pclinux" = 1 ] 

else # of if [ $ioipsl = 1 ]
   if [ ${hostname:0:5} = jean- ] ; then
      cd $MODEL/modipsl
      cd util
        if [ "`grep jeanzay AA_make.gdef`" = "" ] ; then
         echo 'Warning jean-zay not in AA_make.gdef'
         echo 'Think about updating'
         exit 1
        fi
        ./ins_make $o_ins_make
# Compile IOIPSL on jean-zay
        cd $MODEL/modipsl/modeles/IOIPSL/src
        gmake > ioipsl.log
        cd $MODEL/modipsl/modeles/IOIPSL/tools
        gmake > ioipsl.log

   fi
   echo install_lmdz.sh ioipsl_OK `date`
fi # of if [ $ioipsl = 1 ]
# Saving ioipsl lib for possible parallel compile
  cd $MODEL/modipsl
  tar cf ioipsl.tar lib/ bin/

