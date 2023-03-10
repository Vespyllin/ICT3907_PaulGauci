BIN := _build/dev/lib/xeval/ebin
TEST_BIN := _build/test/lib/xeval/ebin
SRC := lib/
TEST_SRC := test/src

define recursive
	$(shell find $(1) -name "*.$(2)")
endef

all: test_pass

compile: clean
	erlc -pa $(BIN) +debug_info -W0 -I $(SRC)/detecter/include -o $(BIN) $(call recursive,$(SRC),erl)
	elixirc -o $(BIN) $(call recursive,$(SRC),ex)

clean: 
	rm -f $(BIN)/*.beam

test_pass: compile
	rm -f $(TEST_BIN)/*.beam
	cp $(BIN)/* $(TEST_BIN)
	elixirc -o $(TEST_BIN) $(call recursive,$(TEST_SRC),ex)