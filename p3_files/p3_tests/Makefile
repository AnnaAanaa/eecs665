TESTFILES := $(wildcard *.levi)
TESTS := $(TESTFILES:.levi=.test)

.PHONY: all

all: $(TESTS)

%.test:
	@rm -f $*.unparse $*.err
	@touch $*.unparse
	@echo "TEST $*"
	@../levic $*.levi -u $*.unparse 2> $*.err ;\
	PROG_EXIT_CODE=$$?;\
	if [ $$PROG_EXIT_CODE != 0 ]; then \
		echo "levic error:"; \
		cat $*.err; \
		exit 1; \
	fi; \
	diff -B --ignore-all-space $*.unparse $*.unparse.expected; \
	STDOUT_DIFF_EXIT=$$?;\
	exit $$STDOUT_DIFF_EXIT || echo "Tests passed"

clean:
	rm -f *.unparse *.err
