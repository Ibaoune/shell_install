
# Flags for parallelism:
if [ $parallel != none ] ; then
  # MPI_LD are the flags needed for linking with MPI
  MPI_LD="-L${root_mpi}/lib -lmpi"
  if [ "$compiler" = "gfortran" ] ; then
    # MPI_FLAGS are the flags needed for compilation with MPI
    MPI_FLAGS="-fcray-pointer"
    # OMP_FLAGS are the flags needed for compilation with OpenMP
    OMP_FLAGS="-fopenmp -fcray-pointer"
    # OMP_LD are the flags needed for linking with OpenMP
    OMP_LD="-fopenmp"
  elif [ "$compiler" = "ifort" ] ; then
    MPI_FLAGS=""
    OMP_FLAGS="-openmp"
    OMP_LD="-openmp"
  else # pgf90
    MPI_FLAGS=""
    OMP_FLAGS="-mp"
    OMP_LD="-mp"
  fi
fi

#####################################################################
# Test for old gfortran compilers
# If the compiler is too old (older than 4.3.x) we test if the
# temporary gfortran44 patch is available on the computer in which
# case the compiler is changed from gfortran to gfortran44
# Must be aware than parallelism can not be activated in this case
#####################################################################

if [ "$compiler" = "gfortran" ] ; then
   gfortran=gfortran
   gfortranv=`gfortran --version | \
   head -1 | awk ' { print $NF } ' | awk -F. ' { print $1 * 10 + $2 } '`
   if [ $gfortranv -le 43 ] ; then
       echo ERROR : Your gfortran compiler is too old
       echo 'Please choose a new one (ifort) and change the line'
       echo compiler=xxx
       echo in the install_lmdz.sh script and rerun it
       if [ `which gfortran44 | wc -w` -ne 0 ] ; then
          gfortran=gfortran44
       else
          echo gfotran trop vieux ; exit
       fi
   fi
   compiler=$gfortran
fi


## if also compiling XIOS, parallel must be mpi_omp
if [ "$with_xios" = "y" -a "$parallel" != "mpi_omp" ] ; then
  echo "Error, you must set -parallel mpi_omp if you want XIOS"
  exit
fi

if [ "$with_xios" = "y" ] ; then
  opt_makelmdz_xios="-io xios"
fi

if [ "$cosp" = "v2" -a "$with_xios" = "n" ] ; then
  echo "Error, Cospv2 cannot run without Xios"
  exit
fi

