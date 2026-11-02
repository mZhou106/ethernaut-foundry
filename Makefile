.PHONY: build test test-one clean

build:
	forge build

test:
	forge test

# Usage: make test-one LEVEL=Fallback
test-one:
	forge test --match-contract Test$(LEVEL) -vvv

clean:
	forge clean
