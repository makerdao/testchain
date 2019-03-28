# MakerDAO Testchain

This tool will help you set up a local testchain and deploy the contracts you need to work with Maker apps.

This branch, `dai.js`, is configured with the contracts needed for the [Dai.js](https://github.com/makerdao/dai.js) library.

## Installation and requirements

Requires [Seth](https://dapp.tools/seth/), [Nix](https://github.com/NixOS/nix), Node.js and Bash.

Run `npm install` or `yarn install` to install Ganache.

## Basic usage

Run `scripts/launch`.

If run with no arguments, it will start Ganache at `127.0.0.1:2000` with the chain data it finds in `var/chaindata`, and run until killed with Ctrl-C.

If `var/chaindata` does not exist, and the `--reset-chaindata` argument is not present, the `default` snapshot will be used to create it.

Once the deployment is complete, you will find the list of contract addresses in the `out/addresses.json` file.

### Options

* `-s, --snapshot`: Optional. This should match the name of a folder under the `snapshots` folder. This will be copied to `var/chaindata`, overwriting anything there.

* `-d, --deploy`: Optional. If set, `scripts/deploy` will be run once Ganache is set up, to deploy contracts to the test chain.

* `--fast`: Skip `git submodule update` and skip running `dapp build` for dapps that are already built. This is accomplished by setting the `SKIP_BUILD_IF_ALREADY_BUILT` environment variable, so the dapp build scripts must be written (or modified; see the use of `sed_inplace` in `scripts/deploy`) to support it.

* `--reset-chaindata`: Start the testchain with no data.

* `-u, --skip-update`: Skip the git submodule updates, but still run `dapp build` on the contracts.

* `-p, --port`: Start Ganache on a different port.

* `--throw-revert`: Have Ganache throw an exception whenever a transaction is reverted.

* `--ci`: If this is set, all unrecognized arguments will be treated as a new command. This command will be run, and Ganache will exit afterward.

## Deploying changes to contract code

When the deploy script is run, it copies ABI files and output addresses of deployment contracts to a file in `out/` directory. These can be copied into the source code of applications working with the test chain as you see fit.

## Creating new snapshots

Use `scripts/create-snapshot NAME` to copy the contents of `var/chaindata` into a new folder `snapshots/NAME`. Add `--force` if you want to replace an existing snapshot.

## Recipe: rebuilding MCD

```
./scripts/launch -s scd-only --deploy --deploy-mcd-only
```

This starts with a snapshot of all the SCD contracts, and then redeploys all the MCD contracts on top of that snapshot. Edit `scripts/deploy-mcd` to tweak the build parameters or add to it.
