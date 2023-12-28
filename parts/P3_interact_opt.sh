

#########################################################################
#  Options interactives
#########################################################################
while (($# > 0))
   do
   case $1 in
     "-h") cat <<........fin
    $0 [ -v version ] [ -r svn_release ]
           [ -parallel PARA ] [ -d GRID_RESOLUTION ] [ -bench 0/1 ]
           [-name LOCAL_MODEL_NAME] [-gprof] [-opt_makelmdz] [-rad RADIATIF]

    -v       "version" like 20150828.trunk
             see http://www.lmd.jussieu.fr/~lmdz/Distrib/LISMOI.trunk

    -r       "svn_release" : either the svn release number or "last"

    -compiler gfortran|ifort|pgf90 (default: gfortran)

    -parallel PARA : can be mpi_omp (mpi with openMP) or none (for sequential)

    -d        GRID_RESOLUTION should be among the available benchs if -bench 1
              among which : 48x36x19, 48x36x39
              if wanting to run a bench simulation in addition to compilation
              default : 48x36x19

    -bench     activating the bench or not (0/1). Default 1

    -name      LOCAL_MODEL_NAME : default = LMDZversion.release

    -netcdf    PATH : full path to an existing installed NetCDF library
               (without -netcdf: also download and install the NetCDF library)

    -xios      also download and compile the XIOS library
               (requires the NetCDF4-HDF5 library, also installed by default)
               (requires to also have -parallel mpi_omp)

    -gprof     to compile with -pg to enable profiling with gprof

    -cosp      to run without our with cospv1 or cospv2 [none/v1/v2]

    -rad RADIATIF can be old, rrtm or ecrad radiatif code

    -nofcm     to compile without fcm

    -SCM        install 1D version automatically
    -debug      compile everything in debug mode

    -opt_makelmdz     to call makelmdz or makelmdz_fcm with additional options

    -physiq    to choose which physics package to use

    -env_file  specify an arch.env file to overwrite the existing one

    -veget surface model to run [NONE/CMIP6/xxxx]

........fin
     exit ;;
     "-v") version=$2 ; shift ; shift ;;
     "-r") svn=$2 ; shift ; shift ;;
     "-compiler") compiler=$2
                  case $compiler in
                    "gfortran"|"ifort"|"pgf90") compiler=$2 ; shift ; shift ;;
                    *) echo "Only gfortran , ifort or pgf90 for the compiler option" ; exit
                  esac ;;
     "-d") grid_resolution=$2 ; shift ; shift ;;
     "-gprof") OPT_GPROF="-pg" ; shift ;;
     "-cosp") cosp=$2
              case $cosp in
                  "none"|"v1"|"v2") cosp=$2 ; shift ; shift ;;
                  *) echo Only none v1 v2 for cosp option ; exit
              esac ;;
     "-nofcm") compile_with_fcm=0 ; shift ;;
     "-SCM") SCM=1 ; shift ;;
     "-opt_makelmdz") OPT_MAKELMDZ="$2" ; shift ; shift ;;
     "-rad") rad=$2
             case $rad in
                "old"|"rrtm"|"ecrad") rad=$2 ; shift ; shift ;;
                *) echo Only old rrtm ecrad for rad option ; exit
             esac ;;
     "-parallel") parallel=$2
                  case $parallel in
                    "none"|"mpi"|"omp"|"mpi_omp") parallel=$2 ; shift ; shift ;;
                    *) echo Only none mpi omp mpi_omp for the parallel option ; exit
                  esac ;;
     "-bench") bench=$2 ; shift ; shift ;;
     "-debug") optim=-debug ; shift ;;
     "-name") MODEL=$2 ; shift ; shift ;;
     "-netcdf") netcdf=$2 ; shift ; shift ;;
     "-physiq") physiq=$2 ; shift ; shift ;;
     "-xios") with_xios="y" ; shift ;;
     "-env_file") env_file=$2 ; shift ; shift ;;
     "-veget") veget=$2 ; shift ; shift ;;
     *) ./install_lmdz.sh -h ; exit
   esac
done
