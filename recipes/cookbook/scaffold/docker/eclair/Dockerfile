# this file is modelled after https://github.com/ACINQ/eclair/blob/master/Dockerfile

FROM simverse/buildtime:local as simverse_buildtime_eclair

# -- install JDK ------------------------------------------------------------------------------------------------------------
# from https://github.com/docker-library/openjdk/blob/master/8/jdk/alpine/Dockerfile

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u212
ENV JAVA_ALPINE_VERSION 8.212.04-r0

RUN set -x \
	&& apk add --no-cache \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

# ^^ install JDK ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ARG ECLAIR_REPO_PATH

# Setup maven, we don't use https://hub.docker.com/_/maven/ as it declare .m2 as volume, we loose all mvn cache
# We can alternatively do as proposed by https://github.com/carlossg/docker-maven#packaging-a-local-repository-with-the-image
# this was meant to make the image smaller, but we use multi-stage build so we don't care

RUN apk add --no-cache curl tar bash

ARG MAVEN_VERSION=3.6.0
ARG USER_HOME_DIR="/root"
ARG SHA=6a1b346af36a1f1a491c1c1a141667c5de69b42e6611d3687df26868bc0f4637
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# Let's fetch eclair dependencies, so that Docker can cache them
# This way we won't have to fetch dependencies again if only the source code changes
# The easiest way to reliably get dependencies is to build the project with no sources
WORKDIR /root/build
COPY "$ECLAIR_REPO_PATH/pom.xml" pom.xml
COPY "$ECLAIR_REPO_PATH/eclair-core/pom.xml" eclair-core/pom.xml
COPY "$ECLAIR_REPO_PATH/eclair-node/pom.xml" eclair-node/pom.xml
COPY "$ECLAIR_REPO_PATH/eclair-node-gui/pom.xml" eclair-node-gui/pom.xml
RUN mkdir -p eclair-core/src/main/scala && touch eclair-core/src/main/scala/empty.scala
# Blank build. We only care about eclair-node, and we use install because eclair-node depends on eclair-core
RUN mvn install -pl eclair-node -am
RUN mvn clean

# Only then do we copy the sources
COPY "$ECLAIR_REPO_PATH" .

# And this time we can build in offline mode, specifying 'notag' instead of git commit
RUN mvn package -pl eclair-node -am -DskipTests -Dgit.commit.id=notag -Dgit.commit.id.abbrev=notag -o
# It might be good idea to run the tests here, so that the docker build fail if the code is bugged

# ---------------------------------------------------------------------------------------------------------------------------

FROM simverse/runtime:local as simverse_runtime_eclair

# -- install JRE ------------------------------------------------------------------------------------------------------------
# from https://github.com/AdoptOpenJDK/openjdk-docker/blob/master/11/jdk/alpine/Dockerfile.openj9.releases.full

# LABEL maintainer="dinakar.g@in.ibm.com"

