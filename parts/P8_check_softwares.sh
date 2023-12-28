echo '################################################################'
if [ "$check_linux" = 1 ] ; then
echo   Check if required software is available
echo '################################################################'

#### Ehouarn: test if the required shell is available
#### Maj FH-LF-AS 2021-04 : default=bash ; if bash missing, use ksh 
use_shell="bash" # default
if [ "`which bash`" = "" ] ; then
  echo "no bash ; we will use ksh"
  use_shell="ksh"
  if [ "`which ksh`" = "" ] ; then
    echo "bash (or ksh) needed!! Install it!"
    exit
  fi
fi

for logiciel in wget tar gzip make $compiler gcc ; do
if [ "`which $logiciel`" = "" ] ; then
echo You must first install $logiciel on your system
exit
fi
done

if [ $pclinux = 1 ] ; then
cd $MODEL
cat <<eod > tt.f90
print*,'coucou'
end
eod
$compiler tt.f90 -o a.out
./a.out >| tt
if [ "`cat tt | sed -e 's/ //g' `" != "coucou" ] ; then
echo problem installing with compiler $compiler ; exit ; fi
\rm tt a.out tt.f90
fi
fi
