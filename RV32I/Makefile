rtl_source = $(wildcard rtl/*.v)
tb_source = $(wildcard tb/*.v)
testbenches = $(tb_source:tb/%_tb.v=%)

.PHONY: all test clean $(testbenches)

all: test

test: $(testbenches)

$(testbenches): %: rtl/%.v tb/%_tb.v
	@echo "Testing $*"
	@mkdir -p build
	@iverilog -g2012 -o build/tb_$* $^
	@vvp build/$*_tb

clean
	rm -rf build
