#! /usr/bin/env bash
#
# sample script for setting up a Rowan4GsDevKit dev environment
#		
set -xe

echo "***** test_generate-generate.sh *****"

# CLONE/UPDATE rowan3 projects into project directory ... these projects will be used to create the rowan3 stone
cloneProjectsFromProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet --update $*

# generate the Rowan 3 project in the tODE stone directory
generatePackageList.stone loadedPackages.ston --projectsHome=$devKitHome $*
repositorySummary.solo loadedPackages.ston $*

# generateProject.solo needs to run with a rowan3 extent from $GS_VERS (3.7.1 or later)
OLD_PATH="$PATH"
OLD_GEMSTONE="$GEMSTONE"
export GEMSTONE=`registryQuery.solo -r $registry --product=$GS_VERS`
export PATH=$GEMSTONE/bin:$PATH
generateProject.solo loadedPackages.ston --projectName=$rowan3ProjectName --componentName=Core \
	--devkitHome=$devKitHome --projectsHome=projectsHome \
	--sportPackageDirPath=$devKitHome/Sport/src \
	--sportPackageName=Sport.v3 $*

# revert to original path and gemstone
export PATH="$OLD_PATH"
if [ "$OLD_GEMSTONE"x = "x" ]; then
	unset GEMSTONE
else
	export GEMSTONE="$OLD_GEMSTONE"
fi

#
# install GsDevKit packages in Rowan 3 stone directory
#

cd $STONES_HOME/$registry/stones/$rowan3StoneName
ln -s $projectsHome .

# attach all of standard GemStone git projects in the image to the clones in $devKitHome
attachRowanDevClones.stone --projectsHome=$devKitHome $*

# make sure the image is in Legacy streams mode
prepareSeasideExtent.topaz -lq
# create classes and pool variables so that GsDevKit code will compile
createSharedPools.stone $*

snapshot.stone snapshots --extension="prepared_rowan3.dbf" $*

installProject.stone file:$projectsHome/$rowan3ProjectName/rowan/specs/$rowan3ProjectName.ston --projectsHome=$projectsHome --ignoreInvalidCategories --noAutoInitialize --trace  $*

snapshot.stone snapshots --extension="$rowan3ProjectName.dbf" $*

echo "***** FINISHED -- test_generate-generate.sh *****"
