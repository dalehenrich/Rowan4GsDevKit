#! /usr/bin/env bash
#
# sample driver script for setting up a tODE stone with projects that will be loaded
#	into a Rowan 3 stone for editting
#		
set -xe
echo "***** master_gsApplicationTools_seaside_zinc.sh *****"

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

# shared with all scripts
export registry=test_Rowan4GsDevKit
export rowan3ProjectSet=rowan3
export devKitProjectSet=devkit
export registryHome=$STONES_HOME/$registry
export todeHome="$registryHome/tode"
export todeStoneName=tode_r4_$GS_VERS
export rowan3StoneName=rowan3_r4_$GS_VERS

# rowan4gsdevkit is standard; issue_917 is for dev
export rowanv3Branch=rowan4gsdevkit
export rowanv3Branch=issue_917

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
export scriptDir=`dirname "$0"`
# projectsHome is where the $rowan3ProjectName is located
export projectsHome=$registryHome/stones/$todeStoneName/projectsHome
# devKitHome is where the github projects are cloned
export devKitHome=$registryHome/devKit

# make the Rowan4GsDevKit/bin scripts available
export PATH=$scriptDir/../bin:$PATH

# set up the _stones structure and create a standard tODE stone
$scriptDir/test_generate-prepare.sh $*

cd $STONES_HOME/$registry/stones/$todeStoneName
snapshot.stone snapshots --extension=prepared_tode.dbf

# load the managed projects at this point
# proper filetree install of Zinc and GsApplicationTools  
#		at this point ...Zinc and GsApplicationTools are pure github: projects and need to be  filetree projects
#
# load any additional projects that you want to manage
#

cd $registryHome/stones/$todeStoneName

# load Seaside as the managed project
metacelloLoad.stone --project=Seaside3 --repoPath=repository --projectDirectory=$devKitHome/Seaside Welcome Development Examples $*

metacelloLoad.stone --project=ZincHTTPComponents --repoPath=repository --projectDirectory=$devKitHome/zinc $*

# load AFTER zinc, because zinc requires github: variant of gsApplicationTools and incoming wins ... need filetree to win for generate step
metacelloLoad.stone --project=GsApplicationTools --repoPath=repository --projectDirectory=$devKitHome/gsApplicationTools $*

snapshot.stone snapshots --extension=generated_tode.dbf

# generate the base rowan project
export rowan3ProjectName=tode_rowan3
$scriptDir/test_generate-generate.sh $*

# generate the managed rowan project
export rowan3ProjectName=managed_rowan3
$scriptDir/test_managed-generate.sh $*

cd $STONES_HOME/$registry/stones/$rowan3StoneName
snapshot.stone snapshots --extension="$rowan3ProjectName.dbf" $*

echo "***** FINISHED -- master_gsApplicationTools_seaside_zinc.sh *****"
