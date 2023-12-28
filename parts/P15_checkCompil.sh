##################################################################
# Verification du succes de la compilation
##################################################################

# Recherche de l'executable dont le nom a change au fil du temps ...
gcm=""
#for exe in gcm.e bin/gcm_${grid_resolution}_phylmd_seq_orch.e bin/gcm_${grid_resolution}_phylmd_seq.e bin/gcm_${grid_resolution}_phylmd_para_mem_orch.e bin/gcm_${grid_resolution}_phylmd_para_mem.e  ; do
for exe in gcm.e bin/gcm_${grid_resolution}_phylmd${suff_exe}${suff_orc}.e ; do   if [ -f $exe ] ; then gcm=$exe ; fi
done

if [ "$gcm" = "" ] ; then
  if [ $bench = 1 ] ; then
    echo 'Compilation failed !! Cannot run the benchmark;'
    exit
  else
    echo 'Compilation not done (only done when bench=1)'
  fi
else
   echo '##########################################################'
   echo 'Compilation successfull !! ' `date`
   echo '##########################################################'
   echo The executable is $gcm
fi

