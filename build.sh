#!/usr/bin/env bash
mkdir ebin
erlc  -I lib/amqp_client/include/ -I lib/ -o ebin src/*


