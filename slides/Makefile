REBAR3_URL=https://s3.amazonaws.com/rebar3/rebar3
NODE0=web_node_0@$(shell hostname)
NODE1=web_node_1@$(shell hostname)
NODE2=web_node_2@$(shell hostname)
NODE3=web_node_3@$(shell hostname)
NODE4=web_node_4@$(shell hostname)


ifeq ($(wildcard rebar3),rebar3)
REBAR3 = $(CURDIR)/rebar3
endif

REBAR3 ?= $(shell test -e `which rebar3` 2>/dev/null && which rebar3 || echo "./rebar3")


ifeq ($(REBAR3),)
REBAR3 = $(CURDIR)/rebar3
endif

.PHONY: deps test build

all: build test docs

build: $(REBAR3)
	@$(REBAR3) compile

$(REBAR3):
	wget $(REBAR3_URL) || curl -Lo rebar3 $(REBAR3_URL)
	@chmod a+x rebar3

deps:
	@$(REBAR3) get-deps

clean:
	@$(REBAR3) clean

distclean: clean
	@$(REBAR3) delete-deps

docs:
	@$(REBAR3) edoc


test: 
	@$(REBAR3) do ct, cover

release: test
	@$(REBAR3) release

run-one: build
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_0  PORT=8080 ETCD2_HOST=172.17.8.101 _build/default/rel/slides/bin/slides console

run-two: build
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_1  PORT=8081 _build/default/rel/slides/bin/slides console

run-nodes:
	sleep 3
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_1  PORT=8081 _build/default/rel/slides/bin/slides foreground &
	sleep 3
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_2  PORT=8082 _build/default/rel/slides/bin/slides foreground &
	sleep 3
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_3  PORT=8083 _build/default/rel/slides/bin/slides foreground &
	sleep 3
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_4  PORT=8084 _build/default/rel/slides/bin/slides foreground &

cluster:
	sleep 3   
	erl -sname con -noinput -hidden -eval "rpc:call('$(NODE1)', net_kernel, connect, ['$(NODE0)']),init:stop()."
	sleep 3   
	erl -sname con -noinput -hidden -eval "rpc:call('$(NODE2)', net_kernel, connect, ['$(NODE0)']),init:stop()."
	sleep 3
	erl -sname con -noinput -hidden -eval "rpc:call('$(NODE3)', net_kernel, connect, ['$(NODE0)']),init:stop()."
	sleep 3
	erl -sname con -noinput -hidden -eval "rpc:call('$(NODE4)', net_kernel, connect, ['$(NODE0)']),init:stop()."

stop-nodes:
	sleep 2
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_1  PORT=8081 _build/default/rel/slides/bin/slides stop &
	sleep 2
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_2  PORT=8082 _build/default/rel/slides/bin/slides stop &
	sleep 2
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_3  PORT=8083 _build/default/rel/slides/bin/slides stop &
	sleep 2
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_4  PORT=8084 _build/default/rel/slides/bin/slides stop &

python-client:
	python presentation.py

cool-schema:
	bash build_schema