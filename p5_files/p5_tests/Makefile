TESTFILES := $(wildcard **/*.levi) $(wildcard *.levi)
TESTS := $(TESTFILES:.levi=.test)

.PHONY: all

all: $(TESTS)

%.test:
	@echo "Testing $*.levi"
	@touch $*.err
	@../levic $*.levi -c 2> $*.err ;\
	PROG_EXIT_CODE=$$?;\
	echo "diff error...";\
	diff $*.err $*.err.expected;\
	ERR_EXIT_CODE=$$?;\
	exit $$ERR_EXIT_CODE

clean:
	rm -f *.out *.err
