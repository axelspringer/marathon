FROM axelspringer/mesos:1.4.1 as build

ARG MARATHON_VERSION
ENV VERSION ${MARATHON_VERSION:-1.5.1}

RUN \
    # Update the packages.
    apt-get -y update && \
    # Install neat tools
    apt-get install -y tar wget git ca-certificates-java && \
    # Install a few utility tools.
    apt-get install -y openjdk-8-jdk && \
    # Install the latest OpenJDK.
    apt-get install -y autoconf libtool && \
    # Install other Mesos dependencies.
    apt-get -y --no-install-recommends install build-essential

RUN \
    # Temp
    export TEMP=$(mktemp -d) && \
    # Change dir
    cd ${TEMP} && \
    # Clone source
    git clone --depth=1 --branch v${MARATHON_VERSION} https://github.com/mesosphere/marathon.git . && \
    # # Get sbt version
    eval $(sed s/sbt.version/SBT_VERSION/ <project/build.properties) && \
    wget -P /usr/local/bin/ http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$SBT_VERSION/sbt-launch.jar && \
    cp project/sbt /usr/local/bin && \
    chmod +x /usr/local/bin/sbt && \
    # Build
    sbt -Dsbt.log.format=false universal:packageZipTarball && \
    # Move into place
    mv $(find target -name 'marathon-*.tgz' | sort | tail -1) /tmp

FROM axelspringer/mesos:1.4.1
MAINTAINER Sebastian Doell <sebastian.doell@axelspringer.de>

ARG MARATHON_VERSION
ENV VERSION ${MARATHON_VERSION:-1.5.1}

COPY \
     --from=build /tmp/marathon-${VERSION}.tgz /tmp

RUN \
    # Extract && delete
    tar --strip-components=1 -xzvf /tmp/marathon-*.tgz -C / && rm -rf /tmp/*.tgz && \
    # Update the packages.
    apt-get -y update && \
    # Install neat tools
    apt-get install -y ca-certificates-java && \
    # jdk setup
    /var/lib/dpkg/info/ca-certificates-java.postinst configure && \
    ln -svT "/usr/lib/jvm/java-8-openjdk-$(dpkg --print-architecture)" /docker-java-home && \
    # clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV JAVA_HOME /docker-java-home
ENTRYPOINT ["./bin/marathon"]