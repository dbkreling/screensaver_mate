#!/bin/bash
#
# This script generates an .xml file for screensaver presentations
# Usage: 
# ./generate_presentation.sh -d <directory-with-pictures>
#
# Author: Daniel Kreling <kreling@linux.vnet.ibm.com>

# Argument = -d pictures directory -c clean directory -m more info -h help

PIXDIR=
CLDIR=
URL=
usage(){
cat << EOF
$0 : missing file operand
Try '$0 -h' for more information.
EOF
}

clean() {
rm $1/*.xml
rm $2
}

# Create an entry on the screensaver UI
create_entry() {
cat << EOF > $URL
[Desktop Entry]
Name=$PIXDIR
Exec=/usr/lib/mate-screensaver/slideshow --location=/usr/share/backgrounds/$PIXDIR
TryExec=/usr/lib/mate-screensaver/slideshow
StartupNotify=false
Terminal=false
Type=Application
Categories=Screensaver;
Keywords=MATE;screensaver;slideshow;$PIXDIR;
OnlyShowIn=MATE;
EOF
}
while getopts “hd:c:m” OPTION
do
	case $OPTION in
	h)
		cat <<EOF
Usage: ./generate_presentation.sh OPTION [directory-with-pictures]

OPTIONS:
   -h      Show this message
   -d      Directory with your images
   -m	   More information about the script
   -c	   Clean and remove the generated data files only (Preserve pictures)
EOF
		exit 1
		;;
	d)
		PIXDIR=$OPTARG
		URL=/usr/share/applications/screensavers/$PIXDIR-slideshow.desktop
		create_entry $PIXDIR $URL
		;;
	m)
		cat << EOF
$0 Description: This script creates an .xml file to create a screensaver presentation with the
pictures you have on a directory.
EOF
		exit 1
		;;
	c)
		CLDIR=$OPTARG
		URL=/usr/share/applications/screensavers/$CLDIR-slideshow.desktop
		clean $CLDIR $URL
		;;
	esac
done

if [[ -z $PIXDIR ]] && [[ -z $CLDIR ]]; then
     usage
     exit 1
fi
# Reference to getopts usage:
# https://rsalveti.wordpress.com/2007/04/03/bash-parsing-arguments-with-getopts/

pictures_aux="ls $PIXDIR | grep .jp"
pic1aux="ls $PIXDIR | grep .jp | head -n 1"
pic1=$(eval $pic1aux)
declare -a pictures=($(eval $pictures_aux))

if [[ -f $PIXDIR/*.xml ]]; then
	rm $PIXDIR/*.xml
fi

cat << EOF > $PIXDIR/background-2.xml
<background>
  <starttime>
    <year>2009</year>
    <month>08</month>
    <day>04</day>
    <hour>00</hour>
    <minute>00</minute>
    <second>00</second>
  </starttime>
<!-- This animation will start at midnight. -->
  <static>
    <duration>1795.0</duration>
    <file>$PWD/$pic1</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>$PWD/$pic1</from>
EOF

for (( c=1; c<=${#pictures[@]}-1; c++ )); do
cat <<EOF >> $PIXDIR/background-2.xml
    <to>$PWD/${pictures[$c]}</to>
  </transition>
  <static>
    <duration>1795.0</duration>
    <file>$PWD/${pictures[$c]}</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>$PWD/${pictures[$c]}</from>
EOF
done

cat <<EOF >> $PIXDIR/background-2.xml
    <to>$PWD/$pic1</to>
  </transition>
</background>
EOF

