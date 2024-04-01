#! /usr/bin/env bash
#
# sample driver script for setting up a tODE stone with projects that will be loaded
#	into a Rowan 3 stone for editting
#		
set -xe
echo "***** master_baseTode.sh *****"

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
# b665ecdff2d46a21c4910934586784230eb922fa (HEAD of issue_917) -conflicts with BaselineOfSeaside3.package/BaselineOfSeaside3.class/properties.json (6 week ago)

# 183ebcf5486d62d6acf864516a59f6e6c7bc2e9d / 508a850cdedc55a4df62cc0c003703b751979240 (reverted b665ecdff2d46a21c4910934586784230eb922fa)  - conflicts with 4-6 years ago
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

# generate the base rowan project
export rowan3ProjectName=base_tode_rowan3
$scriptDir/test_generate-generate.sh $*

cd $STONES_HOME/$registry/stones/$rowan3StoneName
snapshot.stone snapshots --extension="$rowan3ProjectName.dbf" $*

echo "***** FINISHED -- master_baseTode.sh *****"
