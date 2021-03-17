FROM golang:alpine AS build-env

# Set up dependencies
ENV PACKAGES git build-base

# Set working directory for the build
WORKDIR /go/src/github.com/Khaos-Labs/tkchain

# Install dependencies
RUN apk add --update $PACKAGES
RUN apk add linux-headers

# Add source files
COPY . .

# Make the binary
RUN make build

# Final image
FROM alpine

# Install ca-certificates
RUN apk add --update ca-certificates jq
WORKDIR /root

# Copy over binaries from the build-env
COPY --from=build-env /go/src/github.com/Khaos-Labs/tkchain/build/tkchaind /usr/bin/tkchaind
COPY --from=build-env /go/src/github.com/Khaos-Labs/tkchain/build/tkchaincli /usr/bin/tkchaincli

# Run tkchaind by default
CMD ["tkchaind"]
