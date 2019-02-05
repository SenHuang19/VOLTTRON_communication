FROM ubuntu

USER root
ENV VOLTTRON_GIT_BRANCH=master
ENV VOLTTRON_USER_HOME=/home/volttron
ENV VOLTTRON_HOME=${VOLTTRON_USER_HOME}/.volttron
ENV VOLTTRON_ROOT=/code/volttron
ENV VOLTTRON_USER=volttron
ENV TERM xterm

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    default-jre \
    python-dev \
    python-setuptools \
    openssl \
    libssl-dev \
    libevent-dev \
    python-pip \
    git \
    gnupg \
    dirmngr \
    && pip install PyYAML \
    && rm -rf /var/lib/apt/lists/*

# This is not ideal. The tarballs are not named nicely and EnergyPlus versioning is strange
ENV ENERGYPLUS_VERSION 8.5.0
ENV ENERGYPLUS_TAG v8.5.0
ENV ENERGYPLUS_SHA c87e61b44b

# This should be x.y.z, but EnergyPlus convention is x-y-z
ENV ENERGYPLUS_INSTALL_VERSION 8-5-0

# Downloading from Github
# e.g. https://github.com/NREL/EnergyPlus/releases/download/v8.4.0-Update1/EnergyPlus-8.4.0-09f5359d8a-Linux-x86_64.sh
ENV ENERGYPLUS_DOWNLOAD_BASE_URL https://github.com/NREL/EnergyPlus/releases/download/$ENERGYPLUS_TAG
ENV ENERGYPLUS_DOWNLOAD_FILENAME EnergyPlus-$ENERGYPLUS_VERSION-$ENERGYPLUS_SHA-Linux-x86_64.sh
ENV ENERGYPLUS_DOWNLOAD_URL $ENERGYPLUS_DOWNLOAD_BASE_URL/$ENERGYPLUS_DOWNLOAD_FILENAME

# Collapse the update of packages, download and installation into one command
# to make the container smaller & remove a bunch of the auxiliary apps/files
# that are not needed in the container

RUN apt-get update && apt-get install -y ca-certificates curl git \
    && rm -rf /var/lib/apt/lists/* \
    && curl -SLO $ENERGYPLUS_DOWNLOAD_URL \
    && chmod +x $ENERGYPLUS_DOWNLOAD_FILENAME \
    && echo "y\r" | ./$ENERGYPLUS_DOWNLOAD_FILENAME \
    && rm $ENERGYPLUS_DOWNLOAD_FILENAME \
    && cd /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION \
    && rm -rf DataSets Documentation ExampleFiles WeatherData MacroDataSets PostProcess/convertESOMTRpgm \
    PostProcess/EP-Compare PreProcess/FMUParser PreProcess/ParametricPreProcessor PreProcess/IDFVersionUpdater

# Remove the broken symlinks
RUN cd /usr/local/bin \
    && find -L . -type l -delete

# Add a symbolink to Energy+.idd
RUN ["ln", "-s", "/usr/local/EnergyPlus-8-5-0/Energy+.idd", "/usr/local/Energy+.idd"]
RUN adduser $VOLTTRON_USER
WORKDIR ${VOLTTRON_USER_HOME}
RUN git clone https://github.com/VOLTTRON/volttron -b ${VOLTTRON_GIT_BRANCH}
COPY source/upgrade-energyplus ./volttron/
RUN chmod 755 ./volttron/upgrade-energyplus
COPY source/upgrade-control ./volttron/
RUN chmod 755 ./volttron/upgrade-control
COPY source/upgrade-listener ./volttron/
RUN chmod 755 ./volttron/upgrade-listener

RUN chown $VOLTTRON_USER.$VOLTTRON_USER ./volttron

USER $VOLTTRON_USER

WORKDIR ${VOLTTRON_USER_HOME}/volttron
RUN ls -la
RUN python bootstrap.py
COPY source/pnnl ./pnnl
COPY source/ControlAgent ./ControlAgent
COPY source/bcvtb ./bcvtb
COPY source/eplus ./eplus
COPY source/ep.config ./
COPY source/pubsub ./volttron/platform/pubsub


RUN mkdir ../.volttron
COPY source/keystore ../.volttron/
COPY source/auth.json ../.volttron/
COPY source/config ../.volttron/
COPY source/run.sh ./
USER root
RUN chown $VOLTTRON_USER.$VOLTTRON_USER ./eplus
RUN chmod 755 ./run.sh
RUN chown $VOLTTRON_USER.$VOLTTRON_USER ../.volttron/keystore
RUN chown $VOLTTRON_USER.$VOLTTRON_USER ../.volttron/auth.json
RUN chown $VOLTTRON_USER.$VOLTTRON_USER ../.volttron/config
RUN chmod 755 ./run.sh

USER $VOLTTRON_USER