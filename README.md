# MakerDAO Testchain

This tool will help you set up a local testchain and deploy the contracts you need to work with Maker apps.

This branch, `mcd`, is configured for the Multi-Collateral Dai contracts. Its `default` snapshot contains both a deployment of those contracts and the ones required for the Single-Collateral Dai system.

## Installation and requirements

Requires Node.js and Bash.

Run `npm install` or `yarn install` to install Ganache.

## Basic usage

Run `scripts/launch.sh`.

If run with no arguments, it will start Ganache at `127.0.0.1:2000` with the chain data it finds in `var/chaindata`, and run until killed with Ctrl-C.

If `var/chaindata` does not exist, the `default` snapshot will be used to create it.

### Options

* `-s, --snapshot`: Optional. This should match the name of a folder under the `snapshots` folder. This will be copied to `var/chaindata`, overwriting anything there.

* `-d, --deploy`: Optional. If set, `scripts/deploy` will be run once Ganache is started.

* `--fast`: Skip `git submodule update` and skip running `dapp build` for dapps that are already built. This is accomplished by setting the `SKIP_BUILD_IF_ALREADY_BUILT` environment variable, so the dapp build scripts must be written (or modified; see the use of `sed_inplace` in `deploy.sh`) to support it.

* `-p, --port`: Start Ganache on a different port.

* `--ci`: If this is set, all unrecognized arguments will be treated as a new command. This command will be run once the test chain is up, and Ganache will exit afterward.

* `-o, --output`: Works only with `-d`. Will export deployed contracts to specified format. Available formats are: `json|env|yaml|template`

* `--template`: Output configuration template. See (deployment output section)[#deploying-changes-to-contract-code].

## Deploying changes to contract code

When the deploy script is run, it copies ABI files and output addresses of deployment contracts to file in `out/` directory. These can be copied into the source code of applications working with the test chain as you see fit.

This output file can be in different format depending on `-o, --output` option.

 * `-o json` - creates `out/addresses.json` file in JSON format
 * `-o env` - creates `out/addresses` file with bash script that setting variables to ENV params.
 * `-o yaml` - creates `out/addresses.yaml` file in YAML format
 * `-o path/to/output/config.any --template path/to/config.template` - will copy config file to `path/to/output/config.any` and replace all placeholders there.

### Configuration file template

If you need to configure your application using custom config file you could do this using config template.

1. Create config template file somewhere ex: `your/project/path/config/local.template` with this content:
```
[database]
name = "vulcanize_public"
hostname = "localhost"
port = 5432

[client]
ipcPath = "http://{{TESTCHAIN_HOST}}:{{TESTCHAIN_PORT}}"

[contract]
vat = "{{TESTCHAIN_VAT}}"
join_eth = "{{TESTCHAIN_JOIN_ETH}}"
```

2. Run launch script with `-d` deploy flag. 

```bash
$ testchain/scripts/launch -d --template your/project/path/config/local.template -o your/project/path/config/local.toml
```

This command will copy `local.template` content, replace all testchain variables and place new fullfilled config file to `your/project/path/config/local.toml`

If such file already exist, script will ask you to delete it first.

### Testchain template variables

`TESTCHAIN_HOST` - host. default to `127.0.0.1`
`TESTCHAIN_PORT` - testchain port. default to `2000`
`TESTCHAIN_DEPLOY` - contract address
`TESTCHAIN_GOV` - contract address
`TESTCHAIN_VAT` - contract address
`TESTCHAIN_PIT` - contract address
`TESTCHAIN_DRIP` - contract address
`TESTCHAIN_CAT` - contract address
`TESTCHAIN_VOW` - contract address
`TESTCHAIN_MCD` - contract address
`TESTCHAIN_JOIN_DAI` - contract address
`TESTCHAIN_MOVE_DAI` - contract address
`TESTCHAIN_FLAP` - contract address
`TESTCHAIN_FLOP` - contract address
`TESTCHAIN_MOM` - contract address
`TESTCHAIN_DAI` - contract address
`TESTCHAIN_DAI_GUARD` - contract address
`TESTCHAIN_DGX` - contract address
`TESTCHAIN_JOIN_DGX` - contract address
`TESTCHAIN_MOVE_DGX` - contract address
`TESTCHAIN_FLIP_DGX` - contract address
`TESTCHAIN_SPOT_DGX` - contract address
`TESTCHAIN_PIP_DGX` - contract address
`TESTCHAIN_PIP_ETH` - contract address
`TESTCHAIN_JOIN_ETH` - contract address
`TESTCHAIN_MOVE_ETH` - contract address
`TESTCHAIN_FLIP_ETH` - contract address
`TESTCHAIN_SPOT_ETH` - contract address
`TESTCHAIN_REP` - contract address
`TESTCHAIN_PIP_REP` - contract address
`TESTCHAIN_JOIN_REP` - contract address
`TESTCHAIN_MOVE_REP` - contract address
`TESTCHAIN_FLIP_REP` - contract address
`TESTCHAIN_SPOT_REP` - contract address

## Creating new snapshots

Use `scripts/create-snapshot NAME` to copy the contents of `var/chaindata` into a new folder `snapshots/NAME`. Add `--force` if you want to replace an existing snapshot.
