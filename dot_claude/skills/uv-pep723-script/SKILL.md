---
name: uv-pep723-script
description: Use this skill when creating Python scripts that use PEP 723 inline script metadata with uv, or when the user asks to "write a uv script", "create a standalone Python script with dependencies", "make a script that runs with uv run", or wants a self-contained Python script with automatic dependency management.
version: 1.0.0
---

# PEP 723 + uv Inline Script Metadata

Use this format for standalone Python scripts that self-describe their dependencies and run with `uv run`.

## Required Header

Every script must start with this exact structure:

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "package-name",
#     "another-package>=1.0",
# ]
# ///
"""Module docstring describing what the script does."""
```

## Rules

- The shebang MUST be `#!/usr/bin/env -S uv run --script` — this allows direct execution (`./script.py`) without pre-installing anything
- The `# /// script` block MUST appear immediately after the shebang, before any other code
- `requires-python` specifies the minimum Python version; default to `">=3.12"` unless the user specifies otherwise
- `dependencies` is a list of PyPI package names, optionally with version constraints (PEP 508 syntax)
- Omit `dependencies` entirely if the script has no third-party dependencies
- After the closing `# ///`, add a module-level docstring

## Running Scripts

```bash
# Run directly (if executable)
chmod +x script.py
./script.py

# Run via uv
uv run script.py

# Run with extra args
uv run script.py --arg value
```

## Example: Minimal Script

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "httpx",
#     "rich",
# ]
# ///
"""Fetch a URL and pretty-print the JSON response."""

import httpx
from rich import print_json

response = httpx.get("https://httpbin.org/json")
print_json(response.text)
```

## Example: No Dependencies

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# ///
"""Script using only the standard library."""

import sys
print(f"Python {sys.version}")
```

## Version Constraints

Use standard PEP 508 specifiers in the dependencies list:

```python
# "requests>=2.28"          # minimum version
# "pandas~=2.0"             # compatible release
# "numpy>=1.24,<2.0"        # range
# "mypackage==1.2.3"        # exact pin
```

## Notes

- uv creates an isolated virtual environment per script automatically; no manual venv management needed
- The script is fully portable — anyone with uv installed can run it without setup
- Use `uv add --script script.py package-name` to add dependencies to an existing script via CLI
