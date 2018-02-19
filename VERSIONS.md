# Tags

NOTE: Many of the older tags will not currently work for checking out code
from HepForge due to a repository restructuring. Please check the list of 
tags carefully and contact us if we can't cover your needs.

You may list the full set of available tags with

    git ls-remote --tags

* `R-2_12_10.0`: Updated for use with GENIE 2.12.10. Updated defaults,
comments, and documentation.
* `R-2_12_8.1`: Added `trunk` as a valid branch option when building
GENIE from GitHub.
* `R-2_12_8.0`: Updated for use with GENIE 2.12.8. Updated defaults,
comments, and documentation.
* `R-2_12_6.0`: Updated for use with GENIE 2.12.6. Updated defaults,
comments, and documentation.
* `R-2_12_4.0`: Updated for use with GENIE 2.12.4. Updated defaults,
comments, and documentation.
* `R-2_12_2.0`: Updated for use with GENIE 2.12.2. Updated defaults,
comments, and documentation.
* `R-2_12_0.0`: Updated for use with GENIE 2.12.0. Produce cross
sections on the fly for the test run if using GENIE 2.12.  Updated
comments and documentation.
* `R-2_11_0.0`: Updated for use with GENIE 2.11.0. Use newest support
tag (builds ROOT with CMake).
* `R-2_10_10.0`: Updated for use with GENIE 2.10.10. Stop building with
debugging symbols by default. Users should now supply a `-d/--debug` flag
if they want debugging symbols.
* `R-2_10_8.0`: Updated for use with GENIE 2.10.8.
* `R-2_10_6.1`: Pass the `-v/--verbose` flag to 
[GENIESupport](https://github.com/GENIEMC/GENIESupport)
* `R-2_10_6.0`: Updated for use with GENIE 2.10.6.
* `R-2_10_4.0`: Updated for use with GENIE 2.10.4.
* `R-2_10_2.0`: Updated for use with GENIE 2.10.2. Allow the user to opt
out of building RooMUHistos.
* `R-2_10_0.0`: Updated for use with GENIE 2.10.0.
* `R-2_9_0.1`: Update the paths to the SVN repository for the re-organized
configuration.
* `R-2_9_0.0`: Compliant with GENIE 2.9.0; uses tagged version of GENIESupport
[package](https://github.com/GENIEMC/GENIESupport) tag version `R-2_9_0.0`;
drop support for many little hacks required for different versions of GENIE
2.8.X (mostly different ways of handling the patched LHAPDF GRV98 pdf) and
support for loading 2.8.X splines, etc.
* `R-2_8_6.5`: Compliant with GENIE 2.8.6; updated for new HepForge SVN
paths.
* `R-2_8_6.4`: Compliant with GENIE 2.8.6; uses tagged version of GENIESupport
[package](https://github.com/GENIEMC/GENIESupport) tag version `R-2_8_6.3`;
numerous small updates and exit with a failure if the build fails. 
* `R-2_8_6.3`: Compliant with GENIE 2.8.6; uses tagged version of GENIESupport
[package](https://github.com/GENIEMC/GENIESupport) tag version `R-2_8_6.2`;
saves the GENIE configuration step as a script when running the build.
* `R-2_8_6.2`: Compliant with GENIE 2.8.6; uses tagged version of GENIESupport
[package](https://github.com/GENIEMC/GENIESupport) (tag `R-2_8_6.1` of
GENIESupport)
* `R-2_8_6.1`: Compliant with GENIE 2.8.6 (LHAPDF patched PDF handling)
* `R-2_8_4.1`: Compliant with GENIE 2.8.4 (LHAPDF patched PDF handling)
