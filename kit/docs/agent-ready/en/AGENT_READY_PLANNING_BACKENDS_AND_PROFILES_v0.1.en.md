# Agent-Ready Planning Backends and Profiles (Consolidated Draft v0.1, EN)

**Repository:** This kit (and any repository adopting this spec)
**Status:** Draft
**Audience:** maintainers, contributors, agent-runners, tooling authors
**Goal:** support multiple planning styles without losing a single offline-first source of truth.

---

## 1. Intent

Teams plan differently: Scrum, Kanban, Markdown lists, graphs, or agent memory systems.

This spec introduces a minimal shared language that enables:

- exactly one **canonical source of truth** for requirements and tasks,
- optional **mirror** backends for execution and navigation,
- a **Task Core Schema** understood by tools and agents,
- a **Planning Profile** that formalizes readiness/done criteria.

---

## 2. Terms

- **Planning Backend**: a system or format representing the plan (file, graph, external service).
- **Canonical Backend**: the only backend considered source of truth.
- **Mirror Backend**: a derived projection used for execution convenience.
- **Planning Profile**: a formal declaration of readiness/done criteria and task expectations.

---

## 3. Single Source of Truth Requirement

The repository MUST choose exactly one Canonical Backend.

- All requirements and task definitions are edited only via the canonical backend.
- Mirror backends are caches/projections and cannot define requirements.

This prevents “two editors of truth”.

---

## 4. Task Core Schema (Minimal Task Language)

All backends MUST be able to represent the following fields.

### 4.1 Required Fields

- `task_id`: stable unique ID
- `title`: short name
- `state`: minimum `draft|ready|blocked|done` (extensible)
- `priority`: numeric or enum
- `deps[]`: list of dependent `task_id` (may be empty)
- `source_ref`: link/anchor to canonical WorkPlan entry

### 4.2 Recommended Fields

- `stage`: phase/epic/group
- `acceptance[]`: acceptance criteria
- `dod[]`: definition of done
- `tags[]`: capability or risk tags
- `owner_hint`: e.g. `needs-maintainer`, `maintainer-only`
- `notes`: short context

### 4.3 Extensions

Additional fields are allowed if they:

- do not change Task Core meaning,
- are serialized and stable,
- are not the only source of requirements.

Recommended prefix for non-standard fields: `x_...` or `X-...`.

---

## 5. Planning Profile (How We Plan Here)

The Planning Profile defines readiness and done criteria and is stored in the repo (e.g., `DOCS/PLANNING_PROFILE.md` or `.yml`).

### 5.1 Minimum Parameters

- `profile_name`: `light|standard|strict` (or custom)
- `definition_of_ready`
- `definition_of_done`
- `ai_ready_criteria`
- `task_types`
- `risk_tags`

### 5.2 Profile Guidance

- **light**: title + state + verification links
- **standard**: acceptance or PRD link + deps + constraints
- **strict**: acceptance + DoD + strict diff coverage + explicit gates

---

## 6. Backend Registry

The repo should declare backends in a registry file (e.g., `DOCS/PLANNING_BACKENDS.yml`).

Minimum structure:

- `canonical`: backend id (e.g., `markdown-workplan`)
- `backends[]`: list of backends with parameters
- `mirrors[]`: list of mirror backends and sync rules

---

## 7. Canonical Backend: markdown-workplan

### 7.1 Purpose

Offline-first backlog stored in the repo, editable via PRs.

### 7.2 Requirements

- Each task has a `task_id`.
- `ready` implies `definition_of_ready` is satisfied.
- Requirements/PRD files live under canonical root.

### 7.3 Recommendation

Keep operational execution notes separate (e.g., `Workplan.execution.md`) so Implementation PRs do not modify SoT.

---

## 8. Mirror Backends (Example: Beads)

### 8.1 Role

Beads is a **mirror** backend (execution/memory graph), not a source of requirements.

### 8.2 Mapping

- `task_id` is the anchor in beads metadata
- `deps` map to graph edges
- `state` maps to bead status fields
- `source_ref` links back to canonical WorkPlan

### 8.3 Change Rule

- Mirror changes are proposals only.
- Any change to the canonical plan must be a Spec-Change PR with PO approval.

---

## 9. Import/Export Rules

- Canonical -> Mirror: allowed and safe.
- Mirror -> Canonical: only via Spec-Change PR and PO approval.
- Transformations must be deterministic and reproducible.

---

## 10. Compatibility

This spec supports multiple planning styles while enforcing:

- one canonical source of truth,
- a minimal shared Task language,
- formal planning expectations,
- safe transformations.

---

## 11. Document Map

- Quality gates: `AI_READY_QUALITY_CONTRACT_v0.1.en.md`
- WorkPlan/Issues workflow: `AI_READY_WORKPLAN_ISSUES_PROTOCOL_v0.1.en.md`
- WorkPlan -> Issues sync: `AI_READY_WORKPLAN_TO_ISSUES_SYNC_v0.1.en.md`

---

## 12. Non-Goals

- Choosing a single planning framework for everyone.
- Implementations of import/export tools.
- Planning UX tooling.
