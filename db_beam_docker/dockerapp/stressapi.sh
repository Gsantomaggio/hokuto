#!/usr/bin/env bash

for i in `seq 1 500`;
do
    echo "executing ..." $i
    curl http://localhost:8627/api/trace?param=$i
done