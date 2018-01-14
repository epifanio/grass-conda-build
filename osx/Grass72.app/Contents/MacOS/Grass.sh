#! /bin/bash
#############################################################################
#
# MODULE:   	GRASS Initialization
# AUTHOR(S):	Justin Hickey - Thailand - jhickey@hpcc.nectec.or.th
#             William Kyngesburye - kyngchaos@kyngchaos.com
#             Eric Hutton
#             Michael Barton - michael.barton@asu.edu
# PURPOSE:  	The source file for this shell script is in
#   	    	macosx/app/grass.sh.in and is the grass startup script for
#               the Mac OS X application build.
# COPYRIGHT:    (C) 2000-2018 by the GRASS Development Team
#
#               This program is free software under the GNU General Public
#   	    	License (>=v2). Read the file COPYING that comes with GRASS
#   	    	for details.
#
#############################################################################

script_dir=$(dirname "$(dirname "$0")")

# Mac app only startup shell - complete rewrite for starting from a GRASS.app
# in Mac OS X.  Sets defaults for unset env, adds some Mac-only config.

trap "echo 'User break!' ; exit" 2 3 9 15

# dummy for now - just saying we're starting GRASS.app on OSX
export GRASS_OS_STARTUP="Mac.app"

SYSARCH=`uname -p`
SYSVER=`uname -r | cut -d . -f 1`

### change this to dirname/MacOS or dirname/Resources??
### set it this way instead of a direct path

export GISBASE=$script_dir/Resources
grass_ver=`cut -d . -f 1-2 "$GISBASE/etc/VERSIONNUMBER"`

#override config dir.
GRASS_CONFIG_DIR="Library/Preferences/GRASS/$grass_ver"

export GISBASE_USER="$HOME/Library/GRASS/$grass_ver"
export GISBASE_SYSTEM="/Library/GRASS/$grass_ver"

# for extra utils
# ideally user should have these in their PATH, but make sure here
#PATH="/Applications/anaconda/bin:/Applications/anaconda/bin:$PATH"
#export PATH

# add some OS X style app support paths, and create user one if missing.
mkdir -p "$GISBASE_USER/Modules/bin"
mkdir -p "$GISBASE_USER/Modules/scripts"
if [ ! "$GRASS_ADDON_BASE" ] ; then
	GRASS_ADDON_BASE="$GISBASE_USER/Modules"
fi
export GRASS_ADDON_BASE

mkdir -p "$GISBASE_USER/Modules/etc"
addpath="$GISBASE_USER/Modules/etc:$GISBASE_SYSTEM/Modules/etc"
if [ "$GRASS_ADDON_ETC" ] ; then
	GRASS_ADDON_ETC="$GRASS_ADDON_ETC:$addpath"
else
	GRASS_ADDON_ETC="$addpath"
fi
export GRASS_ADDON_ETC

mkdir -p "$GISBASE_USER/Modules/lib"
mkdir -p "$GISBASE_USER/Modules/docs/html"

# rebuild addon html index and gui menus
"$GISBASE/etc/build_html_user_index.sh" "$GISBASE"
"$GISBASE/etc/build_gui_user_menu.sh"

# user fontcap files
if [ ! "$GRASS_FONT_CAP" ] ; then
	GRASS_FONT_CAP="$GISBASE_USER/Modules/etc/fontcap"
fi
export GRASS_FONT_CAP

### replaced all the prior code for finding Python and wxPython
export GRASS_PYTHON="$GISBASE/bin/pythonw"
export GRASS_PYTHONWX="$GISBASE/bin/pythonw"

# use the python wrapper to start grass
"$GISBASE/bin/python" "$GISBASE/bin/grass72" "-gui" "$@"
