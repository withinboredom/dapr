FROM ubuntu:latest AS grpc-sources
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get install -y git
ARG GRPC_VERSION=v1.36.0
WORKDIR /
RUN git clone -b $GRPC_VERSION https://github.com/grpc/grpc
WORKDIR /grpc
RUN git submodule update --init

FROM grpc-sources AS grpc-builder
RUN apt-get install -y build-essential autoconf libtool pkg-config cmake
ENV CC=gcc
RUN mkdir -p cmake/build
WORKDIR /grpc/cmake/build
RUN cmake ../.. -DBUILD_SHARED_LIBS=ON -DgRPC_INSTALL=ON -DCMAKE_BUILD_TYPE=Release
RUN make -j$(nproc)
RUN mkdir -p /libgpr
RUN make DESTDIR=/libgpr install

FROM ubuntu:latest AS ubuntu-grpc
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get install -y git
COPY --from=grpc-builder /libgpr /
COPY --from=grpc-builder /grpc/third_party/protobuf/src /protobuf
RUN ldconfig && protoc --version

FROM ubuntu-grpc AS dapr-protobuf-builder
WORKDIR /
COPY . /dapr
WORKDIR /dapr
ARG LANG
ARG FILE
RUN mkdir -p /out
RUN protoc --proto_path=. --proto_path=/protobuf --${LANG}_out=/out --grpc_out=/out \
    --plugin=protoc-gen-grpc=/usr/local/bin/grpc_${LANG}_plugin \
    $FILE

FROM scratch AS proto-gen
COPY --from=dapr-protobuf-builder /out /