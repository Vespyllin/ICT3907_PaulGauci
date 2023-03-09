BIN := _build/dev/lib/xeval/ebin
SRC := lib/detecter

define recursive
	$(shell find $(1) -name "*.$(2)")
endef

all: compile
	
compile: clean
	erlc -pa $(BIN) +debug_info -W0 -I $(SRC)/include -o $(BIN) $(call recursive,$(SRC),erl)
	erlc -pa $(BIN) +debug_info -W0 -o $(BIN) lib/prop_add_rec.erl

clean: 
	rm -f $(BIN)/*.beam
