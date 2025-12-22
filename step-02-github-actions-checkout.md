# GitHub Actions – Step 02  
## Checkout Repository Code (actions/checkout)

---

## Objective

- Understand why repository checkout is required
- Learn how GitHub Actions accesses repository source code
- Use the official `actions/checkout` action
- Verify repository files inside the runner

---

## Prerequisite

- Step 01 workflow executed successfully
- Repository contains at least one file (README or source code)

---

## New Concept Introduced

This step introduces exactly one new concept:

- **Using an Action** (`uses:`)

Everything else remains the same.

---

## Problem Without Checkout

By default:
- GitHub runner does **not** contain your repository code
- Only workflow metadata is available
- Commands like `ls` will not show your project files

This is intentional for security and performance.

---

## What Is `actions/checkout`?

- Official GitHub Action maintained by GitHub
- Downloads repository code into the runner
- Makes source files available for build, test, scan, deploy steps
- Must be explicitly invoked

---

## Syntax: Using an Action

```text
uses: owner/repository@version
```

Example:
```text
uses: actions/checkout@v4
```

---

## Updated Workflow File: `02-checkout-repo.yml`

> Paste this inside a YAML code block

```yaml
name: 02 - Checkout Repository

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  checkout-demo:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Show repository files
        run: ls -la

      - name: Show current directory
        run: pwd
```

---

## What Happens During Execution

- GitHub creates a new Ubuntu runner
- Repository code is cloned into the runner
- Working directory becomes the repository root
- All project files become accessible

---

## Expected Output

After checkout step:
- `ls -la` shows:
  - `.github/`
  - `README.md`
  - Source folders (if any)

Before checkout:
- These files were not visible

---

## Key Takeaways

- Checkout is **not automatic**
- `uses:` executes a reusable action
- `actions/checkout` is required for almost all real workflows
- Version pinning (`@v4`) is a best practice

---

## Validation Checklist

- Workflow runs successfully
- Checkout step completes without error
- Repository files are visible in logs

---

**Next Step:**  
Step 03 – Running a Build Command (Example: Java / Node / Shell)
