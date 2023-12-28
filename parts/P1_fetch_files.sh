
# A function to fetch files either locally or on the internet
function myget { #1st and only argument should be file name
  # Path on local computer where to look for the datafile
  if [ -f /u/lmdz/WWW/LMDZ/pub/$1 ] ; then
    \cp -f -p /u/lmdz/WWW/LMDZ/pub/$1 .
  elif [ -f ~/LMDZ/pub/$1 ] ; then
    \cp -f -p ~/LMDZ/pub/$1 .
  else
    wget --no-check-certificate -nv http://www.lmd.jussieu.fr/~lmdz/pub/$1
    save_pub_locally=0
    if [ $save_pub_locally = 1 ] ; then # saving wget files on ~/LMDZ/pub
       dir=~/LMDZ/pub/`dirname $1` ; mkdir -p $dir ; cp -r `basename $1` $dir
    fi
  fi
}
