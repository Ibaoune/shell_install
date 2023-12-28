###########################################################################
# Author : M. EL AABARIBAOUNE
# Usage  : install_Med_lmdz.sh -help
#
# bash installation script of the LMDZ model on the UM6P Supercomputer (Toubkal)
#
# The model is downloaded in the following directory tree
# $MODEL/modipsl/modeles/...
# using the "modipsl" infrastructure created by the "IPSL"
# for coupled (atmosphere/ocean/vegetation/chemistry) climate modeling
# activities.
# Here we only download atmospheric (LMDZ) and vegetation (ORCHIDEE)
# components.
#
# The sources of the models can be found in the "modeles" directory.
# In the present case, LMDZ, ORCHIDEE, and IOIPSL or XIOS (handling of input-outputs
# using the NetCDF library). 
#
# The script downloads various source files (including a version of NetCDF)
# and utilities, compiles the model, and runs a test simulation in a
# minimal configuration.
#
# Prerequisites : pgf90/gfortran, bash or ksh, wget , gunzip, tar, ... 
#
#    changes for option real 8.
#      We compile with -r8 (or equivalent) and -DNC_DOUBLE for the GCM
#      but with -r4 for netcdf. Variable real must be set to 
#      r4 or r8 at the beginning of the script below.
