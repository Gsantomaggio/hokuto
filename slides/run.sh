#!/bin/bash

export RELX_REPLACE_OS_VARS=true

for i in `seq 1 1`;
do
    echo "run..$i"
    NODE_NAME=node_$i PORT=808$i _build/default/rel/slides/bin/slides-0.0.1 foreground &
    sleep 1
done  

