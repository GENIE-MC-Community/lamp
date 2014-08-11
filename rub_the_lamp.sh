#!/bin/bash

MAKE=gmake           # Use `gmake`
MAKENICE=0           # make under nice?
HELPFLAG=0           # show the help block (if non-zero)
PYTHIAVER=-1         # must eventually be either 6 or 8
USERREPO="GENIEMC"   # where do we get the code from GitHub?
ROOTTAG="v5-34-18"   # 
FORCEBUILD=""        # " -f" will archive existing packages and rebuild
HTTPSCHECKOUT=0      # use https checkout if non-zero (otherwise ssh)
GENIEVER="GENIE_2_8" # TODO - Add a flag to choose different versions...
                     # Also TODO - Add an option to check out from HepForge
                     
ENVFILE="environment_setup.sh"

XSECDATAREL="2.8.0"
XSECDATA="gxspl-vA-v2.8.0.xml.gz"

# how to use the script
help()
{
  mybr
  echo "Usage: ./rub_the_lamp.sh -<flag>"
  echo "                       -p  #   : Build Pythia 6 or 8 and link ROOT to it (required)."
  echo "                       -u name : The repository name. Default is the GENIEMC"
  echo "                       -r tag  : Which ROOT version (default = v5-34-08)."
  echo "                       -n      : Run configure, build, etc. under nice."
  echo "                       -s      : Use https to checkout code from GitHub (default is ssh)."
  echo "                       -m      : Use \"make\" instead of \"gmake\" to build."
  echo "                       -f      : Archive current support libraries rebuild them fresh."
  echo " "
  echo "Note: Currently the user repository choice affects GENIE only - the support packages"
  echo "are always checked out from the GENIEMC organization respoistory."
  echo " "
  echo "  Examples:  "
  echo "    ./rub_the_lamp.sh -p 6 -u GENIEMC                  # (GENIEMC is the default)"
  echo "    ./rub_the_lamp.sh -p 6 -u <your GitHub user name> " 
  echo "    ./rub_the_lamp.sh -p 8 -r v5-34-12"
  echo " "
  echo "Note: Advanced configuration of the support packages require inspection of that script."
  mybr
  echo " "
}

# quiet pushd
mypush() 
{ 
  pushd $1 >& /dev/null 
  if [ $? -ne 0 ]; then
    echo "Error! Directory $1 does not exist."
    exit 0
  fi
}

# quiet popd
mypop() 
{ 
  popd >& /dev/null 
}

# uniformly printed "subject" breaks
mybr()
{
  echo "----------------------------------------"
}

# bail on illegal versions of Pythia
badpythia()
{
  echo "Illegal version of Pythia! Only 6 or 8 are accepted."
  exit 0
}
#


while getopts "p:u:r:mnsf" options; do
  case $options in
    p) PYTHIAVER=$OPTARG;;
    u) USERREPO=$OPTARG;;
    r) ROOTTAG=$OPTARG;;
    m) MAKE=make;;
    n) MAKENICE=1;;
    s) HTTPSCHECKOUT=1;; 
    f) FORCEBUILD=" -f";;
  esac
done

if [ $PYTHIAVER -eq -1 ]; then
  HELPFLAG=1
fi
if [ $HELPFLAG -ne 0 ]; then
  help
  exit 0
fi
mybr
echo "Letting GENIE out of the bottle..."
echo "Selected Pythia Version is $PYTHIAVER..."
if [ $PYTHIAVER -ne 6 -a $PYTHIAVER -ne 8 ]; then
  badpythia
fi
echo "Selected ROOT tag is $ROOTTAG..."

GITCHECKOUT="http://github.com/"
if [ $HTTPSCHECKOUT -ne 0 ]; then 
  GITCHECKOUT="https://github.com/"
else
  GITCHECKOUT="git@github.com:"
fi

if [ ! -d GENIESupport ]; then
  git clone ${GITCHECKOUT}GENIEMC/GENIESupport.git
else
  echo "GENIESupport already installed..."
fi
if [ ! -d $GENIEVER ]; then
  git clone ${GITCHECKOUT}${USERREPO}/${GENIEVER}.git
else
  echo "${GENIEVER} already installed..."
fi

if [ $MAKENICE -eq 1 ]; then
  NICE="-n"
fi
MAKEFLAG=""
if [ $MAKE == "make" ]; then
  MAKEFLAG="-m"
fi

IS64="no"
# Is this 64 bit?
if echo `uname -a` | grep "x86_64"; then
  IS64="yes"
fi

# TODO - pass other flags nicely
mypush GENIESupport
echo "Running: ./build_support.sh -p $PYTHIAVER -r $ROOTTAG $NICE $MAKEFLAG $FORCEBUILD"
./build_support.sh -p $PYTHIAVER -r $ROOTTAG $NICE $MAKEFLAG $FORCEBUILD
mv $ENVFILE ..
mypop

echo "export GENIE=`pwd`/${GENIEVER}" >> $ENVFILE
echo "export PATH=`pwd`/${GENIEVER}/bin:\$PATH" >> $ENVFILE
echo "export LD_LIBRARY_PATH=`pwd`/${GENIEVER}/lib:\$LD_LIBRARY_PATH" >> $ENVFILE
if [ "$IS64" == "yes" ]; then
  if [ -d /usr/lib64 ]; then
    echo "export LD_LIBRARY_PATH=/usr/lib64:\$LD_LIBRARY_PATH" >> $ENVFILE
  else
    echo "Can't find lib64 - please update your setup script by hand."
  fi
fi

source $ENVFILE
echo "Configuring GENIE environment in-shell. You will need to source $ENVFILE after the build finishes."

mypush $GENIEVER
echo "Configuring GENIE buid..."
./configure --enable-debug --enable-test --enable-numi --enable-t2k --enable-atmo --enable-rwgt --enable-vle-extension --enable-validation-tools --with-optimiz-level=O0 --with-log4cpp-inc=$LOG4CPP_INC --with-log4cpp-lib=$LOG4CPP_LIB >& log.config
echo "Building GENIE..."
$MAKE >& log.make
if [ $? -eq 0 ]; then
  echo "Build successful!"
else 
  echo "Build failed! Please check the log file."
fi
mypop

echo "Downloading Cross Section Data..."
if [ ! -d data ]; then
  mkdir data
else
  echo "Data directory already exists..."
fi
mypush data
XSECSPLINEDIR=`pwd`
if [ ! -f $XSECDATA ]; then
  wget http://www.hepforge.org/archive/genie/data/$XSECDATAREL/$XSECDATA >& log.datafetch
else
  echo "Cross section data already exists in `pwd`..."
fi
mypop
echo "export XSECSPLINEDIR=$XSECSPLINEDIR" >> $ENVFILE

echo "Performing a 5 event test run..."
gevgen -n 5 -p 14 -t 1000080160 -e 0,10 -r 42 -f 'x*exp(-x)' --seed 2989819 --cross-sections $XSECSPLINEDIR/$XSECDATA >& run_log.txt
if [ $? -eq 0 ]; then
  echo "Run successful!"
  echo "***********************************************************"
  echo "  NOTE: To run GENIE you MIUST first source $ENVFILE "
  echo "***********************************************************"
  mypush $XSECSPLINEDIR
  gunzip $XSECDATA
  echo " Note, unzipping $XSECDATA..."
  mypop
else 
  echo "Run failed! Please check the log file."
fi

