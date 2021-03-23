<!--
parent:
  order: false
-->

<div align="center">
  <h1> Tkchain </h1>
</div>

<div align="center">
  <a href="https://github.com/Khaos-Labs/tkchain/releases/latest">
    <img alt="Version" src="https://img.shields.io/github/tag/Khaos-Labs/tkchain.svg" />
  </a>
  <a href="https://github.com/Khaos-Labs/tkchain/blob/development/LICENSE">
    <img alt="License: Apache-2.0" src="https://img.shields.io/github/license/Khaos-Labs/tkchain.svg" />
  </a>
  <a href="https://pkg.go.dev/github.com/Khaos-Labs/tkchain?tab=doc">
    <img alt="GoDoc" src="https://godoc.org/github.com/Khaos-Labs/tkchain?status.svg" />
  </a>
  <a href="https://goreportcard.com/report/github.com/Khaos-Labs/tkchain">
    <img alt="Go report card" src="https://goreportcard.com/badge/github.com/Khaos-Labs/tkchain"/>
  </a>
  <a href="https://codecov.io/gh/cosmos/ethermint">
    <img alt="Code Coverage" src="https://codecov.io/gh/Khaos-Labs/tkchain/branch/development/graph/badge.svg" />
  </a>
</div>
<div align="center">
  <a href="https://github.com/Khaos-Labs/tkchain">
    <img alt="Lines Of Code" src="https://tokei.rs/b1/github/Khaos-Labs/tkchain" />
  </a>
  <a href="https://discord.gg/AzefAFd">
    <img alt="Discord" src="https://img.shields.io/discord/669268347736686612.svg" />
  </a>
</div>

Tkchain is a scalable, high-throughput Proof-of-Stake blockchain that is fully compatible and
interoperable with Ethereum. It's build using the the [Cosmos SDK](https://github.com/cosmos/cosmos-sdk/) which runs on top of [Tendermint Core](https://github.com/tendermint/tendermint) consensus engine.

> **WARNING:** Tkchain is under VERY ACTIVE DEVELOPMENT and should be treated as pre-alpha software. This means it is not meant to be run in production, its APIs are subject to change without warning and should not be relied upon, and it should not be used to hold any value. We will remove this warning when we have a release that is stable, secure, and properly tested.

**Note**: Requires [Go 1.15+](https://golang.org/dl/)

## Build

Install Go
Install go by following the official docs. Remember to set your $PATH environment variable, for example:https://golang.org/doc/install 

mkdir -p $HOME/go/bin

echo "export PATH=$PATH:$(go env GOPATH)/bin" >> ~/.bash_profile

source ~/.bash_profile

::: tip Go 1.15+ is required for the Cosmos SDK. :::

git clone https://github.com/Khaos-Labs/tkchain.git

cd tkchain && make install

If this command fails due to the following error message, you might have already set LDFLAGS prior to running this step.

github.com/Khaos-Labs/tkchain/cmd/tkchaind

flag provided but not defined: -L

usage: link [options] main.o
...
make: *** [install] Error 2

Unset this environment variable and try again.

LDFLAGS="" make install

NOTE: If you still have issues at this step, please check that you have the latest stable version of GO installed.

That will install the gaiad binary. Verify that everything is OK:

tkchaind version --long

tkchaind for instance should output something similar to:

name: tkchaind
server_name: tkchaind
version: 2.0.3
commit: 2f6783e298f25ff4e12cb84549777053ab88749a
build_tags: netgo,ledger
go: go version go1.12.5 darwin/amd64

## Quick Start

To learn how the Tkchain works from a high-level perspective, go to the [Introduction](./docs/intro/overview.md) section from the documentation.

For more, please refer to the [Tkchain Docs](./docs/), which are also hosted on [docs.tkchain.zone](https://docs.Tkchain.zone/).

## Tests

Unit tests are invoked via:

```bash
make test
```

To run JSON-RPC tests, execute:

```bash
make test-rpc
```

There is also an included Ethereum mainnet exported blockchain file in `importer/blockchain`
that includes blocks up to height `97638`. To execute and test a full import of
these blocks using the EVM module, execute:

```bash
make test-import
```

You may also provide a custom blockchain export file to test importing more blocks
via the `--blockchain` flag. See `TestImportBlocks` for further documentation.

### Community

The following chat channels and forums are a great spot to ask questions about Tkchain:

- [Cosmos Discord](https://discord.gg/W8trcGV)
- [Cosmos Forum](https://forum.cosmos.network)
