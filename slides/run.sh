#!/bin/bash

rebar3 release
export RELX_REPLACE_OS_VARS=true

for i in `seq 1 1`;
do
    echo "run..$i"
    NODE_NAME=node_$i  PORT=808$i _build/default/rel/slides/bin/slides-0.0.1 console
    sleep 1
done  

