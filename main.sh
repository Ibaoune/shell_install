#!/bin/bash

#--------------------------------------------------
#Thsi script compile and istall LMDZ part by part.

# Author : M. EL AABARIBAOUNE (@um6p)

#---------------------------------------------------
echo '>>>> 0. Header'
source P0_header.sh

rep=`pwd`/parts

echo install_lmdz.sh DEBUT `date`
set -e

echo '>>>> 1. define function to get files'
source $rep/P1_fetch_files.sh

echo '>>>> 2. Some default parametrs : netcdf, xios/ioipsl, veget, resolution, parallel, rad...'
source $rep/P2_default_param.sh

echo '>>>> 3. Interactives options' 
source $rep/P3_interact_opt.sh

echo '>>>> 4. Other options : suff_orch, cosp, Model, arch,...' 
source $rep/P4_other_opt.sh

echo '>>>> 5. machine specifities : name, arch, environement,...'
source $rep/P5_machines.sh
echo ${hostname:0:5}
module list

echo '>>>> 6. some tests : MPI flags, OMP flags, ...' 
source $rep/P6_prelimTest_flags.sh

echo '>>>> 7. Define compilation flags'  
source $rep/P7_compilFlags.sh

echo '>>>> 8. Check if required software is available : bash/ksh, tar, gzip, make, ...' 
source $rep/P8_check_softwares.sh

echo '>>>> 9. Download a slightly modified version of  LMDZ' 
chmod u=rwx  $rep/P9_download.sh
source $rep/P9_download.sh

echo '>>>> 10. Compile NetCDF'  
source $rep/P10_compileNetCDF.sh

echo '>>>> 11. Compile IOIPSL' 
source $rep/P11_compileIOIPSL.sh

echo '>>>> 12. Compile XIOS'
source $rep/P12_compileXIOS.sh

echo '>>>> 13. Compile ORCH'
source $rep/P13_compileORCH.sh

echo '>>>> 14. Compile LMDZ'
source $rep/P14_compileLMDZ.sh

echo '>>>> 15. Check compile'
source $rep/P15_checkCompil.sh

echo '>>>> 16. Create and run Bench'
source $rep/P16_CreateRunBench.sh
