#!/bin/bash

HELPFLAG=0           # show the help block (if non-zero)
CHECKOUT="HEPFORGE"  # Alternate option is "GITHUB"
TAG="R-2_12_8"       # SVN Branch
SVNAUTHNAM="anon"    # credentialed checkout?
# major, minor, version (extract from tag dynamically)
MAJOR=`echo $TAG | perl -ne '@l=split("-",$_);@m=split("_",@l[1]);print @m[0]'`
MINOR=`echo $TAG | perl -ne '@l=split("-",$_);@m=split("_",@l[1]);print @m[1]'`
PATCH=`echo $TAG | perl -ne '@l=split("-",$_);@m=split("_",@l[1]);print @m[2]'`

USERREPO="GENIEMC"      # "USER REPO" == just User, really
GENIEVER="GENIE"        # "VER" == repo name (really)
GITBRANCH="R-2_12_8"    # 
HTTPSCHECKOUT=0         # use https checkout if non-zero (otherwise ssh)

PYTHIAVER=6          # must eventually be either 6 or 8
ROOTTAG="v5-34-36"   # 
MAKE=make            # May prefer "gmake" on some systems
MAKENICE=0           # Run make under nice if == 1
FORCEBUILD=""        # " -f" will archive existing packages and rebuild

DEBUG="no"

ROOMUHISTOSFLAG=""   # silence is assent
SUPPORTTAG="R-2_12_8.0"
VERBOSESUPPORT=""    # silence is NOT assent

ENVFILE="environment_setup.sh"

# how to use the script
help()
{
    cat <<EOF

Check the [releases](https://github.com/GENIEMC/lamp/releases) page to be sure
you are using a version of "lamp" that is appropriate for the version of GENIE
you want to use. This version of "lamp" expects you want to work with GENIE 
$TAG. "lamp" has been tested for GENIE R-2_8_0 and later, but you need to be
sure you check out the appropriate release for the version of GENIE that you 
would like to use. Check the "VERSIONS.md" file distributed with lamp for help.

Welcome to "rub_the_lamp". This script will build the 3rd party support packages
for GENIE and then build GENIE itself.

Usage: ./rub_the_lamp.sh -<flag>
             -h / --help   : Help
             -g / --github : Check out GENIE code from GitHub
             -f / --forge  : Check out GENIE code from HepForge
                             (DEFAULT)
             -u / --user   : Specify the GitHub user
                             (default == GENIEMC)
             -t / --tag    : Specify the HepForge SVN tag
                             (default == $TAG)
                             Available: use ./list_hepforge_branches.sh
             -b / --branch : Specify the GitHub GENIE branch
                             (default == $GITBRANCH)
             -p / --pythia : Pythia version (6 or 8)
                             (default == 6)
                             8 is under construction! Not available yet.
             -n / --nice   : Run make under nice
                             (default == normal make)
             -o / --root   : ROOT tag version
                             (default == $ROOTTAG)
             -s / --https  : Use HTTPS checkout from GitHub
                             (default is ssh)
             -c / --force  : Archive existing packages and rebuild
                             (default is to keep the existing area)
             -v / --verbose : Install Support packages with verbose mode
                              turned on.
             -d / --debug  : Build GENIE with debugging symbols. (Also impacts
                             support libraries.)
             --svnauthname : HepForge user name (SSH credentialed checkout)
                             (default is anonymous checkout)
             --support-tag : Tag for GENIE Support
                             (default is $SUPPORTTAG)
             --no-roomu    : build without RooMUHistos (requires Boost)
                             (default is to use RooMUHistos)

  All defaults:  
    ./rub_the_lamp.sh
  Produces: $TAG from HepForge, Pythia6, ROOT $ROOTTAG

  Other examples:  
    ./rub_the_lamp.sh --forge
    ./rub_the_lamp.sh -f --tag trunk
    ./rub_the_lamp.sh -g -u GENIEMC --root v5-34-24 -n
 
Note: Advanced configuration of the support packages may require inspection of
that script.
 
EOF
}

# comments on the version
version_info()
{
    cat <<EOF
Note that the "HEAD" version on the lamp package is designed to work with
GENIE 2.10.2 and later. If you want to use an older version of GENIE, you
should check out an appropriate tag. You can do this with a branch checkout
command that will switch to the version of the code matching the tag and also
put you on a separate branch (away from master) in case you want to make
commits, etc. See the VERSIONS.md file in this package for more information.

* The latest version is 2.12.8. To use 2.12.8, you want tag "R-2_12_8.0":

    git checkout -b R-2_12_8.0-br R-2_12_8.0

* To use 2.10.0, you probably want tag "R-2_10_0.0":

    git checkout -b R-2_10_0.0-br R-2_10_0.0

* To use 2.8.6, you probably want tag "R-2_8_6.5":

    git checkout -b R-2_8_6.5-br R-2_8_6.5

* If you have created a repo with a different name or naming structure from
those expected by lamp, you will need to update this script or rename your
repository. This script expects repositories in HepForge to look like 
R-X_Y_Z and in GitHub to look like GENIE, with the version set by the 
**branch name**. You may grep this script for the checklamp function to see
how the major, minor, and patch version numbers are managed.
EOF
}

# quiet pushd
mypush() 
{ 
    pushd $1 >& /dev/null 
    if [ $? -ne 0 ]; then
        echo "Error! Directory $1 does not exist."
        exit 1
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
    exit 1
}
#

# is lamp okay for this version of GENIE?
checklamp()
{
    if [[ $MAJOR != "trunk" && $MAJOR != "master" ]]; then
        if [[ $MAJOR == 2 ]]; then
            if [[ $MINOR -eq 10 ]]; then
                if [[ $PATCH -ge 2 ]]; then
                    LAMPOKAY="YES"
                else
                    badlamp
                fi
            elif [[ $MINOR -ge 11 ]]; then
                LAMPOKAY="YES"
            else
                badlamp
            fi
        else
            badlamp
        fi
    fi
}

# this version of lamp is not approproate for "this" GENIE
badlamp()
{
    echo "GENIE $MAJOR $MINOR $PATCH is not supported by this version of lamp."
    echo ""
    version_info
    echo ""
    echo "Please check the lamp project page for an additional information."
    echo ""
    echo "           https://github.com/GENIEMC/lamp                       "
    echo "           https://github.com/GENIEMC/lamp/releases              "
    echo ""
    exit 1
}


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
        -v|--verbose)
            VERBOSESUPPORT="-v"
            ;;
        -d|--debug)
            DEBUG="yes"
            ;;
        --svnauthname)
            SVNAUTHNAM="$1"
            shift
            ;;
        --support-tag)
            SUPPORTTAG="$1"
            shift
            ;;
        --no-roomu)
            ROOMUHISTOSFLAG="--no-roomu"
            ;;
        *)    # Unknown option
            echo "Unknown option!"
            help
            exit 0
            ;;
    esac
