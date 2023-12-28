#============================================================================
veget_version=false
if [ "$veget" != 'NONE' ] ; then
  cd $MODEL/modipsl/modeles/ORCHIDEE
  set +e ; svn upgrade ; set -e
  if [ "$veget" = "CMIP6" ] ; then
    veget_version=orchidee2.0
    orchidee_rev=6592
  else # specific orchidee revision newer than CMIP6, on 2_1 or 2_2 branches 
    veget_version=orchidee2.1
    orchidee_rev=$veget
     if [ $veget -lt 4465 ] ; then
             echo 'Stopping, ORCHIDEE version too old, script needs work on the CPP flags to pass to makelmdz'
             exit 1
     fi
     set +e
     # which branch is my version on?
     orcbranch=`svn log -v -q svn://forge.ipsl.jussieu.fr/orchidee/ -r $veget |grep ORCHIDEE |head -1| sed -e 's:ORCHIDEE/.*$:ORCHIDEE:' | awk '{print $2}'`
     # switch to that branch
     echo IF YOU INSTALL ORCHIDEE THE VERY FIRST TIME, ASK for PASSWORD at orchidee-help@listes.ipsl.fr 
     svn switch -r $veget --accept theirs-full svn://forge.ipsl.jussieu.fr/orchidee/$orcbranch
     svn log -r $veget | grep  $veget
     if [  $? -gt 0 ] ; then
          echo 'Cannot update ORCHIDEE as not on the right branch for ORCHIDEE'
          exit
      fi
      set -e
      set +e ; svn update -r $veget ; set -e  
  fi
  # Correctif suite debug Jean-Zay
  sed -i -e 's/9010  FORMAT(A52,F17.14)/9010  FORMAT(A52,F20.14)/' src_stomate/stomate.f90
  opt_orc="-prod" ; if [ "$optim" = "-debug" ] ; then opt_orc="-debug" ; fi

  orchideelog=`pwd`/orchidee.log
  echo '########################################################'
  echo 'Compiling ORCHIDEE, the continental surface model '
  echo '########################################################'
  echo Start of the first compilation of orchidee, in sequential mode: `date`
  echo log file : $orchideelog

  export ORCHPATH=`pwd`
  xios_orchid="-noxios"
  if [ "$with_xios" = "y" ] ; then
    xios_orchid="-xios"
  fi
  if [ -d tools ] ; then
###################################################################
# Pour les experts qui voudraient changer de version d'orchidee.
# Attention : necessite d'avoir le password pour orchidee

      # Correctif suite debug Jean-Zay
      if [ -f src_global/time.f90 ] ; then sed -i -e 's/CALL tlen2itau/\!CALL tlen2itau/' src_global/time.f90 ; fi

###################################################################
     if [ "$veget_version" == "false" ] ; then veget_version=orchidee2.0 ; fi
      cd arch
      sed -e s:"%COMPILER        .*.$":"%COMPILER            $compiler":1 \
     -e s:"%LINK            .*.$":"%LINK                $compiler":1 \
     -e s:"%FPP_FLAGS       .*.$":"%FPP_FLAGS           $fpp_flags":1 \
     -e s:"%PROD_FFLAGS     .*.$":"%PROD_FFLAGS         $OPTIM":1 \
     -e s:"%DEV_FFLAGS      .*.$":"%DEV_FFLAGS          $OPTDEV":1 \
     -e s:"%DEBUG_FFLAGS    .*.$":"%DEBUG_FFLAGS        $OPTDEB":1 \
     -e s:"%BASE_FFLAGS     .*.$":"%BASE_FFLAGS         $OPTPREC":1 \
     -e s:"%BASE_LD         .*.$":"%BASE_LD             $BASE_LD":1 \
     -e s:"%ARFLAGS         .*.$":"%ARFLAGS             $ARFLAGS":1 \
     arch-gfortran.fcm > arch-local.fcm
     echo "NETCDF_LIBDIR=\"-L${ncdfdir}/lib -lnetcdff -lnetcdf\"" > arch-local.path
     echo "NETCDF_INCDIR=${ncdfdir}/include" >> arch-local.path
     echo "IOIPSL_INCDIR=$ORCHPATH/../../lib" >> arch-local.path
     echo "IOIPSL_LIBDIR=$ORCHPATH/../../lib" >> arch-local.path
     echo 'XIOS_INCDIR=${ORCHDIR}/../XIOS/inc' >> arch-local.path
     echo 'XIOS_LIBDIR="${ORCHDIR}/../XIOS/lib -lxios"' >> arch-local.path
     cd ../

     # Ajouter les arch de TOUBKAL ici par un cp depuis lustre (Mohammad)
      if [ ${hostname:0:5} = slurm ] ; then
          cp /srv/lustre01/project/climat-um6p-st-iwri-7ksifkvwkuy/Mohammad/Utils/arch_toubkal/orchidee/* arch/.
      fi

     echo ./makeorchidee_fcm -j $xios_orchid $opt_orc -parallel none -arch $arch
     ./makeorchidee_fcm -j 8 $xios_orchid $opt_orc -parallel none -arch $arch > $orchideelog 2>&1
     pwd
  else # of "if [ -d tools ]"
     if [ -d src_parallel ] ; then
       liste_src="parallel parameters global stomate sechiba driver"
       if [ "$veget_version" == "false" ] ; then veget_version=orchidee2.0 ; fi
     fi
     for d in $liste_src ; do src_d=src_$d
        echo src_d $src_d
        echo ls ; ls
        if [ ! -d $src_d ] ; then echo Problem orchidee : no $src_d ; exit ; fi
        cd $src_d ; \rm -f *.mod make ; $make clean
        $make > $orchideelog 2>&1 ; if [ "$compiler" = "$gfortran" -o "$compiler" = "mpif90" ] ; then cp -f *.mod ../../../lib ; fi
        cd ..
     done
  fi # of "if [ -d tools ]" 
  echo install_lmdz.sh orchidee_compil_seq_OK `date`
fi # of if [ "$veget" != 'NONE' ] 



