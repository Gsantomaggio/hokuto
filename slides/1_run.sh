#!/bin/sh

rebar3 clean
rebar3 release
export RELX_REPLACE_OS_VARS=true
echo "run.."
NODE_NAME=node_0  PORT=8080 _build/default/rel/slides/bin/slides console

