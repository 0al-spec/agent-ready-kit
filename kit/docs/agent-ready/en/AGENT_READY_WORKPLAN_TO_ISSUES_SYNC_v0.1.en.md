# Agent-Ready WorkPlan -> GitHub Issues Sync (Consolidated Draft v0.1, EN)

**Repository:** This kit (and any repository adopting this spec)
**Status:** Draft
**Audience:** maintainers, contributors, agent-runners, tooling authors
**Goal:** define deterministic WorkPlan -> Issues sync and immutable fields.

---

## 0. Context

This spec connects:

- `AI_READY_QUALITY_CONTRACT_v0.1.en.md` (quality gates)
- `AI_READY_WORKPLAN_ISSUES_PROTOCOL_v0.1.en.md` (workflow)

It defines idempotent, deterministic synchronization from WorkPlan to Issues.

---

## 1. Principles

1. **Source of Truth**: requirements and tasks live in the WorkPlan/PRD in the repo.
2. **Issues are mirrors**: Issues are for queue, discussion, and control plane.
3. **Idempotency**: repeated sync produces no duplicates and converges to canonical state.
4. **Immutable anchors**: `TASK_ID` and WorkPlan link never change on update.
5. **Minimize writes**: update only if canonical content differs.
6. **Safe-by-default**: no auto-closing by guess; closure is tied to merge or explicit `done` with proof.

---

## 2. Canonical WorkPlan Path

The repository MUST choose exactly one canonical WorkPlan path and record it in sync config:

- `DOCS/Workplan.md` or
- `specs/workplan.md`

---

## 3. Sync Configuration

Recommended file: `DOCS/ISSUE_SYNC.yml` (name is not mandatory).

Minimum parameters:

- `workplan_path`
- `repo` (optional, if derived from CI env)
- `labels` (state/tag mapping)
- `issue_title_template`
- `issue_body_template_version`
- `ai_ready_criteria`

---

## 4. Task Data Model (Input to Sync)

Each task extracted from WorkPlan MUST have:

### 4.1 Required

- `task_id`: stable unique ID
- `title`: short name
- `stage`: phase/epic/group (may be empty but should exist)
- `priority`: numeric or enum
- `state`: at least `draft|ready|blocked|done`
- `source_ref`: anchor link to canonical WorkPlan

### 4.2 Optional

- `deps[]`: list of `task_id`
- `acceptance[]`: acceptance criteria
- `dod[]`: definition of done
- `constraints[]`
- `tags[]`
- `notes`
- `owner_hint`: e.g. `needs-maintainer`

### 4.3 Parsing Rules

- Parsing must be robust to Markdown formatting differences.
- If `task_id` cannot be extracted, the task is ignored or marked as parse error (per config).

---

## 5. Canonical Task -> Issue Mapping

### 5.1 Issue Title

Default format:

`[<TASK_ID>] <title>`

`TASK_ID` is immutable.

### 5.2 Issue Body (Managed Section)

Managed body contains:

1. **Task**: `TASK_ID` + WorkPlan link
2. **Summary**
3. **Acceptance / DoD**
4. **Dependencies**
5. **Constraints** (including links to Quality Contract and local restrictions)
6. **Verification** (canonical commands or links)
7. **Control** (claim instructions and change policy)

### 5.3 Managed Header Marker

The managed section MUST include a header marker, e.g.:

`<!-- ISSUE_SYNC: v0.1; TASK_ID=...; WORKPLAN=... -->`

This enables safe updates and template migrations.

---

## 6. Managed vs Unmanaged Fields

### 6.1 Managed by Sync

- Issue title (unless disabled)
- Issue body within managed markers
- Labels derived from Task state and criteria

### 6.2 Unmanaged

- Comments and discussion
- Reactions
- Manual notes outside managed markers

Recommended practice: keep a "Manual Notes" section below the managed block.

---

## 7. State -> Label Mapping (Recommended)

- `draft` -> `needs-maintainer` (or none, repo choice)
- `ready` -> no special labels; if agent-ready criteria met, add `agent-ready`
- `blocked` -> `blocked`
- `done` -> close issue and/or label `done`

---

## 8. Agent-Ready Criteria (when a task can be autonomous)

A task gets `agent-ready` only if all conditions are true:

1. `task_id` and `title` exist
2. `state = ready`
3. At least one of: acceptance, DoD, or PRD link
4. No blocking deps (all deps are `done` or absent)
5. No `owner_hint = needs-maintainer` and no `unsafe` tag
6. Verification commands/links exist

---

## 9. Upsert Algorithm (Deterministic)

1. Parse WorkPlan -> tasks
2. For each task, compute canonical title/body/labels
3. Locate existing issue by:
   - `TASK_ID` in title, and/or
   - `ISSUE_SYNC` marker with `TASK_ID`
4. If no issue exists: create (subject to publish policy)
5. If exists: update managed fields only if different
6. If issue exists but task removed: do not close automatically; optionally label `orphaned`

---

## 10. Publish Policy (When to Create Issues)

Recommended:

- create for `ready` and `blocked`
- optional for `draft`
- do not create for `done`

---

## 11. Closing Issues

Canonical rule: close on merge of the linked PR.

Optional: close if WorkPlan state is `done` and includes link to merged PR or commit.

---

## 12. Claim and PR Links

Claim is an operational fact in Issues.

- Sync does not remove claims.
- Sync may display PR link if deterministically sourced.

Optional future command format:
`/link-pr #123`

---

## 13. Errors and Diagnostics

Sync MUST report:

- created/updated issues
- parse errors (tasks that failed extraction)
- duplicate `TASK_ID` (fail-fast)

---

## 14. Security

Sync runs with minimal permissions:

- Issues read/write
- Repo read

It MUST NOT modify code, PRs, or workflows.

---

## 15. Versioning

- Spec versions are explicit (v0.1, v0.2, ...)
- Issue body template version is controlled by `issue_body_template_version`
- Breaking changes require migration notes

---

## 16. Non-Goals

- Specific tooling or GitHub Actions implementation
- Reward economics
- Planning UX tooling
