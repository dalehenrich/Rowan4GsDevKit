# Rowan4GsDevKit
Project intended to permit the use of Rowan3 and Jadite4Pharo to edit GsDevKit source code 

Expect:
  1. [GsDevKit_stones](https://github.com/GsDevKit/GsDevKit_stones) to be installed, using branch v2.1.
  1. 3.7.1 to be publically available, requires a Rowan 3 extent ($GEMSTONE/bin/extent0.rowan3.dbf) to be available.
  2. $GEMSTONE/bin to be in PATH.
  3. Rowan4GsDevKit/bin to be in PATH

In a tode stone directory, <stone-name>, run the following scripts to create a tode_rowan3 project that will load be used to load the projects into a Rowan 3 stone for code management:

```
generatePackageList.topaz -lq
repositorySummary.solo loadedPackages.ston
generateProject.solo loadedPackages.ston --projectName=tode_rowan3 --componentName=Core
```
In a Rowan 3 stone directory, <stone-name>, run the following script to load the packages generated above into the stone. $projectsHome is a path to directory where the tode_rowan3 project was created: 
```
prepareSeasideExtent.topaz -lq
createSharedPools.stone
installProject.stone file:$projectsHome/tode_rowan3/rowan/specs/tode_rowan3.ston --projectsHome=$projectsHome --ignoreInvalidCategories -D --trace
```
At this point you should be able to use Jadeite to manage the GsDevKit code.

See tests/test_generate.sh for a bash script that can be used as a template for running the above steps using GsDevKit_stones.
