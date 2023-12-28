##################################################################
# Below, we run a benchmark if bench=1 or tuto
##################################################################

if [ $bench = tuto ] ; then
   myget Training/tutorial.tar ; tar xvf tutorial.tar ; cd TUTORIAL ; ./init.sh

elif [ $bench = 1 ] ; then
   # TOUTE CETTE SECTION DEVRAIT DISPARAITRE POUR UNE COMMANDE
   # OU DES BENCHS PAR MOTS CLES COMME tuto

   echo '##########################################################'
   echo ' Running a test run '
   echo '##########################################################'

   \rm -rf BENCH${grid_resolution}
   bench=bench_lmdz_${grid_resolution}
   echo install_lmdz.sh before bench download  `date`
   #wget http://www.lmd.jussieu.fr/~lmdz/Distrib/$bench.tar.gz
   myget 3DBenchs/$bench.tar.gz
   echo install_lmdz.sh after bench download  `date`
   tar xvf $bench.tar.gz

   if [ "$cosp" = "v1" -o "$cosp" = "v2" ] ; then
     cd BENCH${grid_resolution}
   # copier les fichiers namelist input et output our COSP
     cp ../DefLists/cosp*_input_nl.txt .
     cp ../DefLists/cosp*_output_nl.txt .
   # Activer la cles ok_cosp pour tourner avec COSP
     sed -e 's@ok_cosp=n@ok_cosp=y@' config.def > tmp
      \mv -f tmp config.def
     cd ..
   fi

   if [ -n "$physiq" ]; then
     cd BENCH${grid_resolution}
     if [ -f physiq.def_${physiq} ]; then
       cp physiq.def_${physiq} physiq.def
       echo using physiq.def_${physiq}
     else
       echo using standard physiq.def
     fi
     cd ..
   else
     echo using standard physiq.def
   fi

   if [ "$with_xios" = "y" ] ; then
     cd BENCH${grid_resolution}
     cp ../DefLists/iodef.xml .
     cp ../DefLists/context_lmdz.xml .
     cp ../DefLists/field_def_lmdz.xml .
   # A raffiner par la suite
     echo A FAIRE : Copier les *xml en fonction de l option cosp
     cp ../DefLists/field_def_cosp*.xml .
     cp ../DefLists/file_def_hist*xml .
     # adapt iodef.xml to use attached mode
     sed -e 's@"using_server" type="bool">true@"using_server" type="bool">false@' iodef.xml > tmp
     \mv -f tmp iodef.xml

     # and convert all the enabled="_AUTO_" (for libIGCM) to enabled=.FALSE.
     # except for histday
     for histfile in file_def_hist*xml
     do
       if [ "$histfile" = "file_def_histday_lmdz.xml" ] ; then
       sed -e 's@enabled="_AUTO_"@type="one_file" enabled=".TRUE."@' $histfile > tmp ; \mv -f tmp $histfile
       sed -e 's@output_level="_AUTO_"@output_level="5"@' $histfile > tmp ; \mv -f tmp $histfile
       sed -e 's@compression_level="2"@compression_level="0"@' $histfile > tmp ; \mv -f tmp $histfile
       else
       sed -e 's@enabled="_AUTO_"@type="one_file" enabled=".FALSE."@' $histfile > tmp ; \mv -f tmp $histfile
       fi
     done
     # and add option "ok_all_xml=y" in config.def
     echo "### XIOS outputs" >> config.def
     echo 'ok_all_xml=.true.' >> config.def

     #activer les sorties pour Cosp
     if [ "$cosp" = "v1" ] ; then
      histfile=file_def_histdayCOSP_lmdz.xml
      sed -e 's@enabled=".FALSE."@enabled=".TRUE."@' $histfile > tmp ; \mv -f tmp $histfile
      sed -e 's@output_level="_AUTO_"@output_level="5"@' $histfile > tmp ; \mv -f tmp $histfile
      sed -e 's@compression_level="2"@compression_level="0"@' $histfile > tmp ; \mv -f tmp $histfile
     fi
     if [ "$cosp" = "v2" ] ; then
      histfile=file_def_histdayCOSPv2_lmdz.xml
      sed -e 's@compression_level="2"@compression_level="0"@' $histfile > tmp ; \mv -f tmp $histfile
      contextfile=context_lmdz.xml
      sed -e 's@src="./file_def_histdayCOSP_lmdz.xml"@src="./file_def_histdayCOSPv2_lmdz.xml"@' $contextfile > tmp ; \mv -f tmp $contextfile
      sed -e 's@src="./file_def_histmthCOSP_lmdz.xml"@src="./file_def_histmthCOSPv2_lmdz.xml"@' $contextfile > tmp ; \mv -f tmp $contextfile
      sed -e 's@src="./file_def_histhfCOSP_lmdz.xml"@src="./file_def_histhfCOSPv2_lmdz.xml"@' $contextfile > tmp ; \mv -f tmp $contextfile
      fieldfile=field_def_lmdz.xml
      sed -e 's@field_def_cosp1.xml@field_def_cospv2.xml@' $fieldfile > tmp ; \mv -f tmp $fieldfile
     fi

     cd ..
   fi

   # Cas Bensh avec ecrad
   if [ "$rad" = "ecrad" ] ; then
     cd BENCH${grid_resolution}
     cp  ../DefLists/namelist_ecrad .
     cp -r ../libf/phylmd/ecrad/data .
   # Attention au cas ou ne 1
     sed -e 's@iflag_rrtm=1@iflag_rrtm=2@' physiq.def > tmp
      \mv -f tmp physiq.def
     cd ..
   fi

   cp $gcm BENCH${grid_resolution}/gcm.e

   cd BENCH${grid_resolution}
   # On cree le fichier bench.sh au besoin
   # Dans le cas 48x36x39 le bench.sh existe deja en parallele

   if [ "$grid_resolution" = "48x36x39" ] ; then
      echo On ne touche pas au bench.sh
      # But we have to adapt "run_local.sh" for $mpirun
      sed -e "s@mpirun@$mpirun@g" run_local.sh > tmp
      mv -f tmp run_local.sh
      chmod u=rwx run_local.sh
   elif [ "${parallel:0:3}" = "mpi" ] ; then
      # Lancement avec deux procs mpi et 2 openMP
      echo "export OMP_STACKSIZE=800M" > bench.sh
      if [ "${parallel:4:3}" = "omp" ] ; then
        echo "export OMP_NUM_THREADS=2" >> bench.sh
      fi
      if [ "$cosp" = "v1" -o "$cosp" = "v2" ] ; then
         if [ ${hostname:0:5} = jean- ] ; then
        chmod +x ../arch.env
           ../arch.env
           echo "ulimit -s 2000000" >> bench.sh
         else
           echo "ulimit -s 200000" >> bench.sh
         fi
      else
         echo "ulimit -s unlimited" >> bench.sh
      fi
      if [ ${hostname:0:5} = jean- ] ; then
        . ../arch/arch-${arch}.env
        echo "srun -n 2 -A $idris_acct@cpu gcm.e > listing  2>&1" >> bench.sh
      else
        echo "$mpirun -np 2 gcm.e > listing  2>&1" >> bench.sh
      fi
      # Add rebuild, using reb.sh if it is there
      echo 'if [ -f reb.sh ] ; then' >> bench.sh
      echo '  ./reb.sh histday ; ./reb.sh histmth ; ./reb.sh histhf ; ./reb.sh histins ; ./reb.sh stomate_history ; ./reb.sh sechiba_history ; ./reb.sh sechiba_out_2 ' >> bench.sh
      echo 'fi' >> bench.sh
   else
      echo "./gcm.e > listing  2>&1" > bench.sh
   fi
   # Getting orchidee stuff
   if [ $veget == 'CMIP6' ] ; then
       #echo 'myget 3DBenchs/BENCHorch11.tar.gz'
       #myget 3DBenchs/BENCHorch11.tar.gz
       #tar xvzf BENCHorch11.tar.gz
       echo 'myget 3DBenchs/BENCHCMIP6.tar.gz'
       myget 3DBenchs/BENCHCMIP6.tar.gz
       tar xvzf BENCHCMIP6.tar.gz
       sed -e "s:VEGET=n:VEGET=y:" config.def > tmp
       mv -f tmp config.def
       if [ "$with_xios" = "y" ] ; then
         cp ../../ORCHIDEE/src_xml/context_orchidee.xml .
         echo '<context id="orchidee" src="./context_orchidee.xml"/>' > add.tmp
         cp ../../ORCHIDEE/src_xml/field_def_orchidee.xml .
         cp ../../ORCHIDEE/src_xml/file_def_orchidee.xml .
         cp ../../ORCHIDEE/src_xml/file_def_input_orchidee.xml .
         if [ -f ../../ORCHIDEE/src_xml/context_input_orchidee.xml ] ; then
        cp ../../ORCHIDEE/src_xml/context_input_orchidee.xml .
        echo '<context id="orchidee" src="./context_input_orchidee.xml"/>' >> add.tmp
         fi
         sed -e '/id="LMDZ"/r add.tmp' iodef.xml > tmp
         mv tmp iodef.xml
         sed -e'{/sechiba1/ s/enabled="_AUTO_"/type="one_file" enabled=".TRUE."/}' file_def_orchidee.xml > tmp ; \mv -f tmp file_def_orchidee.xml
         sed -e 's@enabled="_AUTO_"@type="one_file" enabled=".FALSE."@' file_def_orchidee.xml > tmp ; \mv -f tmp file_def_orchidee.xml
         sed -e 's@output_level="_AUTO_"@output_level="1"@' file_def_orchidee.xml > tmp ; \mv -f tmp file_def_orchidee.xml
         sed -e 's@output_freq="_AUTO_"@output_freq="1d"@' file_def_orchidee.xml > tmp ; \mv -f tmp file_def_orchidee.xml
         sed -e 's@compression_level="4"@compression_level="0"@' file_def_orchidee.xml > tmp ; \mv -f tmp file_def_orchidee.xml
         sed -e 's@XIOS_ORCHIDEE_OK = n@XIOS_ORCHIDEE_OK = y@' orchidee.def > tmp ; \mv -f tmp orchidee.def
       fi
   fi
   echo 'Le bench n est pas execute. A executer a part si besoin '
   #echo EXECUTION DU BENCH (Mohammad)
   #set +e
   #set -e
   #tail listing


   echo '##########################################################'
   echo 'Simulation finished in' `pwd`
      echo 'You have compiled with:'
      cat ../compile.sh
   if [ $parallel = "none" ] ; then
     echo 'You may re-run it with : cd ' `pwd` ' ; gcm.e'
     echo 'or ./bench.sh'
   else
     echo 'You may re-run it with : '
     echo 'cd ' `pwd` '; ./bench.sh'
   #  echo 'ulimit -s unlimited'
   #  echo 'export OMP_NUM_THREADS=2'
   #  echo 'export OMP_STACKSIZE=800M'
   #  echo "$mpirun -np 2 gcm.e "
   fi
   echo '##########################################################'

fi # bench


