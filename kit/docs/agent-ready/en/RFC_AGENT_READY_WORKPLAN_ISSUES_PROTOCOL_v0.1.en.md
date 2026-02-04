# Agent-Ready WorkPlan <-> Issues Workflow Protocol (Consolidated Draft v0.1, EN)

**Repository:** This kit (and any repository adopting this protocol)
**Status:** Draft
**Audience:** maintainers, contributors, agent-runners
**Goal:** define the development loop and sync between offline-first WorkPlan and GitHub Issues/PR/CI.

---

## 1. Intent

The WorkPlan is the **source of truth** for tasks and requirements. GitHub Issues are the execution queue and control plane (claiming, discussion, PR links, CI status).

Tasks and requirements are edited in the repository via PRs; execution feedback lives in PRs and CI, where contributors and agent-runners iterate to a merge-ready state.

---

## 2. Source of Truth and Canonical Path

The repository MUST choose exactly one canonical WorkPlan path and declare it in configuration (see Planning Backends spec). Supported canonical paths are:

- `DOCS/Workplan.md`
- `specs/workplan.md`

Requirements/PRD files MUST live under the same canonical root (e.g., `DOCS/PRD/**` or `specs/requirements/**`).

---

## 3. Entities

- **Task**: an entry in WorkPlan with stable `TASK_ID`, title, state, priority, deps, and (ideally) acceptance/DoD.
- **Issue**: a materialization of a Task on GitHub. Issues are not the source of requirements.
- **PR**: the unit of execution. One PR per `TASK_ID`.
- **CI**: required checks that implement the quality gates.

---

## 4. Sync Principle

Sync is **one-way for requirements** and **two-way for operational facts**.

- WorkPlan -> Issues: create/update issues from Tasks.
- Issues -> WorkPlan: only operational facts may sync back, and only in strictly limited form (e.g., execution log or status hints). Requirements never sync back from Issues.

---

## 5. Roles and Permissions

- **Maintainers**: final merge authority.
- **Product Owner (PO)**: owns SoT.
- **Infra Owner (IO)**: owns Judge Surface.
- **Contributors**: direct authors and/or agent-runners.

In small projects, PO = IO = Maintainer.

---

## 6. Task States and Events

### 6.1 Canonical States (WorkPlan)
Minimum canonical states:

- `draft`, `ready`, `blocked`, `done`

Only PO/maintainer can move `draft -> ready`. `done` is recorded only after the linked PR is merged.

### 6.2 Operational States (Issues/PRs)
Operational statuses in Issues or planning backends MAY exist, but they are advisory only.
The authoritative execution state is defined exclusively by the PR lifecycle:

- **No PR** → **not in progress**
- **Draft PR** → **in progress**
- **Ready PR** → **in review**
- **Merged PR** → **done**

Additional operational statuses may be tracked in Issues/PRs or execution logs:

- `claimed`, `in-progress`, `in-review`

These do not replace canonical WorkPlan state.

**Rules:**

- Draft PRs are the minimal, provable signal of work in progress (code + branch + history).
- Agents/contributors SHOULD open a Draft PR as soon as the first commit exists, even if the work is incomplete or CI is not yet passing.
- Issue/WorkPlan status SHOULD NOT override the PR lifecycle; when they conflict, trust the PR.

### 6.3 Events
Recommended events:

- `sync_upsert_issue`, `claim`, `unclaim`, `pr_opened`, `ci_failed`, `ci_green`, `changes_requested`, `approved`, `merged`

---

## 7. One PR = One Task

Every Implementation PR MUST be linked to exactly one `TASK_ID`.

- PR title includes `TASK_ID`.
- PR body links to the WorkPlan anchor for the task.

This is a mandatory traceability gate.

---

## 8. Canonical Issue Format

Issues generated from WorkPlan must include a managed section with:

1. **Task**: `TASK_ID` + WorkPlan link
2. **Summary**: task summary
3. **Acceptance / DoD** (if present)
4. **Dependencies**
5. **Constraints**: links to Quality Contract and relevant restrictions
6. **Verification**: canonical commands or links
7. **Control**: claim instructions and change policy

Managed sections are defined by the sync spec (`AI_READY_WORKPLAN_TO_ISSUES_SYNC_v0.1.en.md`).

---

## 9. Labels (Minimum Set)

- Task/flow: `agent-ready`, `needs-maintainer`, `blocked`, `ai-claimed`
- PR type: `spec-change`, `judge-change`
- Change flags: `tests-change`, `deps-change`, `api-change`, `format-change`
- Exceptions: `perf-accepted`, `execution-log`

---

## 10. Claim Protocol

Claiming avoids duplicate work.

- Canonical claim method is repo-defined: either `/claim` commands or `ai-claimed` label.
- Claim identifies the actor (GitHub user) and optionally the tool.
- Unclaim reverses the claim with `/unclaim` or label removal.

Claims do not modify requirements.

---

## 11. PR Opening and Feedback Loop

PRs are the primary feedback channel for agents and reviewers.

- PR title and body include `TASK_ID` and WorkPlan link.
- PR body includes **Verification** and other template sections.
- The contributor iterates until required checks are green and reviews are resolved.

## 12. Closure and Archiving

A task is `done` only after merge of its linked PR.

- Issue is closed on merge or by maintainer when canceled.
- WorkPlan is updated via PR to record `done` and link to merged PR.
- Optional: move task notes to an archive directory per local flow.

---

## 13. Protected Paths Rule

Implementation PRs MUST NOT modify SoT or Judge Surface.

- Any SoT change is a Spec-Change PR with PO approval.
- Any Judge change is a Judge-Change PR with IO approval.

See Quality Contract for full gate definitions.

---

## 14. Non-Goals

- Specific sync tooling implementations.
- Selection of agent providers.
- Reward economics.

---

## 15. Document Map

- Quality gates: `AI_READY_QUALITY_CONTRACT_v0.1.en.md`
- Planning and schema: `AI_READY_PLANNING_BACKENDS_AND_PROFILES_v0.1.en.md`
- WorkPlan -> Issues sync: `AI_READY_WORKPLAN_TO_ISSUES_SYNC_v0.1.en.md`
