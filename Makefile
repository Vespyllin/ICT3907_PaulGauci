# BIN := _build/dev/lib/deploy/ebin
BIN := ./
SRC := lib/

define recursive
	$(shell find $(1) -name "*.$(2)")
endef

all: compile

compile:
	# erlc -pa $(BIN) +debug_info -W0 -I $(SRC)/detecter/include -o $(BIN) $(call recursive,$(SRC),erl)	
	erlc -pa $(BIN) +debug_info -W0 -I $(SRC)/detecter/include $(call recursive,$(SRC),erl)	

