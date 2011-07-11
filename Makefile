APP_NAME := cameron

all: compile
	
compile: clear
	@cp src/$(APP_NAME).app ebin/
	@erlc -pa ebin/ \
	      -pa deps/ \
	      -pa deps/erl_helpers/ebin/ \
	      -pa deps/erlang-uuid/ebin/ \
	      -pa deps/misultin-0.6.2/ebin/ \
	      -pa deps/redo/ebin/ \
	      -I include/ \
	      -o ebin/ \
	      src/*.erl
	
compile_test: compile
	@erlc -pa ebin/ \
	      -pa deps/ \
	      -pa deps/erl_helpers/ebin/ \
	      -pa deps/erlang-uuid/ebin/ \
	      -pa deps/misultin-0.6.2/ebin/ \
	      -pa deps/redo/ebin/ \
	      -I include/ \
	      -o ebin/ \
	      test/*.erl

run:
	@erl -pa ebin/ deps/**/ebin/ -sname $(APP_NAME) -s $(APP_NAME) \
	     -config priv/config/production \
	     -workflows priv/workflows/production.config

run_dev:
	@erl -pa ebin/ deps/**/ebin/ -sname $(APP_NAME) \
	     -boot start_sasl -s $(APP_NAME) \
	     -config priv/config/development \
	     -workflows priv/workflows/development.config

run_test: compile_test
	@erl -noshell -pa ebin/ deps/**/ebin/ -s $(APP_NAME) \
	     -run $(MODULE) test -run init stop \
	     -config priv/config/test \
 	     -workflows priv/workflows/test.config

run_all_tests: compile_test
	@for fullfilename in `find ./test -name "*_test.erl"`; do \
		filename=$$(basename $$fullfilename); \
		module=$${filename%%.*}; \
		echo ; \
		echo running: $$module; \
		erl -noshell -pa ebin/ deps/**/ebin/ -s $(APP_NAME) \
		    -run $$module test -run init stop \
		    -config priv/config/test; \
	done

clear:
	@rm -f ebin/*.beam
	@rm -f erl_crash.dump
