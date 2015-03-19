#!/bin/bash

HELPFLAG=0           # show the help block (if non-zero)
CHECKOUT="HEPFORGE"  # Alternate option is "GITHUB"
TAG="R-2_8_6"        # SVN Branch

USERREPO="GENIEMC"     # where do we get the code from GitHub?
GENIEVER="GENIE_2_8_6" # 
GITBRANCH="master"     # 
HTTPSCHECKOUT=0        # use https checkout if non-zero (otherwise ssh)

PYTHIAVER=6          # must eventually be either 6 or 8
ROOTTAG="v5-34-24"   # 
MAKE=gmake           # May prefer "make" on Ubuntu
MAKENICE=0           # Run make under nice if == 1
FORCEBUILD=""        # " -f" will archive existing packages and rebuild

SUPPORTTAG="R-2_8_6.3"

ENVFILE="environment_setup.sh"

# how to use the script
help()
{
    mybr
    echo "Check the [releases](https://github.com/GENIEMC/lamp/releases) page to be sure"
    echo "you are using a version of lamp that is appropriate for the version of GENIE"
    echo "you want to use. lamp has been tested for GENIE R-2_8_0 and later. It may"
    echo "not work with earlier versions."
    echo ""
    echo "Welcome to rub_the_lamp. This script will build the 3rd party support"
    echo "packages for GENIE and then build GENIE itself."
    echo ""
    echo "Usage: ./rub_the_lamp.sh -<flag>"
    echo "             -h / --help   : Help"
    echo "             -g / --github : Check out GENIE code from GitHub"
    echo "             -f / --forge  : Check out GENIE code from HepForge"
    echo "                             (DEFAULT)"
    echo "             -r / --repo   : Specify the GitHub repo"
    echo "                             (default == GENIE_2_8_6)"
    echo "                             Available: GENIE_2_8, GENIE_2_8_6"
    echo "             -u / --user   : Specify the GitHub user"
    echo "                             (default == GENIEMC)"
    echo "             -t / --tag    : Specify the HepForge SVN tag"
    echo "                             (default == R-2_8_6)"
    echo "             -b / --branch : Specify the GitHub GENIE branch"
    echo "                             (default == master)"
    echo "             -p / --pythia : Pythia version (6 or 8)"
    echo "                             (default == 6)"
    echo "             -m / --make   : Use make instead of gmake"
    echo "                             (default == use gmake)"
    echo "             -n / --nice   : Run make under nice"
    echo "                             (default == normal make)"
    echo "             -o / --root   : ROOT tag version"
    echo "                             (default == v5-34-24)"
    echo "             -s / --https  : Use HTTPS checkout from GitHub"
    echo "                             (default is ssh)"
    echo "             -c / --force  : Archive existing packages and rebuild"
    echo "                             (default is to keep the existing area)"
    echo "             --support-tag : Tag for GENIE Support"
    echo "                             (default is $SUPPORTTAG)"
    echo ""
    echo "  All defaults:  "
    echo "    ./rub_the_lamp.sh"
    echo "  Produces: R-2_8_6 from HepForge, Pythia6, ROOT v5-34-24"
    echo ""
    echo "  Other examples:  "
    echo "    ./rub_the_lamp.sh --forge"
    echo "    ./rub_the_lamp.sh -f --tag trunk"
    echo "    ./rub_the_lamp.sh -g -u GENIEMC --root v5-34-24 -n"
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
            GENIEVER="$1"
            CHECKOUT="GITHUB"
            shift
            ;;
        -u|--user)
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
        -o|--root)
            ROOTTAG="$1"
            shift
            ;;
        -s|--https)
            HTTPSCHECKOUT=1
            ;;
        -c|--force)
            FORCEBUILD="-f"
            ;;
        --support-tag)
            SUPPORTTAG="$1"
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
# Calculate Major_Minor_Patch from Repository and Name/Tag combos
#
MAJOR=2
MINOR=8
PATCH=0
if [[ $CHECKOUT == "GITHUB" ]]; then
    MAJOR=`echo $GENIEVER | cut -c7-7`
    MINOR=`echo $GENIEVER | cut -c9-9`
    PATCH=`echo $GENIEVER | cut -c11-11`
    # GitHub repos are `GENIE_2_8` and `GENIE_2_8_6`, so we must add the patch 0
    if [[ $PATCH == "" ]]; then
        PATCH=0
    fi
