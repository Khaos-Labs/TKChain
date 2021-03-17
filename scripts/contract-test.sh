#!/bin/bash

KEY="mykey"
TESTKEY="test"
CHAINID="tkchain-100"
MONIKER="localtestnet"

# stop and remove existing daemon and client data and process(es)
rm -rf $PWD/.tkchain*
pkill -f "tkchain*"

make build-tkchain

$PWD/build/tkchaincli config keyring-backend test

# Set up config for CLI
$PWD/build/tkchaincli config chain-id $CHAINID
$PWD/build/tkchaincli config output json
$PWD/build/tkchaincli config indent true
$PWD/build/tkchaincli config trust-node true

# if $KEY exists it should be deleted
$PWD/build/tkchaincli keys add $KEY

# Set moniker and chain-id for Tkchain (Moniker can be anything, chain-id must be an integer)
$PWD/build/tkchaind init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to aphoton
cat $HOME/.tkchaind/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="aphoton"' > $HOME/.tkchaind/config/tmp_genesis.json && mv $HOME/.tkchaind/config/tmp_genesis.json $HOME/.tkchaind/config/genesis.json
cat $HOME/.tkchaind/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="aphoton"' > $HOME/.tkchaind/config/tmp_genesis.json && mv $HOME/.tkchaind/config/tmp_genesis.json $HOME/.tkchaind/config/genesis.json
cat $HOME/.tkchaind/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="aphoton"' > $HOME/.tkchaind/config/tmp_genesis.json && mv $HOME/.tkchaind/config/tmp_genesis.json $HOME/.tkchaind/config/genesis.json
cat $HOME/.tkchaind/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="aphoton"' > $HOME/.tkchaind/config/tmp_genesis.json && mv $HOME/.tkchaind/config/tmp_genesis.json $HOME/.tkchaind/config/genesis.json

# Allocate genesis accounts (cosmos formatted addresses)
$PWD/build/tkchaind add-genesis-account "$("$PWD"/build/tkchaincli keys show "$KEY$i" -a)" 100000000000000000000aphoton

# Sign genesis transaction
$PWD/build/tkchaind gentx --name $KEY --amount=1000000000000000000aphoton --keyring-backend test

# Collect genesis tx
$PWD/build/tkchaind collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
$PWD/build/tkchaind validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed) in background and log to file
$PWD/build/tkchaind start --pruning=nothing --rpc.unsafe --log_level "main:info,state:info,mempool:info" --trace > tkchaind.log &

sleep 1

# Start the rest server with unlocked key in background and log to file
$PWD/build/tkchaincli rest-server --laddr "tcp://localhost:8545" --unlock-key $KEY --chain-id $CHAINID --trace --rpc-api="web3,eth,net,personal" > tkchaincli.log &

solcjs --abi $PWD/tests-solidity/suites/basic/contracts/Counter.sol --bin -o $PWD/tests-solidity/suites/basic/counter
mv $PWD/tests-solidity/suites/basic/counter/*.abi $PWD/tests-solidity/suites/basic/counter/counter_sol.abi 2> /dev/null
mv $PWD/tests-solidity/suites/basic/counter/*.bin $PWD/tests-solidity/suites/basic/counter/counter_sol.bin 2> /dev/null

ACCT=$(curl --fail --silent -X POST --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' -H "Content-Type: application/json" http://localhost:8545 | grep -o '\0x[^"]*' | head -1 2>&1)

echo $ACCT

curl -X POST --data '{"jsonrpc":"2.0","method":"personal_unlockAccount","params":["'$ACCT'", ""],"id":1}' -H "Content-Type: application/json" http://localhost:8545

PRIVKEY="$("$PWD"/build/tkchaincli keys unsafe-export-eth-key $KEY)"

echo $PRIVKEY

## need to get the private key from the account in order to check this functionality.
cd tests-solidity/suites/basic/ && go get && sleep 5 && go run main.go $ACCT
