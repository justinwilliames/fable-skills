---
name: testing-standards
description: >
  Use this skill when the user invokes /testing-standards, asks about the project's testing approach, asks how to write tests, asks what tests to write for a feature, or needs a reminder of TDD workflow. Also trigger when the user says "write tests first", "what tests do I need", "set up testing", or "add tests for X". This skill defines the canonical testing philosophy, tooling, file conventions, and Claude's own rules for writing tests. Do NOT invoke for a project with no test runner configured — fill in the "Before first use" section below first.
---

# Testing Standards

## Before first use

Fill in the following for the project before relying on this skill:

- **Test runner:** [e.g. Vitest, Jest, Pytest — replace the placeholder in § Test Suites below]
- **Unit test command:** [e.g. `npm run test`]
- **E2E test command:** [e.g. `npm run test:e2e`]
- **Full suite command:** [e.g. `npm run test:all`]
- **Key user flows to cover:** [list the primary E2E journeys specific to this project]

Until these are filled in, this skill is a template, not a working standard.

## Failure modes

| Situation | What to do |
|---|---|
| **Broken suite on arrival** | Run the full suite first. Fix or flag every pre-existing failure before writing new tests — never add tests on top of a red suite. |
| **Missing runner** | If no test runner is configured for the project, stop. Tell the user to install and configure one, then fill in "Before first use" above. Do not invent or assume a runner. |
| **CI-only tests** | If tests are configured to run only in CI (no local runner), say so explicitly. Do not claim local verification has passed — it hasn't. |

## Philosophy: Test-Driven Development

All new features must follow TDD. No exceptions.

**The workflow:**
1. Before writing any feature code, write tests covering all expected flows and edge cases
2. Run the tests — they should all fail (this confirms the tests are real and wired up correctly)
3. Build the feature incrementally until every test passes
4. Never mark a feature done until all tests are green

This catches edge cases early, prevents regressions, and gives future changes a safety net.

---

## Test Suites

### 1. Unit / Integration Tests
- Test individual functions, components, hooks, and API handlers in isolation
- Cover: happy path, edge cases, error states, boundary values
- Tool: [Vitest / Jest — pick one and note it here]
- Location: `__tests__/` alongside source files, or `*.test.ts` co-located

### 2. End-to-End Tests
- Test complete user flows through the real browser (no mocks for the critical path)
- Cover: every major user journey from entry point to completion
- Tool: Playwright
- Location: `e2e/`

**Flows to cover (update this list as the app grows):**
- [ ] User can sign up and land on dashboard
- [ ] User can [core action #1]
- [ ] User can [core action #2]
- [ ] Error states show correctly (network failure, 404, validation)
- [ ] Auth gates redirect unauthenticated users

### 3. UI Regression / Screenshot Tests
- Run through the app in a headless browser and capture screenshots at every meaningful state
- Compare against baseline images; flag any pixel diffs
- Tool: Playwright (built-in screenshot + visual comparison)
- Location: `e2e/screenshots/` for baselines, `e2e/screenshots/diff/` for failures

**States to capture for every major screen:**
- Empty state (no data)
- Loaded state (with realistic test data)
- Error state
- Loading/skeleton state (if applicable)
- Mobile viewport (375px)
- Dark mode (if supported)

**To review all screenshots at once:**
```bash
open e2e/screenshots/
# or
npx playwright show-report
```
This gives a quick visual skim of the entire app across all states — useful before any major merge.

---

## Running Tests

```bash
# Unit tests
npm run test

# Unit tests in watch mode (during development)
npm run test:watch

# E2E + screenshots (headless)
npm run test:e2e

# Update screenshot baselines (after intentional UI changes)
npm run test:e2e -- --update-snapshots

# Full suite (run before every commit)
npm run test:all
```

---

## Rules for Claude When Writing Code

1. **Writing a new feature?**
   - Write the test file first
   - Include: happy path, at least two edge cases, one error state
   - Run tests, confirm they fail, then start implementing
   - Keep building until all tests pass before moving on

2. **Modifying existing code?**
   - Run `npm run test:all` before starting
   - Run again after every meaningful change
   - If any test fails that wasn't failing before: fix it immediately, don't continue building

3. **Adding a new screen or major UI component?**
   - Add screenshot captures for all relevant states in `e2e/visual.spec.ts`
   - Run `npm run test:e2e` and review the new screenshots before proceeding

4. **Never leave a test suite in a broken state.**
   - If tests are failing and you can't immediately fix them, stop and explain why before continuing
   - A green test suite is a prerequisite for any new work

---

## Test Data

Keep realistic test fixtures in `tests/fixtures/`. Use these consistently across unit, E2E, and screenshot tests so results are reproducible and comparable.

---

## Screenshot Baseline Updates

When you *intentionally* change the UI (new design, refactor), update baselines explicitly:

```bash
npm run test:e2e -- --update-snapshots
```

Then commit the updated PNGs alongside the code change. Reviewers can visually diff the screenshots in the PR to confirm the change looks right.

## Sync home

Sync home: canonical = your live private copy; public sanitized twin: ~/code/skills/testing-standards → github.com/justinwilliames/skills. Sanitization is a sync step.
