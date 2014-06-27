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

#Basic Usage

If you rub the lamp, you will let GENIE out of the bottle! Running the script with 
no arguments will produce the help menu:

    Usage: ./rub_the_lamp.sh -<flag>
                           -p  #   : Build Pythia 6 or 8 and link ROOT to it (required).
                           -u name : The repository name. Default is the GENIEMC
                           -r tag  : Which ROOT version (default = v5-34-18).
                           -n      : Run configure, build, etc. under nice.
                           -s      : Use https to checkout code from GitHub (default is ssh).
                           -m      : Use `make` instead of `gmake`.
     
    Note: Currently the user repository choice affects GENIE only - the support packages
    are always checked out from the GENIEMC organization respoistory.
     
      Examples:  
        ./rub_the_lamp.sh -p 6 -u GENIEMC                  # (GENIEMC is the default)
        ./rub_the_lamp.sh -p 6 -u <your GitHub user name> 
        ./rub_the_lamp.sh -p 8 -r v5-34-12
     
    Note: Advanced configuration of the support packages require inspection of that script.


This script only supports Linux. It may support Mac OSX in the future (we hope).

#Trouble-Shooting

NOTE: There is currently an issue with the interaction between the 3rd party support
software installer and the main installer. You may need to run the script twice. 
Just run it again immediately after the 3rd party code builds if GENIE is not 
built (the 3rd party code will not be rebuilt if its directory is already present).

If the build fails it is important to check the logs for each of the 3rd party
support packages installed under `GENIESupport`. It is possible you are 
missing requirements for those packages to build. [ROOT](http://root.cern.ch/drupal/)
especially requires a large number of libraries to be installed.

Sometimes you may run into permissions troubles with `https` or `ssh`, so toggle usage
of the `-s` flag if you are gettting permission denied errors.

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

It is possible that there is a problem with `make` vs. `gmake` on your 
system. If you find cryptic error messages associated with libtool and 
autoconf while attempting to build log4cpp, you may chose to try make
in place of gmake. This seems to be a frequent problem for Ubuntu 
users.

##Contributors

* Gabriel Perdue, [Fermilab](http://www.fnal.gov)
* Mathieu Labare, [Universiteit Gent](http://www.ugent.be)
* Tom Van Cuyck,  [Universiteit Gent](http://www.ugent.be)

---
ASCII Art from [Chris.com](http://www.chris.com/ascii/index.php?art=movies/aladdin).

