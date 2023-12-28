###########################################################################
if [ $netcdf = 1 -a ! -d $MODEL/netcdf ] ; then
###########################################################################
   cd $MODEL
   netcdflog=`pwd`/netcdf.log
   echo '##########################################################'
   echo Compiling the Netcdf library
   echo '##########################################################'
   echo log file : $netcdflog
   if [ "$with_xios" = "n" ] ; then
      # keep it simple
      #wget http://www.lmd.jussieu.fr/~lmdz/Distrib/netcdf-4.0.1.tar.gz
      myget import/netcdf-4.0.1.tar.gz
      gunzip netcdf-4.0.1.tar.gz
      tar xvf netcdf-4.0.1.tar
      \rm -f netcdf-4.0.1.tar

      cd netcdf-4.0.1

      localdir=`pwd -P`
      ./configure --prefix=$localdir --enable-shared --disable-cxx
      #sed -e 's/gfortran/'$gfortran'/g' Makefile >| tmp ; mv -f tmp Makefile
      $make check > $netcdflog 2>&1
      $make install >> $netcdflog 2>&1
    #LF rajout d'une verrue, pour une raison non encore expliquee, la librairie est parfois rangée dans lib64
    #   et non dans lib par certains compilateurs
      if [ ! -e lib -a -d lib64 ] ; then ln -s lib64 lib; fi
   else
      # download and compile hdf5 and netcdf, etc. using the install_netcdf4_hdf5.bash script
      #wget http://www.lmd.jussieu.fr/~lmdz/Distrib/install_netcdf4_hdf5.bash
      myget import/install_netcdf4_hdf5.bash
      chmod u=rwx install_netcdf4_hdf5.bash
      if [ "$compiler" = "gfortran" ] ; then
      ./install_netcdf4_hdf5.bash -prefix $MODEL/netcdf4_hdf5 -CC gcc -FC gfortran -CXX g++ -MPI $root_mpi  > $netcdflog 2>&1
      elif [ "$compiler" = "ifort" ] ; then
      ./install_netcdf4_hdf5.bash -prefix $MODEL/netcdf4_hdf5 -CC icc -FC ifort -CXX icpc -MPI $root_mpi  > $netcdflog 2>&1
      elif [ "$compiler" = "pgf90" ] ; then
      ./install_netcdf4_hdf5.bash -prefix $MODEL/netcdf4_hdf5 -CC pgcc -FC pgf90 -CXX pgCC -MPI $root_mpi  > $netcdflog 2>&1
      else
        echo "unexpected compiler $compiler" ; exit
      fi
   fi  # of if [ "$with_xios" = "n" ]
   echo install_lmdz.sh netcdf_OK `date`
fi # of if [ $netcdf = 1 ]

# ncdfdir contains the directory where netcdfd is installed
if [ $netcdf = 0 -o $netcdf = 1 ] ; then
   if [ "$with_xios" = "y" ] ; then
      ncdfdir=$MODEL/netcdf4_hdf5
   else
      ncdfdir=$MODEL/netcdf-4.0.1
   fi
else
   ncdfdir=$netcdf
fi