elif [[ $CHECKOUT == "HEPFORGE" ]]; then
    MAJOR=`echo $TAG | cut -c3-3`
    MINOR=`echo $TAG | cut -c5-5`
    PATCH=`echo $TAG | cut -c7-7`
fi

# 
# Show the selected options.
#
mybr
echo " "
echo "Welcome to the GENIE build script."
echo " "
echo " OS Information: "
if [[ `which lsb_release` != "" ]]; then
    lsb_release -a
elif [[ -e "/etc/lsb-release" ]]; then
    cat /etc/lsb-release
elif [[ -e "/etc/issue.net" ]]; then
    cat /etc/issue.net
else
    echo " Missing information on Linux distribution..."
fi
uname -a
mybr
echo "Options set: "
echo "------------ "
echo " Checkout       = $CHECKOUT"
if [[ $CHECKOUT == "HEPFORGE" ]]; then
    echo " Tag            = $TAG"
elif [[ $CHECKOUT == "GITHUB" ]]; then
    echo " User           = $USERREPO"
    echo " HTTPS Checkout = $HTTPSCHECKOUT"
    echo " Branch         = $GITBRANCH"
else
    echo "Bad checkout option!"
    exit 1
fi
echo " Deduced ID     = $MAJOR $MINOR $PATCH"
echo " Support Tag    = $SUPPORTTAG"
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
    echo "Done with GENIE GitHub checkout."
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
    echo "Done with GENIE HepForge checkout."
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
if [[ $SUPPORTTAG == "head" || $SUPPORTTAG == "HEAD" ]]; then
    echo "Using HEAD of GENIE Support..."
else
    echo "Switching to tag $SUPPORTTAG (on branch named $SUPPORTTAG-br)..."
    git checkout -b ${SUPPORTTAG}-br $SUPPORTTAG
fi
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
# Set up the environment for the GENIE build.
#
source $ENVFILE
echo "Configuring GENIE environment in-shell."
echo "You will need to source $ENVFILE after the build finishes."

#
# For 2.8.2 and 2.8.4, we must point LHAPATH into an area in $GENIE
# For 2.8.6 and 2.9.X, we must copy a patched PDF file into the $LHAPATH
# TODO - check to see if this is also handled in GENIESupport
# 
if [[ $MAJOR == 2 ]]; then
    if [[ $MINOR == 8 ]]; then
        if [[ $PATCH -ge 2 && $PATCH -le 4 ]]; then
            perl -ni -e 'print if !/LHAPATH/' $ENVFILE  # remove just the LHAPATH line
            echo "export LHAPATH=`pwd`/$GENIEDIRNAME/data/evgen/pdfs" >> $ENVFILE
        elif [[ $PATCH == 6 ]]; then
            cp $GENIE/data/evgen/pdfs/GRV98lo_patched.LHgrid $LHAPATH
        fi
    elif [[ $MINOR == 9 ]]; then
        cp $GENIE/data/evgen/pdfs/GRV98lo_patched.LHgrid $LHAPATH
    fi
fi
#
# For trunk prior to 2.10-proto we must copy a patched PDF file into the $LHAPATH
# 
if [[ $CHECKOUT == "HEPFORGE" ]]; then
    if [[ $TAG == "trunk" ]]; then
        cp $GENIE/data/evgen/pdfs/GRV98lo_patched.LHgrid $LHAPATH
    fi
fi