done

#
# Check the help flag
#
if [[ $HELPFLAG -eq 1 ]]; then
    help
    exit 0
fi

#
# START!
#
BUILDSTARTTIME=`date +%Y-%m-%d-%H-%M-%S`
echo ""
echo "Letting GENIE out of the bottle..."
echo "  Starting the build at $BUILDSTARTTIME"

#
# Calculate Major_Minor_Patch from Repository and Name/Tag combos
#  GitHub: R-2_10_2+: GENIE, with Major_Minor_Patch in **branch name**
#  GitHub: R-2_8 -> R-2_10_0: GENIE_X_Y_Z except 2_8, which is before our support window anyway. 
#      Check out an older tag of lamp for pre R-2_10_2
#  HepForge: R-X_Y_Z
#
if [[ $CHECKOUT == "GITHUB" ]]; then
    if [[ $GITBRANCH != "master" ]]; then
        MAJOR=`echo $GITBRANCH | perl -ne '@l=split("-",$_);@m=split("_",@l[1]);print @m[0]'`
        MINOR=`echo $GITBRANCH | perl -ne '@l=split("-",$_);@m=split("_",@l[1]);print @m[1]'`
        PATCH=`echo $GITBRANCH | perl -ne '@l=split("-",$_);@m=split("_",@l[1]);print @m[2]'`
    else
        MAJOR="master"
        MINOR=""
        PATCH=""
    fi
elif [[ $CHECKOUT == "HEPFORGE" ]]; then
    if [[ $TAG != "trunk" ]]; then
        MAJOR=`echo $TAG | perl -ne '@l=split("-",$_);@m=split("_",@l[1]);print @m[0]'`
        MINOR=`echo $TAG | perl -ne '@l=split("-",$_);@m=split("_",@l[1]);print @m[1]'`
        PATCH=`echo $TAG | perl -ne '@l=split("-",$_);@m=split("_",@l[1]);print @m[2]'`
    else
        MAJOR="trunk"
        MINOR=""
        PATCH=""
    fi
fi
checklamp

