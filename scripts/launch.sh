#!/usr/bin/env bash
set -e

START_TIME=`date +%s`
CWD="${0%/*}"
LIB=$CWD/../lib
DB=$CWD/../chaindata

SEED_WORDS="hill law jazz limb penalty escape public dish stand bracket blue jar"

# If 'fast' is passed as last arg, set the SKIP_BUILD_IF_ALREADY_BUILT and
# SKIP_SUBMODULE_UPDATE env variables for many speed, much fast, very impress
if [[ "${@:$#}" == 'fast' ]]; then
  
  export SKIP_BUILD_IF_ALREADY_BUILT=1
  export SKIP_SUBMODULE_UPDATE=1
  set -- "${@:1:$(($#-1))}" # Pop last arg
fi

# Check if a testnet is already running on port 2000
if ! nc -z 127.0.0.1 2000; then

  if [ -n "$SKIP_BUILD_IF_ALREADY_BUILT" ]; then
    echo "Skipping build of dapps that are already built."
  fi

  if [ -n "$SKIP_SUBMODULE_UPDATE" ]; then
    echo "Skipping git submodule update."
  else
    git submodule update --init --recursive
  fi

  # Configure seth
  export ETH_GAS=${ETH_GAS:-"4000000"}
  export SETH_STATUS=yes
  export ETH_RPC_ACCOUNTS=yes # Don't use ethsign
  export ETH_RPC_URL=http://127.1:2000

  # Start a testnet on port 2000
  echo "Starting ganache-cli..."
  ./node_modules/.bin/ganache-cli -i 999 -p 2000 -a 1000 -m $SEED_WORDS \
    --db $DB > ./ganache.out 2>&1 & netpid=$!

  # Stop the testnet when this script exits
  trap "kill $netpid" EXIT

  # Wait for the testnet to become responsive
  until curl -s -o/dev/null "$ETH_RPC_URL"; do sleep 1; done

  # Finish configuring seth with settings from running testnet
  export ETH_FROM=$(seth rpc eth_coinbase)

  # Deploy contracts
  $CWD/deploy.sh

  END_TIME=`date +%s`
  ELAPSED=`echo $END_TIME - $START_TIME | bc`
  echo "Created testnet in" $ELAPSED "seconds."
else
  echo "You already have a test network running on port 2000."
fi


if [[ "$1" != '--ci' ]]; then
  # The testnet will continue to run with its deployed contracts
  # until the user confirms it should shut down.
  $@
  bash $CWD/confirm-kill-testnet
else
  # Proceed to the command given as arguments (but strip --ci as first param).
  $(echo "$@" | sed 's/^\-\-ci //')
fi
