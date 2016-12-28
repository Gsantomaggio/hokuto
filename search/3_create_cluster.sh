#!/bin/bash

export RELX_REPLACE_OS_VARS=true

for i in `seq 1 4`;
do
    echo "Staring the node.....$i"
    NODE_NAME=node_$i  _build/default/rel/search/bin/search foreground &
    sleep 1
done

echo "Nodes started, preparing the join.."
sleep 3

for i in `seq 1 4`;
do
    echo "Adding the node$i to the cluster"
    erl -sname con -noinput  -eval "rpc:call('search_node_$i@$(hostname)', 
net_kernel, connect, ['search_node_0@$(hostname)']),init:stop()."
    sleep 2
done

