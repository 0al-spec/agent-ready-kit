# Agent-Ready Contribution Quality Contract (Consolidated Draft v0.1, EN)

**Repository:** This kit (and any repository adopting this contract)
**Status:** Draft
**Audience:** maintainers, reviewers, contributors, agent-runners
**Goal:** reproducible, safe, and auditable PRs at scale, including autonomous agents.

---

## 1. Intent

We want any contributor or agent-runner to:

1. select a task from the repository WorkPlan,
2. prepare a PR that **objectively** passes quality gates,
3. receive clear CI/review feedback and iterate to a merge-ready state.

At the same time, the repository must be protected against:

- **judge tampering** (weakening CI/merge rules within the same PR),
- **source-of-truth tampering** (rewriting the task/requirements to fit the result),
- regressions masked by “green CI”.

---

## 2. Terms and Surfaces

### 2.1 Source of Truth (SoT)
The canonical plan and requirements stored in the repository. The repo MUST choose exactly one canonical WorkPlan path and record it in configuration (see Planning Backends spec).

### 2.2 Judge Surface
Files that define validation and merge policy, including:

- `.github/workflows/**`
- lint/format/coverage/perf configs
- CI scripts, policy configs, release pipelines

### 2.3 Implementation Surface
Code, tests, docs, examples, and other artifacts that implement tasks, e.g.

- `Sources/**`, `Tests/**`, `Docs/**`, `Examples/**`

---

## 3. PR Types

- **Implementation PR**: implements exactly one WorkPlan task.
- **Spec-Change PR**: modifies Source of Truth (WorkPlan/requirements).
- **Judge-Change PR**: modifies CI/workflows/policy (Judge Surface).

**Rule:** Implementation PRs MUST NOT modify SoT or Judge Surface except for explicitly approved exceptions.

---

## 4. Roles and Permissions

- **Maintainers**: repository owners and final merge authority.
- **Product Owner (PO)**: owner of SoT (WorkPlan/requirements).
- **Infra Owner (IO)**: owner of Judge Surface.
- **Contributor**: PR author and/or agent-runner.

In small projects, PO = IO = Maintainer.

---

## 5. Quality Gates (Mandatory for Every PR)

### Gate 0 - Traceability
**Rule:** Every Implementation PR references exactly one task by stable `TASK_ID`.

**Requirements:**
- PR title: `[<TASK_ID>] <short summary>`
- PR body: link to the WorkPlan anchor for the task
- Branch (recommended): `task/<TASK_ID>-<slug>`

### Gate 1 - Protected Paths (SoT / Judge)
**Rule:** Implementation PRs MUST NOT modify SoT or Judge Surface.

**Requirements:**
- No changes under canonical WorkPlan/requirements paths.
- No changes under `.github/workflows/**` or policy configs.
- Any such change requires a dedicated Spec-Change or Judge-Change PR.

### Gate 2 - No Weakening of Quality Gates
**Rule:** Quality checks MUST NOT be weakened by indirect changes.

**Requirements:**
- No reduced coverage thresholds.
- No disabling tests.
- No broad allowlists/ignores without explicit PO/IO approval.

### Gate 3 - Reproducible Verification
**Rule:** Verification steps are explicit and copy-paste runnable.

**Requirements:**
- PR body contains a **Verification** section with commands.
- CI runs the same commands or a strict superset.

### Gate 4 - Test Suite Green
**Rule:** Required test suites are green and deterministic.

**Requirements:**
- All required checks pass.
- No flaky tests without isolation or explanation.

### Gate 5 - Diff Coverage (or Changed-Lines Coverage)
**Rule:** Behavior changes are covered by tests; changed lines coverage MUST NOT drop below threshold.

**Requirements:**
- Diff coverage meets threshold (e.g., 90-95%).
- Optional: overall coverage meets target.

### Gate 6 - Test Integrity (if tests changed)
**Rule:** Test changes are visible and justified.

**Requirements:**
- Label `tests-change`.
- PR body includes **Test Changes Rationale** section.
- Optional: CODEOWNERS approval for test owners.

### Gate 7 - Performance/Regression Guard (if applicable)
**Rule:** No perf regressions without explicit acceptance.

**Requirements:**
- Perf checks within thresholds.
- Regressions only with label `perf-accepted` and rationale.

### Gate 8 - Dependency and Supply-Chain Guard
**Rule:** Dependency changes require explicit rationale.

**Requirements:**
- Label `deps-change`.
- PR body includes **Dependency Rationale** section.
- Optional: license/security check.

### Gate 9 - Danger Zones Require Maintainer Review
**Rule:** Public API or format changes require maintainer review.

**Requirements:**
- Label `api-change` or `format-change`.
- Maintainer approval required.
- Documentation/migration notes updated if needed.

---

## 6. Source of Truth Policy (Spec-Change PR)

- Any change to WorkPlan/requirements is a **Spec-Change PR**.
- PO approval is mandatory.
- Avoid mixing large implementation changes into Spec-Change PRs.

**Status transitions:**
- `draft -> ready` only by PO/maintainer.
- `done` only after merge of the linked PR.

---

## 7. Judge Surface Policy (Judge-Change PR)

- Any change to workflows/policies is a **Judge-Change PR**.
- IO approval is mandatory.
- No weakening of gates without explicit maintainer agreement.

---

## 8. PR Template (Minimum Required Sections)

Implementation PRs MUST include:

- **Task**: `TASK_ID` + WorkPlan link
- **What changed**: concise summary
- **Why**: rationale/context
- **Verification**: commands
- **Test Changes Rationale**: if tests changed
- **Risk/Notes**: risks, caveats

---

## 9. Recommended Labels (Minimum Set)

- Task/flow: `agent-ready`, `needs-maintainer`, `blocked`, `ai-claimed`
- PR type: `spec-change`, `judge-change`
- Change flags: `tests-change`, `deps-change`, `api-change`, `format-change`
- Exceptions: `perf-accepted`, `execution-log`

## 9.1 ai-ready-kit Repository Contract (Exact)

This repository adopts the following **exact** conventions for PRs:

**PR title format**

- `[<TASK_ID>] <short summary>`

**Required labels**

- Always: `agent-ready`
- If changing Source of Truth (WorkPlan/requirements): `spec-change`
- If changing Judge Surface (CI/workflows/policy): `judge-change`
- If tests change: `tests-change`
- If dependencies change: `deps-change`
- If API/format changes: `api-change` or `format-change`
- If accepting perf regression: `perf-accepted`

**Required checks**

- **Markdown** (GitHub Actions workflow): runs `make md-check` on PRs that touch `**/*.md`,
  `.markdownlint.yaml`, `.markdownlint-cli2.yaml`, or `Makefile`.

---

## 10. Document Map

- WorkPlan and Issues workflow: `AI_READY_WORKPLAN_ISSUES_PROTOCOL_v0.1.en.md`
- Planning backends and profile: `AI_READY_PLANNING_BACKENDS_AND_PROFILES_v0.1.en.md`
- WorkPlan to Issues sync spec: `AI_READY_WORKPLAN_TO_ISSUES_SYNC_v0.1.en.md`

---

## 11. Non-Goals

- Implementation details of CI/sync tooling.
- Selection of agent providers.
- Reward economics and leaderboards.
