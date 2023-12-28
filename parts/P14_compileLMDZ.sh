
#============================================================================
# Ehouarn: the directory name LMDZ* depends on version/tar file...
if [ -d $MODEL/modipsl/modeles/LMD* ] ; then
  echo '###############################################################'
  echo 'Preparing LMDZ compilation : arch file, svn switch if needed...'
  echo '###############################################################'
  cd $MODEL/modipsl/modeles/LMD*
  LMDZPATH=`pwd`
else
  echo "ERROR: No LMD* directory !!!"
  exit
fi

###########################################################
# For those who want to use fcm to compile via :
#  makelmdz_fcm -arch local .....
############################################################

if [ "$pclinux" = "1" ] ; then

# create local 'arch' files (if on Linux PC):
cd arch
# arch-local.path file
echo "NETCDF_LIBDIR=\"-L${ncdfdir}/lib -lnetcdff -lnetcdf\"" > arch-local.path
echo "NETCDF_INCDIR=-I${ncdfdir}/include" >> arch-local.path
echo 'IOIPSL_INCDIR=$LMDGCM/../../lib' >> arch-local.path
echo 'IOIPSL_LIBDIR=$LMDGCM/../../lib' >> arch-local.path
echo 'XIOS_INCDIR=$LMDGCM/../XIOS/inc' >> arch-local.path
echo 'XIOS_LIBDIR=$LMDGCM/../XIOS/lib' >> arch-local.path
echo 'ORCH_INCDIR=$LMDGCM/../../lib' >> arch-local.path
echo 'ORCH_LIBDIR=$LMDGCM/../../lib' >> arch-local.path

if [ $pcmac == 1 ] ; then
    BASE_LD="$BASE_LD -Wl,-rpath,${ncdfdir}/lib"
else
    BASE_LD="$BASE_LD -Wl,-rpath=${ncdfdir}/lib"
fi
# Arch-local.fcm file (adapted from arch-linux-32bit.fcm)

if [ $real = r8 ] ; then FPP_DEF=NC_DOUBLE ; else FPP_DEF="" ; fi
sed -e s:"%COMPILER        .*.$":"%COMPILER            $compiler":1 \
    -e s:"%LINK            .*.$":"%LINK                $compiler":1 \
    -e s:"%PROD_FFLAGS     .*.$":"%PROD_FFLAGS         $OPTIM":1 \
    -e s:"%DEV_FFLAGS      .*.$":"%DEV_FFLAGS          $OPTDEV":1 \
    -e s:"%DEBUG_FFLAGS    .*.$":"%DEBUG_FFLAGS        $OPTDEB":1 \
    -e s:"%BASE_FFLAGS     .*.$":"%BASE_FFLAGS         $OPTPREC":1 \
    -e s:"%FPP_DEF         .*.$":"%FPP_DEF             $FPP_DEF":1 \
    -e s:"%BASE_LD         .*.$":"%BASE_LD             $BASE_LD":1 \
    -e s:"%ARFLAGS         .*.$":"%ARFLAGS             $ARFLAGS":1 \
    arch-linux-32bit.fcm > arch-local.fcm

cd ..
### Adapt "bld.cfg" (add the shell):
#whereisthatshell=$(which ${use_shell})
#echo "bld::tool::SHELL   $whereisthatshell" >> bld.cfg

fi # of if [ "$pclinux" = 1 ]


cd $MODEL/modipsl/modeles/LMDZ*
lmdzlog=`pwd`/lmdz.log

##################################################################
# Possibly update LMDZ if a specific svn release is requested
##################################################################

set +e ; svn upgrade ; set -e

if [ "$svn" = "last" ] ; then svnopt="" ; else svnopt="-r $svn" ; fi
if [ "$svn" != "" ] ; then
    set +e ; svn info | grep -q 'http:'
    if [ $? = 0 ] ; then
        svn switch --relocate http://svn.lmd.jussieu.fr/LMDZ https://svn.lmd.jussieu.fr/LMDZ
    fi
    svn update $svnopt
fi
set -e

echo '##################################################################'
echo "Preparing script compile.sh for LMDZ compilation"
echo "It will only be run automatically if bench=1/tuto"
echo Here bench=$bench
echo '##################################################################'

if [ "$env_file" != "" ] ; then mv arch/arch-${arch}.env arch/arch-${arch}.orig ; \cp -f $env_file arch/arch-${arch}.env ; fi

if [ $compile_with_fcm = 1 ] ; then makelmdz="makelmdz_fcm $optim -arch $arch -j 8 " ; else makelmdz="makelmdz $optim -arch $arch" ; fi

# sequential compilation
if [ "$sequential" = 1 ] ; then
  echo Sequential compilation command, saved in compile.sh:
  echo "./$makelmdz $optim $OPT_MAKELMDZ $optim $opt_rad $opt_cosp -d ${grid_resolution} -v $veget_version gcm "
  echo "./$makelmdz $optim $OPT_MAKELMDZ $optim $opt_rad $opt_cosp -d ${grid_resolution} -v $veget_version gcm " >> compile.sh
  chmod +x ./compile.sh
  if [ $bench = 1 ] ; then
    echo install_lmdz.sh start_lmdz_seq_compilation `date`
    echo log file: $lmdzlog
    ./compile.sh > $lmdzlog 2>&1
    echo install_lmdz.sh end_lmdz_seq_compilation `date`
  fi
fi # fin sequential


