# READ ME FIRST!

This version of `lamp` is designed to work with GENIE `R-2_9_0`!

It is a good idea to use a tagged version of the `lamp`. The latest
recommended tag is `R-2_9_0.0`. Use the following command to check
it out (and read below for more if you're really interested). After
cloning the repository, `cd` into the `lamp` directory and run:

    git checkout -b R-2_9_0.0-br R-2_9_0.0

Run `./rub_the_lamp.sh -h` to get a help menu. If you run into trouble,
please consult the "Trouble-Shooting" section below. If you find a 
bug, please feel free to contact Gabe Perdue (`perdue` at Fermilab)
or open an issue on [GitHub](https://github.com/GENIEMC/lamp).

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

    git checkout -b R-2_9_0.0-br R-2_9_0.0

This will checkout _tag_ `R-2_9_0.0` into _branch_ `R-2_9_0.0-br`. You want to
checkout into a branch to avoid being in a "detached `HEAD`" state.

Check the [releases](https://github.com/GENIEMC/lamp/releases) page to be sure 
you are using a version of `lamp` that is appropriate for the version of GENIE
you want to use. `lamp` has been tested for GENIE `R-2_8_0` and later. It may
not work with earlier versions. This version of `lamp` is designed to work with
GENIE `R-2_9_0`, and you will need to check out an older release of `lamp` to
work with the 2.8 series.

## Basic Usage

If you rub the lamp, you will let GENIE out of the bottle! Running the script with 
no arguments will produce the help menu:

    Welcome to rub_the_lamp. This script will build the 3rd party support
    packages for GENIE and then build GENIE itself. 
    
    Usage: ./rub_the_lamp.sh -<flag>
                 -h / --help   : Help
                 -g / --github : Check out GENIE code from GitHub
                 -f / --forge  : Check out GENIE code from HepForge
                                 (DEFAULT)
                 -r / --repo   : Specify the GitHub repo"
                                 (default == GENIE_2_8_6)"
                                 Available: GENIE_2_8, GENIE_2_8_6"
                 -u / --user   : Specify the GitHub user"
                                 (default == GENIEMC)"
                 -t / --tag    : Specify the HepForge SVN tag
                                 (default == R-2_8_4)
                 -b / --branch : Specify the GitHub GENIE branch
                                 (default == master)
                 -p / --pythia : Pythia version (6 or 8)
                                 (default == 6)
                 -n / --nice   : Run make under nice
                                 (default == normal make)
                 -o / --root   : ROOT tag version
                                 (default == v5-34-24)
                 -s / --https  : Use HTTPS checkout from GitHub
                                 (default is ssh)
                 -c / --force  : Archive existing packages and rebuild
                                 (default is to keep the existing area)
                 --support-tag : Tag for GENIE Support Builder (3rd party code) 

      All defaults: 
        ./rub_the_lamp.sh
      Produces: R-2_8_6 from HepForge, Pythia6, ROOT v5-34-24
    
      Other examples: 
        ./rub_the_lamp.sh --forge
        ./rub_the_lamp.sh -f --tag trunk
        ./rub_the_lamp.sh -g -u GENIEMC --root v5-34-24 -n
        ./rub_the_lamp.sh --support-tag head
        ./rub_the_lamp.sh --support-tag R-2_9_0.0

    Note: Advanced configuration of the support packages require inspection of that script.

This script only supports Linux. It may support Mac OSX in the future (we hope).


## Pythia

Checking out [Pythia](http://home.thep.lu.se/~torbjorn/Pythia.html) version 8 is an option, 
but GENIE will not currently build against it. Please specify only Pythia version 6 for now.


## Checking Available HepForge Tags

Currently, if checking out from GitHub, only 2.8.0 is available. If checking out from
HepForge (recommended except for very specific development tasks), you may see the 
available tags with:

    Usage: ./list_hepforge_branches.sh


## Trouble-Shooting

Sometimes you may run into permissions troubles with `https` or `ssh`, so toggle usage
of the `-s` flag if you are gettting permission denied errors.

If the build fails it is important to check the logs for each of the 3rd party
support packages installed under `GENIESupport`. It is possible you are 
missing requirements for those packages to build. [ROOT](http://root.cern.ch/drupal/)
especially requires a large number of libraries to be installed.

This is a bash script, so some errors will likely occur under different shells. If 
you get errors, make sure `/bin/bash` exists and is not a link to a different executable.

If there is a strong desire for a c-shell or some other version of this script, 
we welcome a translation!

If you are having trouble installing some items (especially log4cpp) it
is possible you are missing the autoconf tools. In that case, you can
install them with a package manager:

* `sudo apt-get install autoconf` (Ubuntu)
* `yum install autoconf` (RedHat/SLF)
* Download source from [GNU](http://ftp.gnu.org/gnu/autoconf/) and build.
* etc.

## Contributors

* Gabriel Perdue,  [Fermilab](http://www.fnal.gov)
* Mathieu Labare,  [Universiteit Gent](http://www.ugent.be)
* Tom Van Cuyck,   [Universiteit Gent](http://www.ugent.be)
* Kevin McFarland, [University of Rochester](http://www.rochester.edu)
* Julia Yarba,     [Fermilab](http://www.fnal.gov)

---
ASCII Art from [Chris.com](http://www.chris.com/ascii/index.php?art=movies/aladdin).

