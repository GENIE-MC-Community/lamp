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

If you rub the lamp, you will let GENIE out of the bottle! Running the script with 
no arguments will produce the help menu:

    Usage: ./rub_the_lamp.sh -<flag>
                           -p  #   : Build Pythia 6 or 8 and link ROOT to it (required).
                           -u name : The repository name. Default is the GENIEMC
                           -r tag  : Which ROOT version (default = v5-34-08).
                           -n      : Run configure, build, etc. under nice.
                           -s      : Use ssh to checkout code from GitHub.
     
    Note: Currently the user repository choice affects GENIE only - the support packages
    are always checked out from the GENIEMC organization respoistory.
     
      Examples:  
        ./rub_the_lamp.sh -p 6 -u GENIEMC                  # (GENIEMC is the default)
        ./rub_the_lamp.sh -p 6 -u <your GitHub user name> 
        ./rub_the_lamp.sh -p 8 -r v5-34-12
     
    Note: Advanced configuration of the support packages require inspection of that script.


This script is not fully functional yet. It supports Linux and will support Mac OSX
in the near future (we hope).

---
ASCII Art from [Chris.com](http://www.chris.com/ascii/index.php?art=movies/aladdin).

