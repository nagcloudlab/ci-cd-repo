# GitHub Actions – Step 01  
## Hello World Workflow (Foundation)

---

## Objective

- Create the first GitHub Actions workflow
- Understand workflow execution basics
- Trigger automation on every push to `main`
- Run simple shell commands on a GitHub runner

---

## Repository Structure

```
ci-cd-with-github-actions/
└── .github/
    └── workflows/
        └── 01-hello-ci.yml
```

---

## Concepts Introduced in This Step

This step introduces only the following concepts:

- Workflow
- Event (Trigger)
- Job
- Step
- Runner

---

## What Is a Workflow?

- A workflow is an automation definition written in YAML
- Stored under `.github/workflows/`
- Executed when a configured event occurs
- A repository can have multiple workflows

---

## Trigger Configuration (`on`)

- `push`  
  Triggers the workflow when code is pushed to the repository

- `workflow_dispatch`  
  Allows manual execution from GitHub Actions UI

---

## Job Definition

- A job is a group of steps
- Jobs run on GitHub-hosted virtual machines
- `ubuntu-latest` is the most commonly used runner

---

## Steps

- Steps execute sequentially
- Each step runs shell commands
- Multiline commands use pipe (`|`) syntax

---

## Workflow File: `01-hello-ci.yml`

```yaml
name: 01 - Hello CI

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  hello:
    runs-on: ubuntu-latest

    steps:
      - name: Print greeting
        run: echo "Hello from GitHub Actions"

      - name: Display OS information
        run: uname -a

      - name: Display current user and working directory
        run: |
          whoami
          pwd

      - name: List files (repository not checked out yet)
        run: ls -la
```

---

## Expected Execution Result

- Workflow appears in the **Actions** tab
- Job runs on an Ubuntu runner
- Logs show:
  - Greeting output
  - OS information
  - Runner user and working directory
  - Limited file listing

---

## Important Observation

- Repository source code is not available yet
- This is expected behavior
- Repository checkout is a separate concept

---

## Key Takeaways

- GitHub Actions is event-driven
- Workflows are defined using YAML
- Jobs run on temporary virtual machines
- Steps execute sequential shell commands

---

## Validation Checklist

- Workflow triggers on push to `main`
- Workflow can be triggered manually
- All steps complete successfully
- No YAML indentation errors

---

**Next Step:**  
Step 02 – Checkout Repository Code using `actions/checkout`
