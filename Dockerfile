FROM pixelmilk/mesos:1.3.1 as build

ARG MARATHON_VERSION
ARG MAINTAINER

ENV VERSION ${MARATHON_VERSION:-1.4.7}
ENV MAINTAINER ${MAINTAINER:-sebastian@katallaxie.me}

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
    sbt -Dsbt.log.format=false assembly && \
    # Move into place
    mv $(find target -name 'marathon-assembly-*.jar' | sort | tail -1) ./ && \
    rm -rf project/target project/project/target plugin-interface/target target/* ~/.sbt ~/.ivy2 && \
    mv marathon-assembly-*.jar target && \
    # Mov to final
    cd .. && \
    mv ${TEMP} /tmp/marathon

FROM pixelmilk/mesos:1.3.1
MAINTAINER Sebastian Doell <sebastian@katallaxie.me>

COPY \
     --from=build /tmp/marathon /

RUN \
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
ENTRYPOINT ["./bin/start"]