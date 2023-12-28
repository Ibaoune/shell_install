echo '################################################################'
echo  Choix des options de compilation
echo '################################################################'

export FC=$compiler
export F90=$compiler
export F77=$compiler
export CPPFLAGS=
OPTIMNC=$OPTIM
BASE_LD="$OPT_GPROF"
OPTPREC="$OPT_GPROF"
ARFLAGS="rs" ; if [ -f /etc/issue ] ; then if [ "`grep -i ubuntu /etc/issue`" != "" ] ; then if [ "`grep -i ubuntu /etc/issue | awk ' { print $2 } ' | cut -d. -f1`" -ge 16 ] ; then ARFLAGS="rU" ; fi ; fi ; fi



if [ "$compiler" = "$gfortran" ] ; then
   OPTIM='-O3'
   OPTDEB="-g3 -Wall -fbounds-check -ffpe-trap=invalid,zero,overflow -O0 -fstack-protector-all -fbacktrace -finit-real=snan"
   OPTDEV="-Wall -fbounds-check"
   fmod='I '
   OPTPREC="$OPTPREC -cpp -ffree-line-length-0"
   if [ $real = r8 ] ; then OPTPREC="$OPTPREC -fdefault-real-8 -DNC_DOUBLE" ; fi
   export F90FLAGS=" -ffree-form $OPTIMNC"
   export FFLAGS=" $OPTIMNC"
   export CC=gcc
   export CXX=g++
   export fpp_flags="-P -C -traditional -ffreestanding"

elif [ $compiler = mpif90 ] ; then
   OPTIM='-O3'
   OPTDEB="-g3 -Wall -fbounds-check -ffpe-trap=invalid,zero,overflow -O0 -fstack-protector-all"
   OPTDEV="-Wall -fbounds-check"
   BASE_LD="$BASE_LD -lblas"
   fmod='I '
   if [ $real = r8 ] ; then OPTPREC="$OPTPREC -fdefault-real-8 -DNC_DOUBLE -fcray-pointer" ; fi
   export F90FLAGS=" -ffree-form $OPTIMNC"
   export FFLAGS=" $OPTIMNC"
   export CC=gcc
   export CXX=g++
elif [ $compiler = pgf90 ] ; then
   OPTIM='-O2 -Mipa -Munroll -Mnoframe -Mautoinline -Mcache_align'
   OPTDEB='-g -Mdclchk -Mbounds -Mchkfpstk -Mchkptr -Minform=inform -Mstandard -Ktrap=fp -traceback'
   OPTDEV='-g -Mbounds -Ktrap=fp -traceback'
   fmod='module '
   if [ $real = r8 ] ; then OPTPREC="$OPTPREC -r8 -DNC_DOUBLE" ; fi
   export CPPFLAGS="-DpgiFortran"
   export CC=pgcc
   export CFLAGS="-O2 -Msignextend"
   export CXX=pgCC
   export CXXFLAGS="-O2 -Msignextend"
   export FFLAGS="-O2 $OPTIMNC"
   export F90FLAGS="-O2 $OPTIMNC"
   compile_with_fcm=1

elif [ $compiler = ifort ] ; then
   OPTIM="-O2 -fp-model strict -ip -align all "
   OPTDEV="-p -g -O2 -traceback -fp-stack-check -ftrapuv -check"
   OPTDEB="-g -no-ftz -traceback -ftrapuv -fp-stack-check -check"
   fmod='module '
   if [ $real = r8 ] ; then OPTPREC="$OPTPREC -real-size 64 -DNC_DOUBLE" ; fi
   export CPP="icc -E"
   export FFLAGS="-O2 -ip -fpic -mcmodel=large"
   export FCFLAGS="-O2 -ip -fpic -mcmodel=large"
   export CC=icc
   export CFLAGS="-O2 -ip -fpic -mcmodel=large"
   export CXX=icpc
   export CXXFLAGS="-O2 -ip -fpic -mcmodel=large"
   export fpp_flags="-P -traditional"
   # Pourquoi forcer la compilation fcm. Marche mieux sans
   #compile_with_fcm=1

elif [ $compiler = mpiifort ] ; then
   echo on ne fait rien la
   # Pourquoi forcer la compilation fcm. Marche mieux sans
   #compile_with_fcm=1

else
   echo unexpected compiler $compiler ; exit
fi

OPTIMGCM="$OPTIM $OPTPREC"

hostname=`hostname`

if [ ${hostname:0:5} = slurm ] ; then
  netcdf=1 # no need to recompile netcdf, alreday available
  #check_linux=0
  #pclinux=0
  ioipsl=1 # no need to recompile ioipsl, already available
  #netcdf="/smplocal/pub/NetCDF/4.1.3"
  netcdf="/srv/software/easybuild/software/netCDF-Fortran/4.4.4-foss-2018b"
  compiler="mpif90"
  #fmod='module '
  #if [ $real = r8 ] ; then OPTPREC="$OPTPREC -i4 -r8 -DNC_DOUBLE" ; fi
  #OPTIM="-auto -align all -O2 -fp-model strict -xHost "
  #OPTIMGCM="$OPTIM $OPTPREC"
fi
##########################################################################


mkdir -p $MODEL
echo $MODEL
MODEL=`( cd $MODEL ; pwd )` # to get absolute path, if necessary


