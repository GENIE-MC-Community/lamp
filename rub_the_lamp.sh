#!/bin/bash

HELPFLAG=0           # show the help block (if non-zero)
CHECKOUT="HEPFORGE"  # Alternate option is "GITHUB"
TAG="R-2_8_4"        # SVN Branch

USERREPO="GENIEMC"   # where do we get the code from GitHub?
GENIEVER="GENIE_2_8" # TODO - Add a flag to choose different "versions"
GITBRANCH="master"   # 
HTTPSCHECKOUT=0      # use https checkout if non-zero (otherwise ssh)

PYTHIAVER=6          # must eventually be either 6 or 8
ROOTTAG="v5-34-18"   # 
MAKE=gmake           # May prefer "make" on Ubuntu
MAKENICE=0           # Run make under nice if == 1
FORCEBUILD=""        # " -f" will archive existing packages and rebuild


                     
ENVFILE="environment_setup.sh"

# TODO - Hmmm... these versions...
XSECDATAREL="2.8.0"
XSECDATA="gxspl-vA-v2.8.0.xml.gz"

# how to use the script
help()
{
  mybr
  echo "Welcome to rub_the_lamp. This script will build the 3rd party support"
  echo "packages for GENIE and then build GENIE itself."
  echo ""
  echo "Usage: ./rub_the_lamp.sh -<flag>"
  echo "             -h / --help   : Help"
  echo "             -g / --github : Check out GENIE code from GitHub"
  echo "             -f / --forge  : Check out GENIE code from HepForge"
  echo "                             (DEFAULT)"
  echo "             -r / --repo   : Specify the GitHub repo"
  echo "                             (default == GENIEMC)"
  echo "             -t / --tag    : Specify the HepForge SVN tag"
  echo "                             (default == R-2_8_4)"
  echo "             -b / --branch : Specify the GitHub GENIE branch"
  echo "                             (default == master)"
  echo "             -p / --pythia : Pythia version (6 or 8)"
  echo "                             (default == 6)"
  echo "             -m / --make   : Use make instead of gmake"
  echo "                             (default == use gmake)"
  echo "             -n / --nice   : Run make under nice"
  echo "                             (default == normal make)"
  echo "             -o / --root   : ROOT tag version"
  echo "                             (default == v5-34-18)"
  echo "             -s / --https  : Use HTTPS checkout from GitHub"
  echo "                             (default is ssh)"
  echo "             -c / --force  : Archive existing packages and rebuild"
  echo "                             (default is to keep the existing area)"
  echo ""
  echo "  All defaults:  "
  echo "    ./rub_the_lamp.sh"
  echo "  Produces: R-2_8_4 from HepForge, Pythia6, ROOT v5-34-18"
  echo ""
  echo "  Other examples:  "
  echo "    ./rub_the_lamp.sh --forge"
  echo "    ./rub_the_lamp.sh -f --tag trunk"
  echo "    ./rub_the_lamp.sh -g -r GENIEMC --root v5-34-18 -n"
  echo " "
  echo "Note: Advanced configuration of the support packages require inspection of that script."
  mybr
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

#
# START!
#
echo ""
echo "Letting GENIE out of the bottle..."
#
# Parse the command line flags.
#
while [[ $# > 0 ]]
do
  key="$1"
  shift

  case $key in
    -h|--help)
    HELPFLAG=1
    ;;
    -g|--github)
    CHECKOUT="GITHUB"
    ;;
    -f|--forge)
    CHECKOUT="HEPFORGE"
    ;;
    -r|--repo)
    USERREPO="$1"
    CHECKOUT="GITHUB"
    shift
    ;;
    -t|--tag)
    TAG="$1"
    CHECKOUT="HEPFORGE"
    shift
    ;;
    -b|--branch)
    GITBRANCH="$1"
    CHECKOUT="GITHUB"
    shift
    ;;
    -p|--pythia)
    PYTHIAVER="$1"
    shift
    ;;
    -m|--make)
    MAKE=make
    ;;
    -n|--nice)
    MAKENICE=1
    ;;
    -o|root)
    ROOTTAG="$1"
    shift
    ;;
    -s|--https)
    HTTPSCHECKOUT=1
    ;;
    -c|--force)
    FORCEBUILD="-f"
    ;;
    *)    # Unknown option

    ;;
  esac
done

#
# Check help and do sanity checks on options.
#
if [[ $HELPFLAG -eq 1 ]]; then
  help
  exit 0
fi
if [ $PYTHIAVER -ne 6 -a $PYTHIAVER -ne 8 ]; then
  badpythia
fi

# 
# Show the selected options.
#
mybr
echo "Options set: "
echo "------------ "
echo " Checkout       = $CHECKOUT"
if [[ $CHECKOUT == "HEPFORGE" ]]; then
  echo " Tag            = $TAG"
elif [[ $CHECKOUT == "GITHUB" ]]; then
  echo " Repo           = $USERREPO"
  echo " HTTPS Checkout = $HTTPSCHECKOUT"
  echo " Branch         = $GITBRANCH"
else
  echo "Bad checkout option!"
  exit 1
fi
echo " Pythia version = $PYTHIAVER"
echo " Make           = $MAKE"
echo " Make Nice      = $MAKENICE"
echo " ROOT tag       = $ROOTTAG"
if [[ $FORCEBUILD == "" ]]; then
  echo " Force build    = NO"
else
  echo " Force build    = YES"
fi

