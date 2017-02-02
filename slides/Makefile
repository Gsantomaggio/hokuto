REBAR3_URL=https://s3.amazonaws.com/rebar3/rebar3

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

run-one:
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_0  PORT=8080 _build/default/rel/slides/bin/slides console

run-nodes:
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_1  PORT=8081 _build/default/rel/slides/bin/slides foreground &
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_2  PORT=8082 _build/default/rel/slides/bin/slides foreground &
	RELX_REPLACE_OS_VARS=true NODE_NAME=node_3  PORT=8083 _build/default/rel/slides/bin/slides foreground &

cluster:
	for i in `seq 1 4`; \
	do \
	echo "Adding the node$i to the cluster" \
	erl -sname con -noinput -hidden -eval "rpc:call('web_node_$i@$(hostname)', net_kernel, connect, ['web_node_0@$(hostname)']),init:stop()." \
	sleep 2 \
	done \
