#! /usr/bin/env bash
#
# Sample script for setting up a Rowan4GsDevKit dev environment on one or more managed projects.
#
# It is not safe to write out the packages for the generated tode projects as those projects use 
# a variety of filetree export formats that on write of the tode_rowan3 project result in way too
# many spurious modifications.
#		
#	Managed projects are projects that you intend to update and if a managed project uses an older 
#	filetree format, you can update the filetree format before making changes that you want to track.
# Messy, but that's what would happen if you were using tODE to make the changes.
#
set -xe

echo "***** test_managed.sh *****"

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

# shared with generate script
registry=test_Rowan4GsDevKit
rowan3ProjectSet=rowan3
devKitProjectSet=devkit
todeHome="$STONES_HOME/$registry/tode"
todeStoneName=tode_r4_$GS_VERS
rowan3StoneName=rowan3_r4_$GS_VERS
# unique in ths script
rowan3ProjectName=managed_rowan3

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
scriptDir=`dirname "$0"`
# projectsHome is where the tode_rowan3 is located
projectsHome=$STONES_HOME/$registry/stones/$todeStoneName/projectsHome
# devKitHome is where the github projects are cloned
devKitHome=$STONES_HOME/$registry/devKit

# ASSUME THAT test_generate.sh has already been run...

#
# install managed projects into tode stone: Seaside.
#
cd $STONES_HOME/$registry/stones/$todeStoneName

newExtent.solo -r $registry $todeStoneName -e snapshots/extent0.generated_tode.dbf  $*

metacelloLoad.stone --onConflictUseLoaded --project=Seaside3 --repoPath=repository --projectDirectory=$devKitHome/Seaside Welcome Development Examples CI $*

snapshot.stone snapshots --extension=seaside_tode.dbf $*

generateManagedPackageList.stone --loadedPackages=loadedPackages.ston --managedPackages=seasidePackages.ston--projectName=$rowan3ProjectName $*

ECHO "EARLY EXIT FOR DEGUGGING"
exit 0

# Prepare to install Managed packages into rowan3 stone

cd $STONES_HOME/$registry/stones/$rowan3StoneName

# Copy Rowan 3 extent from snapshot directory

newExtent.solo -r $registry $rowan3StoneName -e snapshots/extent0.prepared_rowan3.dbf  $*

#
# install GsDevKit packages in Rowan 3 stone directory
#

installProject.stone file:$projectsHome/$rowan3ProjectName/rowan/specs/$rowan3ProjectName.ston --projectsHome=$projectsHome --ignoreInvalidCategories --noAutoInitialize --trace  $*

snapshot.stone snapshots --extension="$rowan3ProjectName.dbf" $*
