#!/usr/bin/env bash
erl -pa lib/amqp_client lib/rabbit_common/ebin lib/amqp_client/ebin -pa ebin  -eval 'ex_distr:start_link()' -sname ex"$1" -setcookie MYEXCOOKIE
