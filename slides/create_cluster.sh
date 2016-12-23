#!/bin/bash

export RELX_REPLACE_OS_VARS=true

for i in `seq 1 2`;
do
    echo "Staring the node.....$i"
    NODE_NAME=web_node_$i  PORT=808$i _build/default/rel/slides/bin/slides foreground &
    sleep 1
done

echo "Nodes started, preparing the join.."
sleep 3

for i in `seq 1 2`;
do
    echo "Adding the node$i to the cluster"
    erl -sname con -noinput  -eval "rpc:call('web_node_$i@$(hostname)', net_kernel, connect, ['web_node_0@$(hostname)']),init:stop()."
    sleep 2
done

