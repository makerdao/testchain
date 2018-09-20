#!/usr/bin/env bash
set -e

CWD="${0%/*}"
LIB=$CWD/../lib
OUT=$CWD/../out

function sed_inplace {
  # sed's -i argument behaves differently on macOS, hence this hack
  sed -i.bak "$1" $2 && rm $2.bak
}

############################
# build sai system

# Fix sai deploy script
sed_inplace '13s/DSToken.*/WETH9)/' $LIB/sai/bin/deploy
# Change sai deploy scripts (deploy and deploy-fab) to skip dapp build if SKIP_BUILD_IF_ALREADY_BUILT is set and dapp is already built
sed_inplace 's/^dapp build$/if [[ -z "$SKIP_BUILD_IF_ALREADY_BUILT" || ( -n "$SKIP_BUILD_IF_ALREADY_BUILT" \&\& ! -f out\/SaiTop.abi ) ]]; then dapp build; fi/' $LIB/sai/bin/deploy-fab
sed_inplace 's/^dapp build$/# dapp build/' $LIB/sai/bin/deploy

cd $LIB/sai
if [[ -z "$SKIP_BUILD_IF_ALREADY_BUILT" || ( -n "$SKIP_BUILD_IF_ALREADY_BUILT" && ! -f out/SaiTop.abi ) ]]; then
  echo "Building and deploying sai contracts..."
else
  echo "Deploying sai contracts..."
fi
bin/deploy-fab 2> /dev/null && . load-fab-unknown
bin/deploy 2> /dev/null     && . load-env-unknown

# Set the ETH price feed to 400 USD
seth send $SAI_PIP "poke(bytes32)" 0x000000000000000000000000000000000000000000000015af1d78b58c400000
# Set the MKR price feed to 1040.49 USD
seth send $SAI_PEP "poke(bytes32)" 0x00000000000000000000000000000000000000000000003867bb3260a7cf7200
seth send $SAI_MOM "setCap(uint256)" $(seth --to-uint256 $(seth --to-wei 1000 eth))
# Mint MKR, owned by default account
seth send $SAI_GOV "mint(uint256)" 0x000000000000000000000000000000000000000000000015af1d78b58c400000
cd -

############################
# build oasis

export SOLC_FLAGS=${SOLC_FLAGS:-"--optimize"}
cd $LIB/maker-otc
if [ -n "$SKIP_BUILD_IF_ALREADY_BUILT" ] && [ -f out/MatchingMarket.abi ]; then
  echo "Skipping dapp build for maker-otc (already built)"
else
  echo "Building maker-otc..."
  dapp build 2> /dev/null
fi
echo "Deploying maker-otc (MatchingMarket)..."
OTC=$(dapp create MatchingMarket 1577836800) # This is some random date in 2020
addr1="0xc226f3cd13d508bc319f4f4290172748199d6612"
addr2="0x7ba25f791fa76c3ef40ac98ed42634a8bc24c238"
seth send $OTC "addTokenPairWhitelist(address,address)" $addr1 $addr2
cd -

############################
# build proxy factory

cd $LIB/ds-proxy
if [ -n "$SKIP_BUILD_IF_ALREADY_BUILT" ] && [ -f out/DSProxy.abi ]; then
  echo "Skipping dapp build for ds-proxy (already built)"
else
  echo "Building ds-proxy..."
  dapp build 2> /dev/null
fi
echo "Deploying ds-proxy (DSProxyFactory)..."
DS_PROXY_FACTORY=$(dapp create DSProxyFactory) # Deploy proxy factory instance
echo "Deployed DSProxyFactory to $DS_PROXY_FACTORY"
cd -

############################
# build proxy registry

cd $LIB/proxy-registry
if [ -n "$SKIP_BUILD_IF_ALREADY_BUILT" ] && [ -f out/ProxyRegistry.abi ]; then
  echo "Skipping dapp build for proxy-registry (already built)"
else
  echo "Building proxy-registry..."
  dapp build ProxyRegistry 2> /dev/null
fi
echo "Deploying proxy-registry (ProxyRegistry)..."
PROXY_REGISTRY=$(dapp create ProxyRegistry $DS_PROXY_FACTORY) # Deploy proxy registry instance and pass in proxy factory
echo "Deployed ProxyRegistry to $PROXY_REGISTRY"

echo "Creating DSProxy via ProxyRegistry.build()..."
DS_PROXY="0x"$(seth --abi-decode "build()(address)" $(seth call $PROXY_REGISTRY "build()")) # Get expected address of new DSProxy instance about to be created
seth send $PROXY_REGISTRY "build()"
echo "Created new DSProxy instance with address: $DS_PROXY"
cd -

############################
# build sai proxy

cd $LIB/sai-proxy
if [ -n "$SKIP_BUILD_IF_ALREADY_BUILT" ] && [ -f out/SaiProxyCreateAndExecute.abi ]; then
  echo "Skipping dapp build for sai-proxy (already built)"
else
  echo "Building sai-proxy..."
  dapp build 2> /dev/null
fi
echo "Deploying sai-proxy (SaiProxyCreateAndExecute)..."
SAI_PROXY=$(dapp create SaiProxyCreateAndExecute)
echo "Deployed SaiProxyCreateAndExecute to $SAI_PROXY"
cd -

############################
# store outputs for apps to use

mkdir -p $OUT

cat > $OUT/addresses.json <<- EOM
{
  "GEM": "$SAI_GEM",
  "GOV": "$SAI_GOV",
  "PIP": "$SAI_PIP",
  "PEP": "$SAI_PEP",
  "PIT": "$SAI_PIT",
  "ADM": "$SAI_ADM",
  "SAI": "$SAI_SAI",
  "SIN": "$SAI_SIN",
  "SKR": "$SAI_SKR",
  "DAD": "$SAI_DAD",
  "MOM": "$SAI_MOM",
  "VOX": "$SAI_VOX",
  "TUB": "$SAI_TUB",
  "TAP": "$SAI_TAP",
  "TOP": "$SAI_TOP",
  "MAKER_OTC": "$OTC",
  "DS_PROXY_FACTORY": "$DS_PROXY_FACTORY",
  "PROXY_REGISTRY": "$PROXY_REGISTRY",
  "DS_PROXY": "$DS_PROXY",
  "SAI_PROXY": "$SAI_PROXY"
}
EOM

$CWD/collect-abis.sh
