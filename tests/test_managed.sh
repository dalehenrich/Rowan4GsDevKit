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
export projectsHome=$STONES_HOME/$registry/stones/$todeStoneName/projectsHome
# devKitHome is where the github projects are cloned
devKitHome=$STONES_HOME/$registry/devKit

# BEGIN SKIPPED SECTION
skip="true"
skip="false"
if [ "$skip" = "false" ]; then
# ASSUME THAT test_generate.sh has already been run...

#
# install managed projects Zinc for now.
#
cd $STONES_HOME/$registry/stones/$todeStoneName

metacelloLoad.stone -D --project=ZincHTTPComponents --repoPath=repository --projectDirectory=/bosch1/users/dhenrich/_stones/tode/devkit/zinc
# metacelloLoad.stone -D --project=Seaside3 --repoPath=repository --projectDirectory=/bosch1/users/dhenrich/_stones/tode/devkit/Seaside Welcome Development 'Zinc Project' Examples CI

snapshot.stone snapshots --extension=`date +%m-%d-%Y_%H:%M:%S`_zinc_tode.dbf

generateManagedPackageList.stone --loadedPackages=loadedPackages.ston --managedPackages=zincPackages.ston--projectName=$rowan3ProjectName $*

# examine managedPackages.ston ... should see zinc packages and ???
exit 0

#
# install GsDevKit packages in Rowan 3 stone directory
#

cd $STONES_HOME/$registry/stones/$rowan3StoneName
ln -s $projectsHome .

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

fi
# END SKIPPED SECTION

snapshot.stone snapshots --extension="prepared_rowan3.dbf" $*

installProject.stone file:$projectsHome/$rowan3ProjectName/rowan/specs/$rowan3ProjectName.ston --projectsHome=$projectsHome --ignoreInvalidCategories --noAutoInitialize --trace  $*

snapshot.stone snapshots --extension="$rowan3ProjectName.dbf" $*
