.PHONY: all clean test1 test2

TESTFILES := $(wildcard *.input)
TESTS := $(TESTFILES:.input=.test)

all: prog test
	echo "Build complete."

prog: prog.o
	g++ $< -o $@
%.o: %.cpp
	g++ -c $< -o $@

clean:
	rm -f *.o prog *.out *.err *.test

test: $(TESTS)

%.test:
	@echo "Running test $*..."
	@./prog $*.input 1> $*.out 2> $*.err
	@diff $*.out $*.out.expected
	@diff $*.err $*.err.expected



