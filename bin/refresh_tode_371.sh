#
# run me in the stone directory
#

set -e
if [ "$1"x = "x" ]; then
	echo "expect name of stone to be first argument of script"
stoneName=$1

newExtent.solo -r tode $stoneName -e product/bin/extent0.seaside.dbf
startNetldi.solo
loadTode.stone --projectDirectory=$STONES_HOME/tode/devkit
