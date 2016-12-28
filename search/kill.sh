#!/bin/bash

for i in `seq 1 4`;
do
    echo "killing the node$i"
    kill $(ps aux | grep "search_node_$i@mac" | awk '{print $2}')
    sleep 1
done