RUN apk add --no-cache --virtual .build-deps curl binutils \
    && GLIBC_VER="2.29-r0" \
    && ALPINE_GLIBC_REPO="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
    && GCC_LIBS_URL="https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-8.2.1%2B20180831-1-x86_64.pkg.tar.xz" \
    && GCC_LIBS_SHA256=e4b39fb1f5957c5aab5c2ce0c46e03d30426f3b94b9992b009d417ff2d56af4d \
    && ZLIB_URL="https://archive.archlinux.org/packages/z/zlib/zlib-1%3A1.2.11-3-x86_64.pkg.tar.xz" \
    && ZLIB_SHA256=17aede0b9f8baa789c5aa3f358fbf8c68a5f1228c5e6cba1a5dd34102ef4d4e5 \
    && curl -Ls https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && SGERRAND_RSA_SHA256="823b54589c93b02497f1ba4dc622eaef9c813e6b0f0ebbb2f771e32adf9f4ef2" \
    && echo "${SGERRAND_RSA_SHA256}  /etc/apk/keys/sgerrand.rsa.pub" | sha256sum -c - \
    && curl -Ls ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-${GLIBC_VER}.apk > /tmp/${GLIBC_VER}.apk \
    && apk add /tmp/${GLIBC_VER}.apk \
    && curl -Ls ${GCC_LIBS_URL} -o /tmp/gcc-libs.tar.xz \
    && echo "${GCC_LIBS_SHA256}  /tmp/gcc-libs.tar.xz" | sha256sum -c - \
    && mkdir /tmp/gcc \
    && tar -xf /tmp/gcc-libs.tar.xz -C /tmp/gcc \
    && mv /tmp/gcc/usr/lib/libgcc* /tmp/gcc/usr/lib/libstdc++* /usr/glibc-compat/lib \
    && strip /usr/glibc-compat/lib/libgcc_s.so.* /usr/glibc-compat/lib/libstdc++.so* \
    && curl -Ls ${ZLIB_URL} -o /tmp/libz.tar.xz \
    && echo "${ZLIB_SHA256}  /tmp/libz.tar.xz" | sha256sum -c - \
    && mkdir /tmp/libz \
    && tar -xf /tmp/libz.tar.xz -C /tmp/libz \
    && mv /tmp/libz/usr/lib/libz.so* /usr/glibc-compat/lib \
    && apk del --purge .build-deps \
    && rm -rf /tmp/${GLIBC_VER}.apk /tmp/gcc /tmp/gcc-libs.tar.xz /tmp/libz /tmp/libz.tar.xz /var/cache/apk/*

ENV JAVA_VERSION jdk-11.0.3+7_openj9-0.14.0

RUN set -eux; \
    apk add --virtual .fetch-deps curl; \
    ARCH="$(apk --print-arch)"; \
    case "${ARCH}" in \
       ppc64el|ppc64le) \
         ESUM='ad641f456258c6a77d07edfdc0ee6cddcaa53b9eb71df517f1074f7602f53832'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.3%2B7_openj9-0.14.0/OpenJDK11U-jdk_ppc64le_linux_openj9_11.0.3_7_openj9-0.14.0.tar.gz'; \
         ;; \
       s390x) \
         ESUM='ff7bb0e44418af84dd96a72c1e55b0f1f69a4a1838f929b36c7d005b3dfe29a9'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.3%2B7_openj9-0.14.0/OpenJDK11U-jdk_s390x_linux_openj9_11.0.3_7_openj9-0.14.0.tar.gz'; \
         ;; \
       amd64|x86_64) \
         ESUM='7012edd56fc958070bc4747073de14ea08eb43081eb6ea19bdbf4763186e2d17'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.3%2B7_openj9-0.14.0/OpenJDK11U-jdk_x64_linux_openj9_11.0.3_7_openj9-0.14.0.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -Lso /tmp/openjdk.tar.gz ${BINARY_URL}; \
    sha256sum /tmp/openjdk.tar.gz; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    echo "${ESUM}  /tmp/openjdk.tar.gz" | sha256sum -c -; \
    tar -xf /tmp/openjdk.tar.gz; \
    jdir=$(dirname $(dirname $(find /opt/java/openjdk -name java | grep -v "/jre/bin"))); \
    mv ${jdir}/* /opt/java/openjdk; \
    apk del --purge .fetch-deps; \
    rm -rf /var/cache/apk/*; \
    rm -rf ${jdir} /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"
ENV JAVA_TOOL_OPTIONS="-XX:+IgnoreUnrecognizedVMOptions -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle"

# ^^ install JRE ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

RUN apk add --no-cache --update \
gmp-dev

ARG ECLAIR_CONF_PATH

# copy build artefacts...
COPY --from=simverse_buildtime_eclair /root/build/eclair-node/target/eclair-node-*.jar .
RUN mv eclair-node-*.jar eclair-node.jar
COPY --from=simverse_buildtime_eclair /root/build/eclair-core/eclair-cli .
RUN chmod +x eclair-cli

USER simnet

WORKDIR /home/simnet

COPY "docker/eclair/home" "/home/simnet/"

# replace symlink with actual target lib files
RUN rm lib
COPY "docker/_aux/runtime/lib" "/home/simnet/lib"

COPY "$ECLAIR_CONF_PATH" "/home/simnet/seed-eclair.conf"

RUN mkdir .eclair