# Contribution guide

Thank you for your interest in this project! This document contains the naming conventions and commit message guidelines used in this repository.

## Naming conventions

### Modules & exported values

- Use **PascalCase**.
- Applies to:
  - Modules
  - Exported functions

**Example:**

```luau
local Module = {}

Module.SomeValue = "Hello, world!"

function Module.DoSomething()
end

return Module
```

### Local functions & variables

- Use **camelCase**.
- Applies to:
  - Local functions
  - Local variables

**Example:**

```luau
local function add(x: number, y: number): number
    return x + y
end
```

### Constants

- Use **UPPER_SNAKE_CASE**

**Example:**

```luau
local VERY_IMPORTANT_VALUE = 100
```

## Commit message conventions

This project follows the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) style.

Try to commit your work in small chunks, with descriptive and clear names.

**Examples:**

```
feat: add datastore call retries on failure
```

```
fix: fix `Collection:Update()` delaying after being aborted
```

```
chore: update package version
```

```
refactor: reorder variables
```

```
style: fix indentation
```

```
docs: update README.md
```

## Pull request guidelines

> **IMPORTANT:** Pull requests will be declined if the commit message conventions were not followed.

- Include a clear description of changes.
- Reference related issues (if applicable).
- Ensure your code follows the naming conventions above.
- Test your changes before submitting.

## Pull request checklist

- [ ] Code is formatted using StyLua
- [ ] Changes tested
- [ ] Commit messages follow the conventions mentioned above