#
# Check that the Pythia version requested is okay
# 
if [ $PYTHIAVER -ne 6 -a $PYTHIAVER -ne 8 ]; then
    badpythia
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
    echo " Do not know how to find information on Linux distribution..."
fi
uname -a
mybr
echo "Options set: "
echo "------------ "
echo " Checkout       = $CHECKOUT"
if [[ $CHECKOUT == "HEPFORGE" ]]; then
    echo " Tag            = $TAG"
    echo " SVN account    = $SVNAUTHNAM"
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
            if [[ $SVNAUTHNAM == "anon" ]]; then 
                svn co --quiet http://genie.hepforge.org/svn/generator/branches/$TAG $GENIEDIRNAME 
            else
                svn co --quiet svn+ssh://${SVNAUTHNAM}@svn.hepforge.org/hepforge/svn/genie/generator/branches/$TAG $GENIEDIRNAME
            fi
        else
            if [[ $SVNAUTHNAM == "anon" ]]; then 
                svn co --quiet http://genie.hepforge.org/svn/generator/trunk $GENIEDIRNAME 
            else
                svn co --quiet svn+ssh://${SVNAUTHNAM}@svn.hepforge.org/hepforge/svn/genie/generator/trunk $GENIEDIRNAME
            fi
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
DEBUGFLAG=""
if [ "$DEBUG" == "yes" ]; then
    DEBUGFLAG="--debug"
fi
echo "Running: ./build_support.sh -p $PYTHIAVER -r $ROOTTAG $NICE $FORCEBUILD $ROOMUHISTOSFLAG $VERBOSESUPPORT $HTTPSFLAG $DEBUGFLAG"
./build_support.sh -p $PYTHIAVER -r $ROOTTAG $NICE $FORCEBUILD $HTTPSFLAG $ROOMUHISTOSFLAG $VERBOSESUPPORT $DEBUGFLAG
if [[ $? == 0 ]]; then
    echo "Successfully built support packages."
else
    echo "Support package installation failed!"
    exit 1
fi
mv $ENVFILE ..
mypop

echo "export GENIE=`pwd`/${GENIEDIRNAME}" >> $ENVFILE
echo "export PATH=`pwd`/${GENIEDIRNAME}/bin:\$PATH" >> $ENVFILE
echo "export LD_LIBRARY_PATH=`pwd`/${GENIEDIRNAME}/lib:\$LD_LIBRARY_PATH" >> $ENVFILE
if [ "$IS64" == "yes" ]; then
    if [ -d /usr/lib64 ]; then
        echo "export LD_LIBRARY_PATH=/usr/lib64:\$LD_LIBRARY_PATH" >> $ENVFILE
    else
        echo "Can't find lib64 - using lib instead!"
    fi
fi

# 
# Set up the environment for the GENIE build.
#
source $ENVFILE
echo "Configuring GENIE environment in-shell."
echo "You will need to source $ENVFILE after the build finishes."

#
# For 2.9.X+, we must copy a patched PDF file into the $LHAPATH
# TODO - check to see if this is also handled in GENIESupport
# 
# For trunk prior to LHAPDF retirement we must copy a patched PDF file into the $LHAPATH
# 
cp -v $GENIE/data/evgen/pdfs/GRV98lo_patched.LHgrid $LHAPATH

#
# Configure and build GENIE
#
mypush $GENIEDIRNAME
echo "Configuring GENIE build..."
CONFIGSCRIPT="do_configure.sh"
echo -e "\043\041/usr/bin/env bash" > $CONFIGSCRIPT
echo -e "echo \"Running configuration script generated by the Lamp...\"" >> $CONFIGSCRIPT
echo -e "./configure \\" >> $CONFIGSCRIPT
if [ "$DEBUG" == "yes" ]; then
    echo -e "  --enable-debug \\" >> $CONFIGSCRIPT
    echo -e "  --with-optimiz-level=O0 \\" >> $CONFIGSCRIPT
else
    echo -e "  --with-optimiz-level=O2 \\" >> $CONFIGSCRIPT
fi
echo -e "  --enable-test \\" >> $CONFIGSCRIPT
echo -e "  --enable-fnal \\" >> $CONFIGSCRIPT
echo -e "  --enable-t2k \\" >> $CONFIGSCRIPT
echo -e "  --enable-atmo \\" >> $CONFIGSCRIPT
echo -e "  --enable-rwght \\" >> $CONFIGSCRIPT
echo -e "  --enable-vle-extension \\" >> $CONFIGSCRIPT
echo -e "  --enable-validation-tools \\" >> $CONFIGSCRIPT
echo -e "  --enable-roomuhistos \\" >> $CONFIGSCRIPT
if [[ $MAJOR == "trunk" ]]; then
    # TODO - let users pass in a flag for this?
    echo -e "  --with-compiler=gcc \\" >> $CONFIGSCRIPT
