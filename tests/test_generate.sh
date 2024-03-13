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
rowan3ProjectSet=rowan3
devKitProjectSet=devkit
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

# create a $GS_VERS stone
export todeStoneName=tode_$GS_VERS
export rowan3StoneName=rowan3_$GS_VERS
scriptDir=`dirname "$0"`
# projectsHome is where the tode_rowan3 is located
export projectsHome=$STONES_HOME/$registry/stones/$todeStoneName/projectsHome
# devKitHome is where the github projects are cloned
devKitHome=$STONES_HOME/$registry/devKit

# BEGIN SKIPPED SECTION
skip="true"
skip="false"
if [ "$skip" = "false" ]; then

createRegistry.solo $registry --ensure

createProjectSet.solo --registry=$registry --projectSet=$devKitProjectSet \
  --from=$GSDEVKIT_STONES_ROOT/projectSets/$urlType/devkit.ston $*

createProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
  --from=$GSDEVKIT_STONES_ROOT/projectSets/$urlType/devkit.ston $*
#
# standard GsDevKit projects, plus:
# ----- loaded into Pharo11
# 	JadeiteForPharo:main								-- Pharo code base for JfP
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=JadeiteForPharo --gitUrl=git@github.com:GemTalk/JadeiteForPharo.git \
	--revision=main $*
#		PharoGemStoneFFI:main								-- GemStone server login support
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=PharoGemStoneFFI --gitUrl=git@github.com:GemTalk/PharoGemStoneFFI.git \
	--revision=main $*
#		RemoteServiceReplication:main				-- client/server object sharing
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=RemoteServiceReplication --gitUrl=git@github.com:GemTalk/RemoteServiceReplication.git \
	--revision=main $*
# ----- loaded into GemStone 3.7.1 extent0.rowan3.dbf
# 	Rowan:issue_917 										-- needed to do load GsDevKit projects (Rowan 3)
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=Rowan --gitUrl=git@github.com:GemTalk/Rowan.git \
	--dirName=RowanV3 --revision=issue_917 $*
#		Announcements:main									-- RemoteServiceReplication support
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=Announcements --gitUrl=git@github.com:GemTalk/Announcements.git \
	--revision=main $*
#		FileSystemGs:gs-3.7.x								-- GemStone base support
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=FileSystemGs --gitUrl=git@github.com:GemTalk/FileSystemGs.git \
	--revision=gs-3.7.x $*
#		RowanClientServices:ericV3.0_pharo	-- GemStone code base for JfP
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=RowanClientServices --gitUrl=git@github.com:GemTalk/RowanClientServices.git \
	--dirName=RowanClientServicesV3 --revision=ericV3.0_pharo $*
#	----- GsDevKit projects with special version requirements
#		glass:rowan4gsdevkit								-- modifications required to preserve Rowan 3 functionality
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=glass --gitUrl=git@github.com:glassdb/glass.git \
	--revision=rowan4gsdevkit $*
#		Sport:master												-- provide Sport class definitions without cracking an .mcz file
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=Sport --gitUrl=git@github.com:GsDevKit/Sport.git \
	--revision=master $*

registerProjectDirectory.solo --registry=$registry --projectDirectory=$devKitHome $*

# CLONE devkit projects into project directory ... these projects will be used to create the tODE stone
cloneProjectsFromProjectSet.solo --registry=$registry --projectSet=$devKitProjectSet --update $*


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

# create tode stone
template="default_tode"
createStone.solo --force --registry=$registry --template=$template $todeStoneName $GS_VERS $*

# create Rowan 3 stone
template="default_rowan3"
createStone.solo --force --registry=$registry --template=$template $rowan3StoneName $GS_VERS $*

pushd $STONES_HOME/$registry/stones/$rowan3StoneName
	updateCustomEnv.solo --addKey=ROWAN_PROJECTS_HOME --value=$devKitHome $*
popd

#start stones
startStone.solo --registry=$registry $todeStoneName -b $*
startStone.solo --registry=$registry $rowan3StoneName -b $*

gslist.solo -lc

#
# install tODE
#
cd $STONES_HOME/$registry/stones/$todeStoneName

loadTode.stone --projectDirectory=$devKitHome $*

todeIt.stone -h
todeIt.stone 'eval `3+4`' $*

# CLONE/UPDATE rowan3 projects into project directory ... these projects will be used to create the rowan3 stone
cloneProjectsFromProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet --update $*

# generate the Rowan 3 project in the tODE stone directory
export PATH=$scriptDir/../bin:$PATH
generatePackageList.topaz -lq
repositorySummary.solo loadedPackages.ston $*

# generateProject.solo needs to run with a rowan3 extent from 3.7.1
OLD_PATH=$PATH
export GEMSTONE=`registryQuery.solo -r $registry --product=3.7.1`
export PATH=$GEMSTONE/bin:$PATH
generateProject.solo loadedPackages.ston --projectName=tode_rowan3 --componentName=Core \
	--sportPackageDirPath=$devKitHome/Sport/src \
	--sportPackageName=Sport.v3 $*

# revert to original path
export PATH=$OLD_PATH
unset GEMSTONE

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

#
# end of the non-skip section
#
else	# ($skip = true)
# start of skipped section

cd $STONES_HOME/$registry/stones/$rowan3StoneName

export PATH=$scriptDir/../bin:$PATH

#
# Copy Rowan 3 extent from snapshot directory
#

newExtent.solo -r $registry $rowan3StoneName -e snapshots/extent0.prepared_rowan3.dbf  $*

#rerun this script, because it will have changes that we want to apply to the prepared_rowan3.dbf extent
createSharedPools.stone $*

fi
# END SKIPPED SECTION

snapshot.stone snapshots --extension="prepared_rowan3.dbf" $*

installProject.stone file:$projectsHome/tode_rowan3/rowan/specs/tode_rowan3.ston --projectsHome=$projectsHome --ignoreInvalidCategories --noAutoInitialize --trace  $*

snapshot.stone snapshots --extension="tode_rowan3.dbf" $*
