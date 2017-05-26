# READ ME FIRST!

This version of `lamp` is designed to work with GENIE `R-2_12_6`! It should
also work with `R-2_10_2`, but earlier versions may require checking out
older tags of `lamp` (see below).

It is a good idea to use a tagged version of the `lamp`. The latest
recommended tag is `R-2_12_6.0`. Use the following command to check
it out (and read below for more if you're really interested). After
cloning the repository, `cd` into the `lamp` directory and run:

    git checkout -b R-2_12_6.0-br R-2_12_6.0

Run `./rub_the_lamp.sh -h` to get a help menu. If you run into trouble,
please consult the "Trouble-Shooting" section below. If you find a 
bug, please feel free to contact Gabe Perdue (`perdue` at Fermilab)
or open an issue on [GitHub](https://github.com/GENIEMC/lamp).

NOTE: On May 4, 2015 the GENIE SVN repository on HepForge was 
re-orgnaized, breaking the SVN checkout path in some versions of`lamp`.
Please check the version tags and use one appropriate for your needs
with respecrt to this change. If you continue to have checkout problems
for a specific version of GENIE, please let Gabe Perdue know (contact
info below) or open an issue on GitHub.

Let [GENIE](http://genie.hepforge.org) out of the bottle!

                                              ..                               
                                             dP/$.                             
                                             $4$$%                             
                                           .ee$$ee.                            
                                        .eF3??????$C$r.        .d$$$$$$$$$$$e. 
     .zeez$$$$$be..                    JP3F$5'$5K$?K?Je$.     d$$$FCLze.CC?$$$e 
         """??$$$$$$$$ee..         .e$$$e$CC$???$$CC3e$$$$.  $$$/$$$$$$$$$.$$$$ 
                `"?$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$b $$"$$$$P?CCe$$$$$F 
                     "?$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$b$$J?bd$$$$$$$$$F" 
                         "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$d$$F"           
                            "?$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"...           
                                "?$$$$$$$$$$$$$$$$$$$$$$$$$F "$$"$$$$b         
                                    "?$$$$$$$$$$$$$$$$$$F"     ?$$$$$F         
                                         ""????????C"                          
                                         e$$$$$$$$$$$$.                        
                                       .$b CC$????$$F3eF                       
                                     4$bC/%$bdd$b@$Pd??Jbbr                    
                                       ""?$$$$eeee$$$$F?"                      

## Tags and versioning

When first checking out this package, you will have the `HEAD` version of the
`master` branch. Get a specific tagged release by checking out the tag into a
branch like so:

    git checkout -b R-2_12_6.0-br R-2_12_6.0

This will checkout _tag_ `R-2_12_6.0` into _branch_ `R-2_12_6.0-br`. You want to
checkout into a branch to avoid being in a "detached `HEAD`" state.

Check the [releases](https://github.com/GENIEMC/lamp/releases) page to be sure 
you are using a version of `lamp` that is appropriate for the version of GENIE
you want to use. `lamp` has been tested for GENIE `R-2_8_0` and later. It may
not work with earlier versions. This version of `lamp` is designed to work with
GENIE `R-2_10_2` or later, and you will need to check out an older release of 
`lamp` to work with the 2.8 series.

You can do this with a branch checkout command that will switch to the version
of the code matching the tag and also put you on a separate branch (away from
master) in case you want to make commits, etc. See the VERSIONS.md file in this
package for more information.

* The latest version is 2.12.6. To use 2.12.6, you want tag "R-2_12_6.0":

    git checkout -b R-2_12_6.0-br R-2_12_6.0

* To use 2.10.0, you probably want tag `R-2_10_0.0`:

        git checkout -b R-2_10_0.0-br R-2_10_0.0

* To use 2.8.6, you probably want tag `R-2_8_6.5`:

        git checkout -b R-2_8_6.5-br R-2_8_6.5

* If you have created a repo with a different name or naming structure from
those expected by lamp, you will need to update this script or rename your
repository. This script expects repositories in HepForge to look like 
R-X_Y_Z and in GitHub to look like GENIE, with the version set by the 
**branch name**. You may grep this script for the checklamp function to see
how the major, minor, and patch version numbers are managed.

## Basic Usage

If you rub the lamp, you will let GENIE out of the bottle! Running the script with 
no arguments will produce the help menu:

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
                                 (default == R-2_12_6)
                                 Available: use ./list_hepforge_branches.sh
                 -b / --branch : Specify the GitHub GENIE branch
                                 (default == R-2_12_6)
                 -p / --pythia : Pythia version (6 or 8)
                                 (default == 6)
                                 8 is under construction! Not available yet.
                 -n / --nice   : Run make under nice
                                 (default == normal make)
                 -o / --root   : ROOT tag version
                                 (default == v5-34-36)
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
                                 (default is R-2_11_0.0)
                 --no-roomu    : build without RooMUHistos (requires Boost)
                                 (default is to use RooMUHistos)
    
      All defaults:
        ./rub_the_lamp.sh
      Produces: R-2_12_6 from HepForge, Pythia6, ROOT v5-34-36
    
      Other examples:
        ./rub_the_lamp.sh --forge
        ./rub_the_lamp.sh -f --tag trunk
        ./rub_the_lamp.sh -g -u GENIEMC --root v5-34-24 -n
    
    Note: Advanced configuration of the support packages may require inspection of
    that script.

This script only supports Linux. It may support Mac OSX in the future (we hope).

## Pythia

Checking out [Pythia](http://home.thep.lu.se/~torbjorn/Pythia.html) version 8
is an option, but GENIE will not currently build against it. Please specify
only Pythia version 6 for now.


## Checking Available HepForge Tags

If checking out from HepForge (recommended except for very specific development
tasks), you may see the available tags with:

    Usage: ./list_hepforge_branches.sh


## Trouble-Shooting

Sometimes you may run into permissions troubles with `https` or `ssh`, so toggle
usage of the `-s` flag if you are gettting "permission denied" errors.

If the build fails it is important to check the logs for each of the 3rd party
support packages installed under `GENIESupport`. It is possible you are 
missing requirements for those packages to build. [ROOT](https://root.cern.ch)
especially requires a large number of libraries to be installed. See the
provisioning scripts in the [Wayfarer](https://github.com/GENIEMC/Wayfarer)
project for clues on libraries your system may be missing.

One common set of errors involve `log4cpp`; it is likely in this case that you
are missing the autoconf tools. In that case, you can install them with a
package manager:

* `sudo apt-get install autoconf` (Ubuntu)
* `yum install autoconf` (RedHat/SLF)
* Download source from [GNU](http://ftp.gnu.org/gnu/autoconf/) and build.
* etc.

This is a bash script, so some errors will likely occur under different shells.
If you get errors, make sure `/bin/bash` exists and it is not a link to a
different executable.

If there is a strong desire for a c-shell or some other version of this script, 
we welcome a translation!

## Contributors

* Gabriel Perdue,  [Fermilab](http://www.fnal.gov)
* Mathieu Labare,  [Universiteit Gent](http://www.ugent.be)
* Tom Van Cuyck,   [Universiteit Gent](http://www.ugent.be)
* Kevin McFarland, [University of Rochester](http://www.rochester.edu)
* Julia Yarba,     [Fermilab](http://www.fnal.gov)
* Ryan Hill,       [Queen Mary University of London](http://www.qmul.ac.uk)
* Martti Nirkko,   [University of Bern](http://www.unibe.ch)

Please contact Gabe Perdue (`perdue "at" fnal.gov`) for complex inquiries, etc.

---
ASCII Art from [Chris.com](http://www.chris.com/ascii/index.php?art=movies/aladdin).
