.PHONY: audit bootstrap run test clean

audit:
	./scripts/audit.sh

bootstrap:
	./scripts/bootstrap-local.sh

run:
	./scripts/run-local.sh

test:
	./scripts/test.sh

clean:
	rm -rf .pharo
	find var/data -mindepth 1 ! -name .gitkeep -delete
