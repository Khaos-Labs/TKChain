FROM golang:stretch as build-env

# Install minimum necessary dependencies
ENV PACKAGES curl make git libc-dev bash gcc
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y $PACKAGES

# Set working directory for the build
WORKDIR /go/src/github.com/Khaos-Labs/tkchain

# Add source files
COPY . .

# build Tkchain
RUN make build-tkchain-linux

# Final image
FROM golang:1.14 as final

WORKDIR /

RUN apt-get update

# Copy over binaries from the build-env
COPY --from=build-env /go/src/github.com/Khaos-Labs/tkchain/build/tkchaind /usr/bin/tkchaind
COPY --from=build-env /go/src/github.com/Khaos-Labs/tkchain/build/tkchaincli /usr/bin/tkchaincli
COPY --from=build-env /go/src/github.com/Khaos-Labs/tkchain/scripts/start.sh /

EXPOSE 26656 26657 1317 8545 8546

# Run tkchaind by default, omit entrypoint to ease using container with tkchaincli
ENTRYPOINT ["/bin/bash", "-c"]