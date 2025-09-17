#!/bin/bash

if [[ $EUID -eq 0 ]]; then
    echo "This script should NOT be run as root !!" 
    exit 1
fi

installdir=$(pwd)
echo "Creating the required folders within $installdir ..."
basedir="$installdir/game"
tmpdir="/tmp/defraginstall"

# Setup the nfs subfolder
mkdir -p $basedir/nfs/maps

echo "Creating a temporary folder in /tmp/defraginstall for downloading assets..."
mkdir -p $tmpdir && cd $tmpdir

# set up server backbone
echo "Downloading the defrag serverpackage from defrag.racing ..."
wget https://dl.defrag.racing/downloads/dfsv.tar
tar -xvf dfsv.tar
mv dfsv/*.dat $basedir/ && mv dfsv/baseq3/* $basedir/baseq3

# get latest defrag engine
echo "Downloading oDFe's binary"
wget https://dl.defrag.racing/downloads/oDFe.ded
mv oDFe.ded $basedir/
chmod +x $basedir/oDFe.ded

# get latest defrag version
echo "Downloading the latest defrag mod-release..."
wget --no-check-certificate $(wget --spider -r --no-parent --no-check-certificate https://q3defrag.org/files/defrag/ 2>&1 | grep -E "\-\-2" | grep "defrag_" | grep -v "beta" | cut -d' ' -f4 | sort | tail -n1)
unzip -o defrag*.zip
mkdir $basedir/defrag/
mv defrag/zz-* $basedir/defrag/

# get recordsystem modules
echo "Downloading the community modules..."
wget https://dl.defrag.racing/downloads/rs.tar
tar -xvf rs.tar

# Move the modules subfolder...
mv rs/defrag/modules $basedir/defrag/ 

# And also the qagame binary.
mv rs/defrag/qagame* $basedir/defrag/qagamei386.so

cd $installdir
rm -rf $tmpdir

echo "Installation done!"
echo "You can now edit sv.conf to your likings, and start start-servers.sh"

exit 0