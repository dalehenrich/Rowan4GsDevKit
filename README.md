# Rowan4GsDevKit
Project intended to permit the use of Rowan3 and Jadite4Pharo to edit GsDevKit source code 

Expect:
  1. [GsDevKit_stones](https://github.com/GsDevKit/GsDevKit_stones) to be installed, using branch v2.
  1. 3.7.1 to be publically available, requires a Rowan 3 extent ($GEMSTONE/bin/extent0.rowan3.dbf) to be available.
  2. $GEMSTONE/bin to be in PATH.
  3. Rowan4GsDevKit/bin to be in PATH

Run the following scripts in the stone directory for <stone-name> to generate the Rowan 3 project project:

```
refresh_tode_371.sh <stone-name>
generatePackageList.topaz -lq
repositorySummary.solo loadedPackages.ston
generateProject.solo loadedPackages.ston --projectName=tode --componentName=Core
```
