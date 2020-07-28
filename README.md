# MakerDAO Testchain

This tool will help you set up a local testchain with all the contracts needed for the [Dai.js](https://github.com/makerdao/dai.js) library. These are preserved as snapshots of the complete system, and can be launched quickly on Ganache without any additional deployment or configuration.

These scripts can also be used to update, re-deploy, add, or remove contracts from the local testing environment, and to create new snapshots of that environment for future use.

## Installation and requirements

Requires Node.js.

Run `npm install` or `yarn` to install Ganache. If you only want to run the testchain with an existing snapshot (without building or deploying additional contracts), that's all you need to do.

If you want to build and deploy contracts, you will need to install [Seth](https://dapp.tools/seth/) and [Nix](https://github.com/NixOS/nix) (`yarn install-nix`). You will also need to initialize and update the git submodules by running `git submodule update --init --recursive` (or `dapp update`).

## Typical usage

If all you need to do is run the testchain with the `default` snapshot, simply run:

```
scripts/launch -s default --fast
```
or
```
yarn launch
```

For a full list of contracts included in the `default` snapshot, you can reference the [SCD](https://github.com/makerdao/testchain/blob/dai.js/out/addresses.json) and [MCD](https://github.com/makerdao/testchain/blob/dai.js/out/addresses-mcd.json) address files generated from the deployment scripts.

## Building and deploying contracts

### The easy way

The majority of users can simply run the following built-in deployment commands:

- `yarn deploy-mcd` or `yarn update-mcd`: Builds and deploys all MCD contracts. `update-mcd` will also automatically overwrite the `default` snapshot with the new deployment. These can be run without altering SCD or auxiliary contracts.
- `yarn deploy-scd` or `yarn update-scd`: Builds and deploys all SCD and auxiliary contracts. `update-scd` will also automatically overwrite the `scd-only` snapshot with the new deployment. **If you create a new SCD snapshot, you must subsequently redeploy MCD.**

Note that, by default, these built-in commands assume you have up-to-date submodules, and they will terminate the testchain instance upon completion.

### The less easy way

`scripts/launch` is the base command.

If run with no arguments, it will start Ganache at `127.0.0.1:2000` with the chain data it finds in `var/chaindata`. It will run until killed with Ctrl-C.

If `var/chaindata` does not exist, and the `--reset-chaindata` argument is not present, the `default` snapshot will be used to create it.

### Options

* `-s, --snapshot`: Optional. This should match the name of a folder under the `snapshots` folder. This will be copied to `var/chaindata`, overwriting anything there.

* `-d, --deploy`: Optional. If set, `scripts/deploy` will be run once Ganache is set up, to deploy contracts to the test chain.

* `--fast`: Skip `git submodule update` and skip running `dapp build` for dapps that are already built. This is accomplished by setting the `SKIP_BUILD_IF_ALREADY_BUILT` environment variable, so the dapp build scripts must be written (or modified; see the use of `sed_inplace` in `scripts/deploy`) to support it.

* `--reset-chaindata`: Start the testchain with no data.

* `-u, --skip-update`: Skip the git submodule updates, but still run `dapp build` on the contracts.

* `-p, --port`: Start Ganache on a different port.

* `--throw-revert`: Have Ganache throw an exception whenever a transaction is reverted.

* `--ci`: If this is set, all unrecognized arguments will be treated as a new command. This command will be run, and Ganache will exit afterward.


## Deployer account

Some governance processes are bypassed in the testchain deployment. This gives the deployer account special priveleges within the system (such as triggering a shutdown). This account also starts with a balance of 400 MKR.

```
Address: 0x16Fb96a5fa0427Af0C8F7cF1eB4870231c8154B6
Key: 474BEB999FED1B3AF2EA048F963833C686A0FBA05F5724CB6417CF3B8EE9697E
```

## Creating a new snapshot

Create a new snapshot with: `./scripts/create-snapshot $SNAPSHOT_NAME`

Update an existing snapshot with: `./scripts/create-snapshot $SNAPSHOT_NAME --force`

If you want to update the `default` or `scd-only` snapshots, you can also run `yarn create-default-snapshot` or `yarn create-scd-snapshot`

## Contract data and build output

When the deployment scripts are run, they copy ABI files and output addresses from the deployed contracts to a file in the `out/` directory. These can be copied into the source code of applications working with the testchain as you see fit.
