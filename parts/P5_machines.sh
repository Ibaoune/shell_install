
if [ $compiler = g95 ] ; then echo g95 is not supported anymore ; exit ; fi

################################################################
# Specificite des machines
################################################################

hostname=`hostname`
if [ "$pclinux" = 1 ] ; then o_ins_make="-t g95" ; else o_ins_make="" ; fi

case ${hostname:0:5} in

    slurm) compiler="gfortran" ;
           module purge ;
           module load GCC/7.3.0-2.30 ;
           if [ $parallel != none ] ; then
             module purge ;
             module load Subversion ;
             module load GCC/7.3.0-2.30 ;
             module load OpenMPI/3.1.1-GCC-7.3.0-2.30 ;
             module load netCDF/4.6.1-foss-2018b ;
             module load netCDF-Fortran/4.4.4-foss-2018b ;
             root_mpi=/srv/software/easybuild/software/OpenMPI/3.1.1-GCC-7.3.0-2.30 ;
             path_mpi=$root_mpi/bin ;
             par_comp=${path_mpi}/mpif90 ;
             mpirun=${path_mpi}/mpirun ;
             make=make ;# A noter que gmake ne foctionne pas ici . A investiguer pourquoi après ?
             arch=X64_TOUBKAL ;
           else
             arch=local  ;
             make=make ;
           fi ;;
   *)       if [ $parallel = none -o -f /usr/bin/mpif90 ] ; then
                path_mpi=`which mpif90 | sed -e s:/mpif90::` ;
                if [ -d /usr/lib64/openmpi ] ; then
                  root_mpi="/usr/lib64/openmpi"
                else
                  root_mpi="/usr"
                fi
            else
               echo "Cannot find mpif90" ;
               if [ $parallel = none ] ; then exit ; fi ;
            fi ;
            if [ $parallel != none ] ; then
              root_mpi=$(which mpif90 | sed -e s:/bin/mpif90::)
              path_mpi=$(which mpif90 | sed -e s:/mpif90::)
              export LD_LIBRARY_PATH=${root_mpi}/lib:$LD_LIBRARY_PATH
            fi
            par_comp=${path_mpi}/mpif90 ;
            mpirun=${path_mpi}/mpirun ;
            arch=local  ;
            make=make ;
            o_ins_make="-t g95"
esac

