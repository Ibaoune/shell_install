
# 04_2021 : tester si r4 marche encore !
#real=r4
real=r8

svn=""
#version=trunk
version=20220131.trunk

getlmdzor=1
netcdf=1   #  1 for automatic installation
           #  0 for no installation
           #  /.../../netcdf-4.0.1 if wanting to link with an already
           #  compiled netcdf library (implies to check option compatibility)
check_linux=1
ioipsl=1
bench=1
pclinux=1
pcmac=0 # default: not on a Mac
compiler=gfortran
SCM=0
# surface/vegetation scheme treatment
# controlled by the single variable veget which can have the following values
# - NONE: bucket scheme (default)
# - CMIP6: orchidee version used in CMIP exercise, rev 5661
# - number: orchidee version number
veget=CMIP6
# choose the resolution for the bench runs
# grid_resolution= 32x24x11 or 48x36x19 for tests (test without ORCHIDEE)
#                  96x71x19  standard configuration
grid_resolution=144x142x79
#grid_resolution=96x95x39
#grid_resolution=48x36x19
#grid_resolution=32x32x39
#grid_resolution=144x142x79
# choose the physiq version you want to test
#physiq=NPv6.0.14splith
physiq=

## parallel can take the values none/mpi/omp/mpi_omp
parallel=mpi_omp
#parallel=none
idris_acct=lmd
OPT_GPROF=""
OPT_MAKELMDZ=""
MODEL=""

## also compile XIOS? (and more recent NetCDF/HDF5 libraries) Default=no
with_xios="y"
opt_makelmdz_xios=""

## compile with old/rrtm/ecrad radiatif code (Default=rrtm)
rad=rrtm

## compile_with_fcm=1 : use makelmdz_fcm (1) or makelmdz (0)
compile_with_fcm=1

#Compilation with Cosp (cosp=NONE/v1/v2 ; default=NONE)
cosp=NONE
opt_cosp=""

# Check if on a Mac
if [ `uname` = "Darwin" ]
then
    pcmac=1
    export MAKE=make
fi
#echo "pcmac="$pcmac

env_file=""