#
# Configure and build GENIE
#
mypush $GENIEDIRNAME
echo "Configuring GENIE buid..."
CONFIGSCRIPT="do_configure.sh"
echo -e "\043\041/usr/bin/env bash" > $CONFIGSCRIPT
echo -e "echo \"Running configuration script generated by the Lamp...\"" >> $CONFIGSCRIPT
echo -e "./configure \\" >> $CONFIGSCRIPT
echo -e "  --enable-debug \\" >> $CONFIGSCRIPT
echo -e "  --enable-test \\" >> $CONFIGSCRIPT
echo -e "  --enable-numi \\" >> $CONFIGSCRIPT
echo -e "  --enable-t2k \\" >> $CONFIGSCRIPT
echo -e "  --enable-atmo \\" >> $CONFIGSCRIPT
echo -e "  --enable-rwght \\" >> $CONFIGSCRIPT
echo -e "  --enable-vle-extension \\" >> $CONFIGSCRIPT
echo -e "  --enable-validation-tools \\" >> $CONFIGSCRIPT
echo -e "  --enable-roomuhistos \\" >> $CONFIGSCRIPT
echo -e "  --with-optimiz-level=O0 \\" >> $CONFIGSCRIPT
echo -e "  --with-log4cpp-inc=$LOG4CPP_INC \\" >> $CONFIGSCRIPT
echo -e "  --with-log4cpp-lib=$LOG4CPP_LIB \\" >> $CONFIGSCRIPT
echo -e "  >& log.config" >> $CONFIGSCRIPT
echo -e " " >> $CONFIGSCRIPT
echo -e "# libxml is challenging for the auto-finder sometimes." >> $CONFIGSCRIPT
echo -e "#  --with-libxml2-inc=/usr/include/libxml2 \\" >> $CONFIGSCRIPT
echo -e "#  --with-libxml2-lib=/usr/lib64 \\" >> $CONFIGSCRIPT
chmod u+x $CONFIGSCRIPT
./$CONFIGSCRIPT
echo "Building GENIE..."
$MAKE >& log.make
if [ $? -eq 0 ]; then
    echo "Build successful!"
else 
    echo "Build failed! Please check the log file."
    exit 1
fi
mypop

#
# Get cross seciton data
#
echo "Downloading Cross Section Data..."
if [ ! -d data ]; then
    mkdir data
else
    echo "Data directory already exists..."
fi
mypush data
XSECSPLINEDIR=`pwd`
# TODO - Hmmm... these versions...
if [[ $MAJOR == 2 ]]; then
    if [[ $MINOR == 8 ]]; then
        if [[ $PATCH == 0 ]]; then
            XSECDATA="gxspl-vA-v2.8.0.xml.gz"          
            if [ ! -f $XSECDATA ]; then
                wget http://www.hepforge.org/archive/genie/data/2.8.0/$XSECDATA >& log.datafetch
            else
                echo "Cross section data $XSECDATA already exists in `pwd`..."
            fi
        elif [[ $PATCH -le 6 ]]; then
            XSECDATA="gxspl-NuMIsmall.xml.gz"          
            if [ ! -f $XSECDATA ]; then
                wget http://www.hepforge.org/archive/genie/data/2.8.4/$XSECDATA >& log.datafetch
            else
                echo "Cross section data $XSECDATA already exists in `pwd`..."
            fi
        fi
    elif [[ $MINOR == 9 ]]; then
        # Only one option for 2.9.X for now...
        XSECDATA="gxspl-NuMI-R290.xml.gz"          # R. Hatcher's splines        
        if [ ! -f $XSECDATA ]; then
            curl -O http://home.fnal.gov/~rhatcher/$XSECDATA >& log.datafetch
        else
            echo "Cross section data $XSECDATA already exists in `pwd`..."
        fi
    else
        echo "Don't know how to choose cross section splines for test run! Halting!"
        exit 1
    fi
else
    echo "Major version != 2... Don't know how to choose cross section splines for test run! Halting!"
    exit 1
fi
mypop
echo "export XSECSPLINEDIR=$XSECSPLINEDIR" >> $ENVFILE

#
# Do a short test run.
#
echo "Performing a 5 event test run..."
RUNSPKG="genie_runs"
if [ ! -d "RUNSPKG" ]; then
    echo "Checking out the genie_runs package from GitHub..."
    git clone ${GITCHECKOUT}GENIEMC/${RUNSPKG}.git
else
    echo "$RUNSPKG already installed..."
fi
echo "Moving to the genie_runs package area to do the test run..."
mypush $RUNSPKG 
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
    exit 1
fi
mypop