# compiling in parallel mode
if [ $parallel != "none" ] ; then
  echo '##########################################################'
  echo ' Parallel compile '
  echo '##########################################################'
  echo "(after saving the sequential libs and binaries)"
  cd $MODEL/modipsl
  tar cf sequential.tar bin/ lib/
  \rm -rf bin/ lib/
  tar xf ioipsl.tar
  #
  # Orchidee
  #
  cd $ORCHPATH
  if [ -d src_parallel -a $veget != 'NONE' ] ; then
     cd arch
     sed  \
     -e s:"%COMPILER.*.$":"%COMPILER            $par_comp":1 \
     -e s:"%LINK.*.$":"%LINK                $par_comp":1 \
     -e s:"%MPI_FFLAG.*.$":"%MPI_FFLAGS          $MPI_FLAGS":1 \
     -e s:"%OMP_FFLAG.*.$":"%OMP_FFLAGS          $OMP_FLAGS":1 \
     -e s:"%MPI_LD.*.$":"%MPI_LD              $MPI_LD":1 \
     -e s:"%OMP_LD.*.$":"%OMP_LD              $OMP_LD":1 \
     arch-local.fcm > tmp.fcm

     mv tmp.fcm arch-local.fcm
     cd ../
     echo Compiling ORCHIDEE in parallel mode `date`
     echo logfile $orchideelog
     echo "NOTE : to recompile it when necessary, use ./compile_orc.sh in modipsl/modeles/ORCHIDEE"
     echo ./makeorchidee_fcm -j 8 -clean $xios_orchid $opt_orc -parallel $parallel -arch $arch > compile_orc.sh
     echo ./makeorchidee_fcm -j 8 $xios_orchid $opt_orc -parallel $parallel -arch $arch >> compile_orc.sh
     echo echo Now you must also recompile LMDZ, by running ./compile.sh in modeles/LMDZ >> compile_orc.sh
     chmod u+x compile_orc.sh
     ./makeorchidee_fcm -j 8 -clean $xios_orchid $opt_orc -parallel $parallel -arch $arch > $orchideelog 2>&1
     ./makeorchidee_fcm -j 8 $xios_orchid $opt_orc -parallel $parallel -arch $arch >> $orchideelog 2>&1
     echo End of ORCHIDEE compilation in parallel mode `date`
  elif [ $veget != 'NONE' ] ; then
    echo '##########################################################'
    echo ' Orchidee version too old                                 '
    echo ' Please update to new version                             '
    echo '##########################################################'
    exit
  fi # of [ -d src_parallel -a $veget != 'NONE' ]

  # LMDZ
  cd $LMDZPATH
  if [ $arch = local ] ; then
    cd arch
    sed -e s:"%COMPILER.*.$":"%COMPILER            $par_comp":1 \
    -e s:"%LINK.*.$":"%LINK                $par_comp":1 \
    -e s:"%MPI_FFLAG.*.$":"%MPI_FFLAGS          $MPI_FLAGS":1 \
    -e s:"%OMP_FFLAG.*.$":"%OMP_FFLAGS          $OMP_FLAGS":1 \
    -e s:"%ARFLAGS.*.$":"%ARFLAGS          $ARFLAGS":1 \
    -e s@"%BASE_LD.*.$"@"%BASE_LD             -Wl,-rpath=${root_mpi}/lib:${ncdfdir}/lib"@1 \
    -e s:"%MPI_LD.*.$":"%MPI_LD              $MPI_LD":1 \
    -e s:"%OMP_LD.*.$":"%OMP_LD              $OMP_LD":1 \
    arch-local.fcm > tmp.fcm
    mv tmp.fcm arch-local.fcm
    cd ../
  fi
  # Ajouter les arch de TOUBKAL ici par un cp depuis lustre (Mohammad).
  if [ ${hostname:0:5} = slurm ] ; then
          cp /srv/lustre01/project/climat-um6p-st-iwri-7ksifkvwkuy/Mohammad/Utils/arch_toubkal/lmdz/* arch/.
  fi
  rm -f compile.sh
  echo resol=${grid_resolution} >> compile.sh
  if [ ${hostname:0:5} = jean- -a "$cosp" = "v2" ] ; then

  echo LMDZ compilation command in parallel mode, saved in compile.sh, is : 
  echo "(ATTENTION le probleme de cospv2 sur jean-zay en mode prod n est pas corrige ! )"
# ATTENTION le probleme de cospv2 sur jean-zay en mode prod n est pas corrige
     echo ./$makelmdz -dev $optim $OPT_MAKELMDZ $opt_rad $opt_cosp $opt_makelmdz_xios -d \$resol -v $veget_version -mem -parallel $parallel gcm >> compile.sh
     echo ./$makelmdz -dev $optim $OPT_MAKELMDZ $opt_rad $opt_cosp $opt_makelmdz_xios -d \$resol -v $veget_version -mem -parallel $parallel gcm 
  else
    echo ./$makelmdz $optim $OPT_MAKELMDZ $opt_rad $opt_cosp $opt_makelmdz_xios -d \$resol -v $veget_version -mem -parallel $parallel gcm >> compile.sh
    echo ./$makelmdz $optim $OPT_MAKELMDZ $opt_rad $opt_cosp $opt_makelmdz_xios -d \$resol -v $veget_version -mem -parallel $parallel gcm 
  fi
  chmod +x ./compile.sh

  if [ $bench = 1 ] ; then
     echo Compiling LMDZ in parallel mode `date`,  LMDZ log file: $lmdzlog ; ./compile.sh > $lmdzlog 2>&1
  fi

fi # of if [ $parallel != "none" ]




