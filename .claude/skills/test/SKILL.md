---
name: test
description: Run tests for the Phlexible gem across the Appraisal matrix
arguments:
  - name: appraisal
    description: "Appraisal to test: phlex1-rails7, phlex1-rails8, phlex2-rails7, phlex2-rails8, or 'all' (default: phlex2-rails8)"
    default: "phlex2-rails8"
  - name: file
    description: "Optional test file path, or path:line for a single test"
disable-model-invocation: true
---

Run Phlexible tests using the Appraisal gem for multi-version testing.

## Instructions

1. If `appraisal` is "all", run: `bundle exec appraisal rails test {file}`
2. Otherwise, run: `bundle exec appraisal {appraisal} rails test {file}`
3. If no `file` is given, omit it to run the full suite for that appraisal.
4. Report pass/fail/skip counts from the test output.
5. If tests fail, summarise which tests failed and why.
