# Rowan4GsDevKit
Project intended to permit the use of Rowan3 and Jadite4Pharo to edit GsDevKit source code 

Expect:
  1. [GsDevKit_stones](https://github.com/GsDevKit/GsDevKit_stones) to be installed, using branch v2.1.
  1. 3.7.1 to be publically available, requires a Rowan 3 extent ($GEMSTONE/bin/extent0.rowan3.dbf) to be available.
  2. $GEMSTONE/bin to be in PATH.
  3. Rowan4GsDevKit/bin to be in PATH

The bash script tests/master_base_tode.sh creates:
- A registry named test_Rowan4GsDevKit.
- A tode_r4_3.7.1 stone with a standard tODE projects installed.
- A devKit project directory with the standard GsDevKit projects including Rowan and JadeiteForPharo projects.
- A project named base_tode_rowan3 which includes all of the packages used in the basic tODD stone. 
- A stone name rowan3_r4_3.7.1 that has the base_tode_rowan3 project already preloaded.

### Example #1: run tests/master_base_tode.sh and create a project using a pre-generated packageMap for Seaside

Here's an example bash session using tests/master_base_tode.sh using a pre-generated Seaside package map ($rowan4gsdevkit_root/packageMaps/371/seaside.ston):
```
rowan4gsdevkit_root=<path-to-Rowan4GsDevKit-project>

$rowan4gsdevkit_root/tests/master_baseTode.sh

# generate a Rowan 3 project for doing seaside development
rowanProjectName=seaside_rowan3
registryName=test_Rowan4GsDevKit
devkitHome=$STONES_HOME/test_Rowan4GsDevKit/devKit
stoneDirectory=`registryQuery.solo -r $registryName  --stonesDirectory`
projectsHome=$stoneDirectory/tode_r4_3.7.1/projectsHome
$rowan4gsdevkit_rootbin/generateProject.solo $rowan4gsdevkit_root/packageMaps/371/seaside.ston \
                                             --projectName=$rowanProjectName --componentName=Core \
                                             --projectsHome=$projectsHome --devkitHome=$devkitHome
# install the seaside_rowan3 project into rowan3_r4_3.7.1 stone
cd $stoneDirectory
installProject.stone file:projectsHome/seaside_rowan3/rowan/specs/seaside_rowan3.ston --projectsHome=projectsHome --ignoreInvalidCategories --noAutoInitialize
```


```
## UTILITY SCRIPTS

# example that stops the stones 
stopStone.solo -i -r test_Rowan4GsDevKit rowan3_r4_3.7.1 -b
stopStone.solo -i -r test_Rowan4GsDevKit tode_r4_3.7.1 -b

# example that starts the stones 
startStone.solo -r test_Rowan4GsDevKit rowan3_r4_3.7.1 -b
stopStone.solo -r test_Rowan4GsDevKit tode_r4_3.7.1 -b
``
