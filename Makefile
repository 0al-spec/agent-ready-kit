MDLINT := npx --yes markdownlint-cli2

.PHONY: md-lint md-fmt md-check

md-lint:
	$(MDLINT)

md-fmt:
	$(MDLINT) --fix

md-check: md-lint
