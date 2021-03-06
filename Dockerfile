FROM debian:8

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  lib32gcc1 \
  wget \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m steam
WORKDIR /home/steam
USER steam

# Install steamcd and cs 1.6
RUN wget -nv https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz

COPY install.txt .
RUN ./steamcmd.sh +runscript install.txt

RUN mkdir -p ~/.steam && ln -s ~/linux32 ~/.steam/sdk32

WORKDIR /home/steam/cs16

# Add metamod
RUN mkdir -p cstrike/addons/metamod/dlls
COPY metamod_i386.so cstrike/addons/metamod/dlls/
COPY metamod.so cstrike/addons/metamod/dlls/

# Add bots
COPY podbot cstrike/addons/podbot
RUN echo "linux addons/podbot/podbot_mm_i386.so" > cstrike/addons/metamod/plugins.ini
COPY liblist.gam cstrike/

# Copy ESL configs
COPY *.cfg cstrike/

# Install aim maps
COPY AimMapCs1.6/cstrike cstrike/

EXPOSE 27015/tcp
EXPOSE 27015/udp

CMD ./hlds_run -game cstrike -strictportbind -autoupdate -ip 0.0.0.0 +sv_lan 1 +map aim_map -maxplayers 32
