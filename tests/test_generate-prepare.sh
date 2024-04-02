#! /usr/bin/env bash
#
# sample script for setting up a Rowan4GsDevKit dev environment
#		
set -xe

echo "***** test_generate-prepare.sh *****"

createRegistry.solo $registry --ensure

createProjectSet.solo --registry=$registry --projectSet=$devKitProjectSet \
  --from=$GSDEVKIT_STONES_ROOT/projectSets/$urlType/devkit.ston $*

createProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
  --from=$GSDEVKIT_STONES_ROOT/projectSets/$urlType/devkit.ston $*
#
# standard GsDevKit projects, plus:
# ----- loaded into Pharo 11
if [ "$urlType" = "https" ]; then # use https urls
	JadeiteForPharoUrl="https://github.com/GemTalk/JadeiteForPharo.git"
	PharoGemStoneFFIUrl="https://github.com/GemTalk/PharoGemStoneFFI.git"
	RemoteServiceReplicationUrl="https://github.com/GemTalk/RemoteServiceReplication.git"
	RowanUrl="https://github.com/GemTalk/Rowan.git"
	AnnouncementsUrl="https://github.com/GemTalk/Announcements.git"
	FileSystemGsUrl="https://github.com/GemTalk/FileSystemGs.git"
	RowanClientServicesUrl="https://github.com/GemTalk/RowanClientServices.git"
	GlassUrl="https://github.com/glassdb/glass.git"
	SportUrl="https://github.com/GsDevKit/Sport.git"
else # use ssh urls
	JadeiteForPharoUrl="git@github.com:GemTalk/JadeiteForPharo.git"
	PharoGemStoneFFIUrl="git@github.com:GemTalk/PharoGemStoneFFI.git"
	RemoteServiceReplicationUrl="git@github.com:GemTalk/RemoteServiceReplication.git"
	RowanUrl="git@github.com:GemTalk/Rowan.git"
	AnnouncementsUrl="git@github.com:GemTalk/Announcements.git"
	FileSystemGsUrl="git@github.com:GemTalk/FileSystemGs.git"
	RowanClientServicesUrl="git@github.com:GemTalk/RowanClientServices.git"
	GlassUrl="git@github.com:glassdb/glass.git"
	SportUrl="git@github.com:GsDevKit/Sport.git"
fi
# 	JadeiteForPharo:main								-- Pharo code base for JfP
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=JadeiteForPharo --gitUrl=$JadeiteForPharoUrl \
	--revision=main $*
#		PharoGemStoneFFI:main								-- GemStone server login support
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=PharoGemStoneFFI --gitUrl=$PharoGemStoneFFIUrl\
	--revision=main $*
#		RemoteServiceReplication:main				-- client/server object sharing
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=RemoteServiceReplication --gitUrl=$RemoteServiceReplicationUrl\
	--revision=main $*
# ----- loaded into GemStone $GS_VERS extent0.rowan3.dbf
# 	Rowan:issue_917 										-- bugfixes needed to load GsDevKit projects	(Rowan 3 working branch)
#		Rowan:rowan4gsdevkit								-- features needed to load GsDevKit projects	(Rowan 3 tested and ready for others)
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=Rowan --gitUrl=$RowanUrl \
	--dirName=RowanV3 --revision=$rowanv3Branch $*
#		Announcements:main									-- RemoteServiceReplication support
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=Announcements --gitUrl=$AnnouncementsUrl \
	--revision=main $*
#		FileSystemGs:gs-3.7.x								-- GemStone base support
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=FileSystemGs --gitUrl=$FileSystemGsUrl \
	--revision=gs-3.7.x $*
#		RowanClientServices:ericV3.0_pharo	-- GemStone code base for JfP
#		RowanClientServices:rowan4gsdevkit	-- Rowan4GsDevKit specific changes
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=RowanClientServices --gitUrl=$RowanClientServicesUrl \
	--dirName=RowanClientServicesV3 --revision=rowan4gsdevkit $*
#	----- GsDevKit projects with special version requirements
#		glass:rowan4gsdevkit								-- modifications required to preserve Rowan 3 functionality
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=glass --gitUrl=$GlassUrl \
	--revision=rowan4gsdevkit $*
#		Sport:master												-- provide Sport class definitions without cracking an .mcz file
updateProjectSet.solo --registry=$registry --projectSet=$rowan3ProjectSet \
	--projectName=Sport --gitUrl=$SportUrl \
	--revision=master $*

if [ -d "$STONES_HOME/devKit" ] ; then
	if [ ! -d $registryHome ] ; then
		mkdir $registryHome
	fi
	ln -s $STONES_HOME/devKit $devKitHome
fi

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

# enable download when $GS_VERS ships
downloadGemStone.solo --registry=$registry $GS_VERS $*

# update product list from shared product directory when a download is done by shared registry
registerProduct.solo --registry=$registry --fromDirectory=$STONES_HOME/test_gemstone $*

# create/update clientLibs directory for use by JadeiteForPharo
updateClientLibs.solo -r $registry $GS_VERS

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


echo "***** FINISHED - test_generate-prepare.sh *****"

