#!/bin/bash

KEY="tkchain-mainnet-bxlkm"
CHAINID="tkchain-65"
MONIKER="tkchain-mainnet-1"

# remove existing daemon and client
rm -rf ~/.tkchain*

if [[ "$(uname)" == "Darwin" ]]; then
    # Do something under Mac OS X platform
    # macOS 10.15
    LDFLAGS="" make install
else
    make install
fi

tkchaincli config keyring-backend test

# Set up config for CLI
tkchaincli config chain-id $CHAINID
tkchaincli config output json
tkchaincli config indent true
tkchaincli config trust-node true

# if $KEY exists it should be deleted
tkchaincli keys add $KEY

# Set moniker and chain-id for Tkchain (Moniker can be anything, chain-id must be an integer)
tkchaind init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to tkb
cat $HOME/.tkchaind/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="tkb"' > $HOME/.tkchaind/config/tmp_genesis.json && mv $HOME/.tkchaind/config/tmp_genesis.json $HOME/.tkchaind/config/genesis.json
cat $HOME/.tkchaind/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="tkb"' > $HOME/.tkchaind/config/tmp_genesis.json && mv $HOME/.tkchaind/config/tmp_genesis.json $HOME/.tkchaind/config/genesis.json
cat $HOME/.tkchaind/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="tkb"' > $HOME/.tkchaind/config/tmp_genesis.json && mv $HOME/.tkchaind/config/tmp_genesis.json $HOME/.tkchaind/config/genesis.json
cat $HOME/.tkchaind/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="tkb"' > $HOME/.tkchaind/config/tmp_genesis.json && mv $HOME/.tkchaind/config/tmp_genesis.json $HOME/.tkchaind/config/genesis.json

# increase block time (?)
cat $HOME/.tkchaind/config/genesis.json | jq '.consensus_params["block"]["time_iota_ms"]="30000"' > $HOME/.tkchaind/config/tmp_genesis.json && mv $HOME/.tkchaind/config/tmp_genesis.json $HOME/.tkchaind/config/genesis.json

if [[ $1 == "pending" ]]; then
    echo "pending mode on; block times will be set to 30s."
    # sed -i 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.tkchaind/config/config.toml
    sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.tkchaind/config/config.toml
    sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.tkchaind/config/config.toml
    sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.tkchaind/config/config.toml
    sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.tkchaind/config/config.toml
    sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.tkchaind/config/config.toml
    sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.tkchaind/config/config.toml
    sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.tkchaind/config/config.toml
fi

# Allocate genesis accounts (cosmos formatted addresses)
tkchaind add-genesis-account $(tkchaincli keys show $KEY -a) 100000000000000000000tkb

# Sign genesis transaction
tkchaind gentx --name $KEY --amount=1000000000000000000tkb --keyring-backend test

# Collect genesis tx
tkchaind collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
tkchaind validate-genesis

# Command to run the rest server in a different terminal/window
echo -e '\nrun the following command in a different terminal/window to run the REST server and JSON-RPC:'
echo -e "tkchaincli rest-server --laddr \"tcp://localhost:8545\" --wsport 8546 --unlock-key $KEY --chain-id $CHAINID --trace --rpc-api "web3,eth,net"\n"
tkchaincli keys unsafe-export-eth-key $KEY
# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
tkchaind start --pruning=nothing --rpc.unsafe --log_level "main:info,state:info,mempool:info" --trace