# 
# Pause here to verify selection?
# 
echo ""
echo "Press ctrl-c to stop. Otherwise starting the build in..."
for i in {5..1}
do
  echo "$i"
  sleep 1
done

#
# Set basic GitHub checkout info. Even if we are getting GENIE from HepForge,
# we still get the support package build script from GitHub.
#
GITCHECKOUT="http://github.com/"
if [ $HTTPSCHECKOUT -ne 0 ]; then 
  GITCHECKOUT="https://github.com/"
else
  GITCHECKOUT="git@github.com:"
fi

#
# Check out the GENIE code.
# 
GENIEDIRNAME=""
# GitHub version is _only_ 2.8.0 right now. If this changes, add logic to 
# pick out the version number correctly...
MAJOR=2
MINOR=8
PATCH=0
if [[ $CHECKOUT == "GITHUB" ]]; then
  GENIEDIRNAME=$GENIEVER
  if [ ! -d $GENIEDIRNAME ]; then
    git clone ${GITCHECKOUT}${USERREPO}/${GENIEVER}.git
    mypush $GENIEVER  
    git checkout $GITBRANCH
    mypop
  else
    echo "$GENIEDIRNAME already installed..."
  fi
elif [[ $CHECKOUT == "HEPFORGE" ]]; then
  GENIEDIRNAME=$TAG
  echo "Checking out $TAG..."
  if [ ! -d $GENIEDIRNAME ]; then
    if [[ $TAG != "trunk" ]]; then
      svn co --quiet http://genie.hepforge.org/svn/branches/$TAG $GENIEDIRNAME 
    else
      svn co --quiet http://genie.hepforge.org/svn/trunk $GENIEDIRNAME 
    fi
  else
    echo "$GENIEDIRNAME already installed..."
  fi
  echo "Done with HepForge checkout."
  MAJOR=`echo $TAG | cut -c3-3`
  MINOR=`echo $TAG | cut -c5-5`
  PATCH=`echo $TAG | cut -c7-7`
fi

#
# Build the support packages.
#
if [ ! -d GENIESupport ]; then
  git clone ${GITCHECKOUT}GENIEMC/GENIESupport.git
else
  echo "GENIESupport already installed..."
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

HTTPSFLAG=""
if [ $HTTPSCHECKOUT -ne 0 ]; then 
  HTTPSFLAG="-s"
fi

# TODO - pass other flags nicely
mypush GENIESupport
echo "Running: ./build_support.sh -p $PYTHIAVER -r $ROOTTAG $NICE $MAKEFLAG $FORCEBUILD $HTTPSFLAG"
./build_support.sh -p $PYTHIAVER -r $ROOTTAG $NICE $MAKEFLAG $FORCEBUILD $HTTPSFLAG
mv $ENVFILE ..
mypop

echo "export GENIE=`pwd`/${GENIEDIRNAME}" >> $ENVFILE
echo "export PATH=`pwd`/${GENIEDIRNAME}/bin:\$PATH" >> $ENVFILE
echo "export LD_LIBRARY_PATH=`pwd`/${GENIEDIRNAME}/lib:\$LD_LIBRARY_PATH" >> $ENVFILE
if [ "$IS64" == "yes" ]; then
  if [ -d /usr/lib64 ]; then
    echo "export LD_LIBRARY_PATH=/usr/lib64:\$LD_LIBRARY_PATH" >> $ENVFILE
  else
    echo "Can't find lib64 - please update your setup script by hand."
  fi
fi

#
# For the 2.8.X patch series, we must point LHAPATH into an area in $GENIE
# 
if [[ $MAJOR == 2 ]]; then
  if [[ $MINOR == 8 ]]; then
    if [[ $PATCH > 0 ]]; then
      perl -ni -e 'print if !/LHAPATH/' $ENVFILE  # remove just the LHAPATH line
      echo "export LHAPATH=`pwd`/$GENIEDIRNAME/data/evgen/pdfs" >> $ENVFILE
    fi
  fi
fi

source $ENVFILE
echo "Configuring GENIE environment in-shell."
echo "You will need to source $ENVFILE after the build finishes."

mypush $GENIEDIRNAME
echo "Configuring GENIE buid..."
./configure --enable-debug \
  --enable-test \
  --enable-numi \
  --enable-t2k \
  --enable-atmo \
  --enable-rwght \
  --enable-vle-extension \
  --enable-validation-tools \
  --with-optimiz-level=O0 \
  --with-log4cpp-inc=$LOG4CPP_INC \
  --with-log4cpp-lib=$LOG4CPP_LIB \
  >& log.config
echo "Building GENIE..."
$MAKE >& log.make
if [ $? -eq 0 ]; then
  echo "Build successful!"
else 
  echo "Build failed! Please check the log file."
fi
mypop

echo "Downloading Cross Section Data..."
echo "  WARNING - only able to fetch 2.8.0 right now!"
echo "  This may not be what you want to use!"
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
gevgen -n 5 -p 14 -t 1000080160 -e 0,10 -r 42 -f 'x*exp(-x)' \
  --seed 2989819 --cross-sections $XSECSPLINEDIR/$XSECDATA >& run_log.txt
if [ $? -eq 0 ]; then
  echo "Run successful!"
  echo "***********************************************************"
  echo "  NOTE: To run GENIE you MIUST first source $ENVFILE "
  echo "***********************************************************"
  mypush $XSECSPLINEDIR
  gunzip -f $XSECDATA
  echo " Note, unzipping $XSECDATA..."
  mypop
else 
  echo "Run failed! Please check the log file."
fi

