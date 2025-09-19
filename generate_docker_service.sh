#!/bin/bash

if [[ $EUID -eq 0 ]]; then
    echo "This script should NOT be run as root !!"
    exit 1
fi

installdir=$(pwd)
echo "Creating the required folders within $installdir ..."
basedir="$installdir/game"
tmpdir="/tmp/defraginstall"

mkdir -p $tmpdir
cd $tmpdir

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

echo "Generating docker-compose file"
COUNTER=0
source sv.conf
echo "Checking sv.conf for required settings..."
for CONFIGURABLE in SV_BASE_HOSTNAME SV_RCON SV_LOCATION ADMIN_NAME; do
	if [[ "${!CONFIGURABLE}" = "" ]]
	then
		read -p "Enter $CONFIGURABLE: " $CONFIGURABLE
	fi
done
printf "\nServer Hostname: $SV_BASE_HOSTNAME\nAdmin: $ADMIN_NAME\nRcon Password: $SV_RCON\nServer Location: $SV_LOCATION\n\n"

echo "Generating docker compose file"
curr_port=27960
rm -rf docker-compose.override.yml &>/dev/null
printf 'services:' > docker-compose.override.yml 2>&1
for sv_type in mixed cpm vq3 fastcaps teamruns freestyle;do
	i=0
	sv_qty="${sv_type}_count"
        sv_sfx="${sv_type}_sfx"
	while [[ $i -ne "${!sv_qty}" ]]
	do
	  curr_id="rs${curr_port}"
		i=$(($i+1))
		curr_name="${sv_type}_${i}"
		curr_hostname="${SV_BASE_HOSTNAME} ${!sv_sfx} ${i}"
		printf "
  ${curr_name}:
    image: q3df
    container_name: ${curr_name}
    network_mode: host
    user: \"$(id -u):$(id -g)\"
    volumes:
      - base:/server/defrag/
      - maps:/server/nfs/maps/
      - ./game/.q3a/://.q3a/
    restart: always
    environment:
      - MDD_ENABLED=${MDD_ENABLED}
      - RS_ID=${!curr_id}
      - NAME_ID=${curr_name}
      - SV_TYPE=${sv_type}
      - SV_HOSTNAME=${curr_hostname}
      - SV_RCON=${SV_RCON}
      - SV_LOCATION=${SV_LOCATION}
      - SV_PORT=${curr_port}
      - ADMIN_NAME=${ADMIN_NAME}
      - ADMIN_MAIL=${ADMIN_MAIL}
      - ADMIN_DISCORD=${ADMIN_DISCORD}
      - ADMIN_IRC=${ADMIN_IRC}
      - SV_MAPBASE=${SV_MAPBASE}
      - SV_HOMEPAGE=${SV_HOMEPAGE}
      - SV_PRIVATE=${SV_PRIVATE}
      - SV_PASSWORD=${SV_PASSWORD}" >> docker-compose.override.yml 2>&1
	sudo mkdir game/defrag/$curr_name &>/dev/null
	#sudo cp cfgs/${sv_type}.cfg servers/base/defrag/$curr_name/main.cfg
        curr_port=$(($curr_port+1))
	done
done