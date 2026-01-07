# General rules

- Assume all programs are for single-user private use, not multi-user or production use SaaS services
- Before completing a task you MUST build the project using `task build`
- Add basic tests for all new features, no need to aim for 100% coverage. Something is better than nothing
- When an Web related task is finished, you MUST confirm its functionality with playwright before claiming the task is done
- Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- `rg` and `fd` are available, use them instead of grep and find if possible

## Python

- Use uv to manage Python projects and run python inside projects
  Example: `uv run python`
- When running `ruff` always use `--fix` to let it automatically fix easy issues to save time

## Facts

- The latest Go version is 1.25
- `task lint` MUST always pass without errors.
- Always use `bd ready` to see what task is next on the list
- if llm-shared exists in the project, do not edit it without explicit permission
