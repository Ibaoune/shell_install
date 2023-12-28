#=========================================================================
if [ "$with_xios" = "y" ] ; then
  echo '##########################################################'
  echo 'Compiling XIOS'
  echo '##########################################################'
  cd $MODEL/modipsl/modeles
  xioslog=`pwd`/xios.log
  #wget http://www.lmd.jussieu.fr/~lmdz/Distrib/install_xios.bash
  myget script_install/install_xios.bash
  chmod u=rwx install_xios.bash
  if [ ${hostname:0:5} = jean- ] ; then
     svn co http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/xios-2.5 XIOS
     cd XIOS/arch
     svn update
     cd ..
     echo "Compiling XIOS, start" `date` "(it takes about 20 min on Jean-Zay)"
     echo "log file: $xioslog"
     ./make_xios --prod --arch $arch --job 4 > xios.log 2>&1
  elif [ ${hostname:0:5} = slurm ] ; then
     svn co http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/xios-2.5 XIOS
     # Ajouter les arch de TOUBKAL ici par un cp depuis lustre (Mohammad)
     cd XIOS/arch
     cp /srv/lustre01/project/climat-um6p-st-iwri-7ksifkvwkuy/Mohammad/Utils/arch_toubkal/xios/* .
     cd ..
     echo "Compiling XIOS, start" `date`
     echo "log file: $xioslog"
     ./make_xios --prod --arch $arch --job 4 > xios.log 2>&1
  else
     ./install_xios.bash -prefix $MODEL/modipsl/modeles \
                      -netcdf ${ncdfdir} -hdf5 ${ncdfdir} \
                      -MPI $root_mpi -arch $arch > xios.log 2>&1
  fi # of case Jean-Zay
  if [ -f XIOS/lib/libxios.a ] ; then
     echo "XIOS library successfully generated"
     echo install_lmdz.sh XIOS_OK `date`
  fi
fi

