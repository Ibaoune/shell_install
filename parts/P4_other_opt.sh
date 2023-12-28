

# Option de compilation du rayonnement
opt_rad=""
case $rad in
   rrtm) opt_rad="-rad rrtm" ;;
   ecrad) opt_rad="-rad ecrad" ;;
esac


# Option de compilation pour Cosp
opt_cosp=""
case cosp in
   v1) opt_cosp="-cosp true" ;;
   v2) opt_cosp="-cospv2 true" ;;
esac

# Check on veget version
#if [ "$veget" != 'NONE'  -a "$veget" != "CMIP6" -a "$veget" != +([0-9]) ] ; then
if [ $veget != 'NONE'   -a $veget != "CMIP6" ] ; then
    re='^[0-9]+$'
    if ! [[ $veget =~ $re ]] ; then
        echo 'Valeur de l option veget non valable'
        exit
    fi
fi

#Define veget-related suffix for gcm name
if [ "$veget" = 'NONE' ] ; then
    suff_orc=''
    #For use with tutorial, orchidee_rev is also defined (will be written in surface_env at the end of the script)
    orchidee_rev=''
else
    suff_orc='_orch'
fi


if [ $parallel = none ] ; then sequential=1; suff_exe='_seq' ; else sequential=0; suff_exe='_para_mem' ; fi

#Chemin pour placer le modele
if [ "$MODEL" = "" ] ; then MODEL=./LMDZ$version$svn$optim ; fi


arch=local


