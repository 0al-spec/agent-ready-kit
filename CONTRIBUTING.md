# Contributing

Thanks for contributing. This guide covers how we validate and format Markdown in this repo.

## Markdown validation and formatting

We use `markdownlint-cli2` via `npx` so contributors do not need to install a global tool.

### Local checks

- Lint (CI-equivalent):
  - `make md-check`
- Auto-fix formatting where possible:
  - `make md-fmt`

If you do not want to use `make`, you can run:

- `npx --yes markdownlint-cli2`
- `npx --yes markdownlint-cli2 --fix`

### Configuration

- Lint rules live in `.markdownlint.yaml`.
- CLI config (globs and ignores) lives in `.markdownlint-cli2.yaml`.

Some rules are relaxed to preserve existing spec formatting (for example, hard line breaks and inline HTML markers).

### CI

GitHub Actions runs `make md-check` on pull requests and on pushes to `main` when Markdown files change.

### Troubleshooting

If CI fails:

1. Run `make md-check` locally to reproduce.
2. Run `make md-fmt` if the failure is auto-fixable.
3. Re-run `make md-check` before pushing.
