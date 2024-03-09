#! /usr/bin/env bash
#
# sample script for setting up a Rowan4GsDevKit dev environment
#		
set -xe

echo "***** test_generate.sh *****"

if [ ! -d $STONES_HOME/test_git ]; then
	mkdir $STONES_HOME/test_git
else
	rm -rf  $STONES_HOME/test_git/*
fi

if [ "$CI" != "true" ]; then
	if [ "$GS_VERS"x = "x" ] ; then
		export GS_VERS=3.7.1
	fi
fi

registry=test_Rowan4GsDevKit
projectSet=devkit
todeHome="$STONES_HOME/$registry/tode"

export urlType=ssh
if [ "$CI" = "true" ]; then
	# GSDEVKIT_STONES_ROOT defined in ci.yml
	export urlType=https
else
	# GSDEVKIT_STONES_ROOT is $STONES_HOME/git ... the location that GsDevKit_stones 
	#	was cloned when superDoit was installed
	export GSDEVKIT_STONES_ROOT=$STONES_HOME/git/GsDevKit_stones
fi

createRegistry.solo $registry --ensure

if [ -d $STONES_HOME/devKit/ ]; then
	rm -rf  $STONES_HOME/$registry/devKit
fi

createProjectSet.solo --registry=$registry --projectSet=$projectSet \
  --from=$GSDEVKIT_STONES_ROOT/projectSets/$urlType/devkit.ston $*
# clone Rowan:issue_917 ... needed to do load
updateProjectSet.solo --registry=$registry --projectSet=$projectSet \
	--projectName=Rowan --gitUrl=git@github.com:GemTalk/Rowan.git \
	--revision=issue_917 $*

registerProjectDirectory.solo --registry=$registry --projectDirectory=$STONES_HOME/$registry/devkit $*

# cloneProjectsFromProjectSet.solo will create the project directory if it does not already exist
cloneProjectsFromProjectSet.solo --registry=$registry --projectSet=$projectSet $*


# create and register a product directory where GemStone product trees are kept.
if [ ! -d $STONES_HOME/test_gemstone ]; then
	mkdir $STONES_HOME/test_gemstone
else
	echo "reuse $STONES_HOME/test_gemstone for now"
	# chmod -R +w $STONES_HOME/test_gemstone *
	# rm -rf  $STONES_HOME/test_gemstone/*
fi
registerProductDirectory.solo --registry=$registry --productDirectory=$STONES_HOME/test_gemstone $*

# enable download when 3.7.1 ships
# downloadGemStone.solo --registry=$registry 3.7.1 $GS_VERS $*

# update product list from shared product directory when a download is done by shared registry
registerProduct.solo --registry=$registry --fromDirectory=$STONES_HOME/test_gemstone $*

# create and register stones directory for test_rowanV3
if [ ! -d $STONES_HOME/$registry/stones ]; then
	mkdir $STONES_HOME/$registry/stones
else
	rm -rf $STONES_HOME/$registry/stones
	mkdir $STONES_HOME/$registry/stones
fi

registerStonesDirectory.solo --registry=$registry --stonesDirectory=$STONES_HOME/$registry/stones $*

if [ ! -d $todeHome ]; then
	mkdir $todeHome
else
	rm -rf $todeHome/*
fi

registerTodeSharedDir.solo --registry=$registry \
                           --todeHome=$todeHome \
                           --populate $*


# create a $GS_VERS stone
export todeStoneName=tode_$GS_VERS
export rowan3StoneName=rowan3_$GS_VERS

# create tode stone
template="default_tode"
createStone.solo --registry=$registry --template=$template $todeStoneName $GS_VERS $*

# create Rowan 3 stone
template="default_rowan3"
createStone.solo --registry=$registry --template=$template $rowan3StoneName $GS_VERS $*

#start stones
startStone.solo --registry=$registry $todeStoneName -b $*
startStone.solo --registry=$registry $rowan3StoneName -b $*

gslist.solo -lc

#
# install tODE
#
cd $STONES_HOME/$registry/stones/$todeStoneName
export projectsHome=$STONES_HOME/$registry/stones/$todeStoneName/projectsHome
loadTode.stone --projectDirectory=$STONES_HOME/$registry/devkit $*

todeIt.stone -h
todeIt.stone 'eval `3+4`' $*

# generate the Rowan 3 project in the tODE stone directory
scriptDir=`dirname "$0"`
export PATH=$scriptDir/../bin:$PATH
generatePackageList.topaz -lq
repositorySummary.solo loadedPackages.ston $*

# generateProject.solo needs to run with a rowan3 extent from 3.7.1
OLD_PATH=$PATH
export GEMSTONE=`registryQuery.solo -r $registry --product=3.7.1`
export PATH=$GEMSTONE/bin:$PATH
generateProject.solo loadedPackages.ston --projectName=tode_rowan3 --componentName=Core $*

# revert to original path
export PATH=$OLD_PATH
unset GEMSTONE

#
# install GsDevKit packages in Rowan 3 stone directory
#
cd $STONES_HOME/$registry/stones/$rowan3StoneName
ln -s $projectsHome .

# until 3.7.2 ships, we need to use Rowan:issue_917 when doing the GsDevKit install
devKitHome=`registryQuery.solo -r $registry --projectDirectory`
installProject.stone file:$scriptDir/../specs/Rowan.ston --projectsHome=devKitHome --ignoreInvalidCategories --trace  $*

prepareSeasideExtent.topaz -lq
createSharedPools.stone $*
snapshot.stone snapshots --extension="prepared_rowan3.dbf" $*

installProject.stone file:projectsHome/tode_rowan3/rowan/specs/tode_rowan3.ston --projectsHome=projectsHome --ignoreInvalidCategories --trace  $*

snapshot.stone snapshots --extension="tode_rowan3.dbf" $*
