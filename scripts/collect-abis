#!/usr/bin/env bash
set -e

CWD="${0%/*}"
LIB=$CWD/../lib
OUT=$CWD/../out

mkdir -p $OUT

cp $LIB/maker-otc/out/MatchingMarket.abi \
  $LIB/ds-proxy/out/DSProxy.abi \
  $LIB/ds-proxy/out/DSProxyFactory.abi \
  $LIB/sai-proxy/out/SaiProxyCreateAndExecute.abi \
  $LIB/proxy-registry/out/ProxyRegistry.abi \
$OUT

ls $LIB/sai/out/*.abi | \
  grep -v -E "(Fab|Dev|Test)" | \
  xargs sh -c "cp \$@ $OUT"
