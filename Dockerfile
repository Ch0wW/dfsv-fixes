FROM debian:bookworm-slim

# 1) Since Q3DF's GameDLL uses x86, we need to enable support for i386. 
RUN dpkg --add-architecture i386

# 2) Update the list & install most required packages
RUN apt-get update && apt-get install -y wget gnupg unionfs-fuse lsb-release inetutils-tools
RUN apt-get install -y libxml2:i386 

# 3) Create user for the folder /server that'll be used later
RUN groupadd -r q3df
RUN useradd --no-log-init --system --create-home --home-dir /server --gid q3df q3df

# 4) Install libmysqlclient20 (important for modules)
COPY .install/libmysqlclient20_5.7.21-1ubuntu1_i386.deb /server
RUN dpkg --unpack /server/libmysqlclient20_5.7.21-1ubuntu1_i386.deb
RUN rm /server/libmysqlclient20_5.7.21-1ubuntu1_i386.deb

# 5) Now work on the folder...
USER q3df
RUN mkdir -p /server/baseq3
RUN mkdir /tmp/defraginstall
WORKDIR /tmp/defraginstall

# 6) Install Quake3's basefolder & oDFe
RUN wget https://dl.defrag.racing/downloads/dfsv.tar
RUN tar -xvf dfsv.tar
RUN mv dfsv/*.dat /server/
RUN mv dfsv/baseq3/* /server/baseq3

# 7) Get latest oDFe build from defrag racing
RUN wget https://dl.defrag.racing/downloads/oDFe.ded
RUN mv oDFe.ded /server/
RUN chmod +x /server/oDFe.ded

# 8) Now delete /tmp/defraginstall
RUN rm -rf /tmp/defraginstall

# 9) Copy the start script and the initial maps for DF
COPY game/start.sh /server/start.sh

COPY game/baseq3/amt-freestyle6.pk3 /server/baseq3/
COPY game/baseq3/ojdf-sa.pk3 /server/baseq3/
COPY game/baseq3/st1.pk3 /server/baseq3/

ENV TERM xterm
ENTRYPOINT ["./start.sh"]