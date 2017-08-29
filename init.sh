#!/bin/bash

# change to build
cd /build
# Update the packages.
apt-get -y update
# Install neat tools
apt-get install -y tar wget git ca-certificates-java
# Install a few utility tools.
apt-get install -y openjdk-8-jdk
# Install the latest OpenJDK.
apt-get install -y autoconf libtool
# Install other Mesos dependencies.
apt-get -y --no-install-recommends install build-essential
# Clone source
git clone --depth=1 --branch v${MARATHON_VERSION} https://github.com/mesosphere/marathon.git .
# # Get sbt version
eval $(sed s/sbt.version/SBT_VERSION/ <project/build.properties)
wget -P /usr/local/bin/ http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$SBT_VERSION/sbt-launch.jar
cp project/sbt /usr/local/bin
chmod +x /usr/local/bin/sbt
# Build
sbt -Dsbt.log.format=false assembly
# Move into place
mv $(find target -name 'marathon-assembly-*.jar' | sort | tail -1) ./
rm -rf project/target project/project/target plugin-interface/target target/* ~/.sbt ~/.ivy2
mv marathon-assembly-*.jar target
# Move to final
tar -zcvf marathon-${MARATHON_VERSION}.tar.gz .