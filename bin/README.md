lsstinstall bins
================

The lsstinstall executable shell script is an eups wrapper.
It will create a local workspace lsst_wrk, in the home directoy. 
The workspace can be customized using environment variable


The envconfig bash, to be sourced, 
provides an easy way to discover which environment are available and enable them


These scripts are meant to be distributed via conda.

Highlights:
- envref is derived from the corresponding source package metadata
- eups executabler is installed from conda-forge
- for each environment, a load shell is create, to be included in the .bashrc.
