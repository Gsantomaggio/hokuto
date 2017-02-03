REBAR3_URL=https://s3.amazonaws.com/rebar3/rebar3
NODE0=search_node_0@$(shell hostname)
NODE1=search_node_1@$(shell hostname)
NODE2=search_node_2@$(shell hostname)
NODE3=search_node_3@$(shell hostname)
NODE4=search_node_4@$(shell hostname)


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
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_0 _build/default/rel/search/bin/search console

run-nodes:	
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_1 _build/default/rel/search/bin/search foreground &
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_2 _build/default/rel/search/bin/search foreground &
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_3 _build/default/rel/search/bin/search foreground &
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_4 _build/default/rel/search/bin/search foreground &


cluster: run-nodes
	sleep 3   
	erl -sname con -noinput -hidden -eval "rpc:call($(NODE1), net_kernel, connect, [$(NODE0)]),init:stop()."
	sleep 3   
	erl -sname con -noinput -hidden -eval "rpc:call($(NODE2), net_kernel, connect, [$(NODE0)]),init:stop()."
	sleep 3
	erl -sname con -noinput -hidden -eval "rpc:call($(NODE3), net_kernel, connect, [$(NODE0)]),init:stop()."
	sleep 3
	erl -sname con -noinput -hidden -eval "rpc:call($(NODE4), net_kernel, connect, [$(NODE0)]),init:stop()."

stop-nodes:
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_1  _build/default/rel/search/bin/search stop &
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_2  _build/default/rel/search/bin/search stop &
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_3  _build/default/rel/search/bin/search stop &
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_4  _build/default/rel/search/bin/search stop &