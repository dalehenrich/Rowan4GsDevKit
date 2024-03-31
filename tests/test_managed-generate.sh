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

# ASSUME THAT test_generate-prepare.sh and test_generate-generate.sh has already been run...

#
# install managed projects into tode stone: Seaside.
#
cd $STONES_HOME/$registry/stones/$todeStoneName

newExtent.solo -r $registry $todeStoneName -e snapshots/extent0.generated_tode.dbf  $*

generateManagedPackageList.stone --loadedPackages=loadedPackages.ston --managedPackages=seasidePackages.ston--projectName=$rowan3ProjectName $*

ECHO "**** EARLY EXIT BEFORE INSTALLING MANAGED PROJECTS FOR DEGUGGING ****"
exit 0

# Prepare to install Managed packages into rowan3 stone

cd $STONES_HOME/$registry/stones/$rowan3StoneName

# Copy Rowan 3 extent from snapshot directory

newExtent.solo -r $registry $rowan3StoneName -e snapshots/extent0.prepared_rowan3.dbf  $*

#
# install GsDevKit packages in Rowan 3 stone directory
#

installProject.stone file:$projectsHome/$rowan3ProjectName/rowan/specs/$rowan3ProjectName.ston --projectsHome=$projectsHome --ignoreInvalidCategories --noAutoInitialize --trace  $*

echo "***** FINISHED - test_managed.sh *****"

