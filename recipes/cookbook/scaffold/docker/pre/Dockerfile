FROM simverse/runtime:local as simverse_runtime_pre

USER simnet

WORKDIR /home/simnet

COPY "docker/pre/home" "/home/simnet/"

# replace symlink with actual target lib files
RUN rm lib
COPY "docker/_aux/runtime/lib" "/home/simnet/lib"

RUN mkdir certs
