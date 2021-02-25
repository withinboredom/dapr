## Overview

| packages  | description                                                            |
|-----------|------------------------------------------------------------------------|
| common    | common protos that are imported by multiple packages                   |
| internals | internal gRPC and protobuf definitions which is used for Dapr internal |
| runtime   | Dapr and App Callback services and its associated protobuf messages    |
| operator  | Dapr Operator gRPC service                                             |
| placement | Dapr Placement service                                                 |
| sentry    | Dapr Sentry for CA service                                             |

## Proto client generation

1. Install protoc version: [v3.14.0](https://github.com/protocolbuffers/protobuf/releases/tag/v3.14.0)

2. Install protoc-gen-go and protoc-gen-go-grpc

```bash
make init-proto
```

3. Generate gRPC proto clients


```bash
make gen-proto
```

### Using Docker for other languages

1. In a terminal, navigate to the root of the repo

```bash
DOCKER_BUILDKIT=1 docker build --target proto-gen -f dapr/proto-gen.Dockerfile \
    --build-arg GRPC_VERSION=v1.36.0 \
    --build-arg LANG=<cpp|csharp|node|php|python|ruby> \
    --build-arg FILE=<path to .proto file from root of repo> \
    --output directory/to/copy/generated/files/to \
    .
```

2. After a few moments, the docker image will finish building.
3. The generated files are now in `directory/to/copy/generated/files/to`, it will be created if it doesn't exist.

## Update e2e test apps
Whenever there are breaking changes in the proto files, we need to update the e2e test apps to use the correct version of dapr dependencies. This can be done by navigating to the tests folder and running the commands:-

```
# Use the last commit of dapr.
./update_testapps_dependencies.sh be08e5520173beb93e5d5f047dbde405e78db658
```

**Note**: On Windows, use the mingw tools to execute the bash script

Check in all the go.mod files for the test apps that have now been modified to point to the latest dapr version.