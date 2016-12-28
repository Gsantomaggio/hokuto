#!/bin/bash

rebar3 release
export RELX_REPLACE_OS_VARS=true
echo "run.."
NODE_NAME=node_0 _build/default/rel/search/bin/search console