elif [[ $MAJOR == 2 ]]; then
    if [[ $MINOR -ge 11 ]]; then
        echo -e "  --with-compiler=gcc \\" >> $CONFIGSCRIPT
    fi
else
    badlamp
fi
echo -e "  --with-log4cpp-inc=$LOG4CPP_INC \\" >> $CONFIGSCRIPT
echo -e "  --with-log4cpp-lib=$LOG4CPP_LIB \\" >> $CONFIGSCRIPT
echo -e "  >& log_${BUILDSTARTTIME}.config" >> $CONFIGSCRIPT
echo -e " " >> $CONFIGSCRIPT
echo -e "# libxml is challenging for the auto-finder sometimes." >> $CONFIGSCRIPT
echo -e "#  --with-libxml2-inc=/usr/include/libxml2 \\" >> $CONFIGSCRIPT
echo -e "#  --with-libxml2-lib=/usr/lib64 \\" >> $CONFIGSCRIPT
chmod u+x $CONFIGSCRIPT
./$CONFIGSCRIPT
echo "Building GENIE..."
$MAKE >& log_$BUILDSTARTTIME.make
if grep -q "ailed" log_$BUILDSTARTTIME.make; then
    echo "Build failed! Please check the log file."
    exit 1
else
    echo "Build successful!"
fi
mypop

#
# Get cross section data
#
echo "Downloading Cross Section Data..."
if [ ! -d data ]; then
    mkdir data
else
    echo "Data directory already exists..."
fi
mypush data
XSECSPLINEDIR=`pwd`
FETCHLOG=log_$BUILDSTARTTIME.datafetch
if [[ $MAJOR == "trunk" ]]; then
    XSECDATA="none"          
elif [[ $MAJOR == 2 ]]; then
    if [[ $MINOR -eq 10 ]]; then
        if [[ $PATCH -ge 0 && $PATCH -le 10 ]]; then
            XSECDATA="gxspl-small.xml.gz"          
            if [ ! -f $XSECDATA ]; then
                # Use 2.10.0 splines for patches to 2.10
                # wget https://www.hepforge.org/archive/genie/data/${MAJOR}.${MINOR}.${PATCH}/$XSECDATA >& $FETCHLOG
                wget https://www.hepforge.org/archive/genie/data/${MAJOR}.${MINOR}.0/$XSECDATA >& $FETCHLOG
            else
                echo "Cross section data $XSECDATA already exists in `pwd`..."
            fi
        else
            badlamp
        fi
    elif [[ $MINOR -eq 11 ]]; then
        XSECDATA="gxspl-small.xml.gz"          
        if [ ! -f $XSECDATA ]; then
            # go ahead and use 2.10 splines for 2.11 (not a production release anyway)
            wget https://www.hepforge.org/archive/genie/data/2.10.0/$XSECDATA >& $FETCHLOG
        else
            echo "Cross section data $XSECDATA already exists in `pwd`..."
        fi
    elif [[ $MINOR -ge 12 ]]; then
        XSECDATA="none"          
    else
        badlamp
    fi
else
    badlamp
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
if [[ $XSECDATA == "none" ]]; then
    ./do_make_spline.sh --list CCQE --knots 50 --maxenergy 20 --target 1000180400 --nus -14,14
    ./do_a_run.sh --list CCQE --target 1000180400 --numevt 5 --run 42 --energy 3 --nus 14
else
    gevgen -n 5 -p 14 -t 1000080160 -e 0,10 -r 42 -f 'x*exp(-x)' \
        --seed 2989819 --cross-sections $XSECSPLINEDIR/$XSECDATA >& run_log_$BUILDSTARTTIME.txt
fi
if [ $? -eq 0 ]; then
    echo "Run successful!"
    echo "***********************************************************"
    echo "  NOTE: To run GENIE you MUST first source $ENVFILE "
    echo "***********************************************************"
    if [[ $XSECDATA != "none" ]]; then 
        mypush $XSECSPLINEDIR
        gunzip -f $XSECDATA
        echo " Note, unzipping $XSECDATA..."
        mypop
    fi
else 
    echo "Run failed! Please check the log file."
    exit 1
fi
mypop
echo " "
BUILDSTOPTIME=`date +%Y-%m-%d-%H-%M-%S`
echo "Finished at ${BUILDSTOPTIME}!"
