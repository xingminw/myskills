---
name: multi-client-collaboration
version: 0.1.0
description: "Use when work is split across multiple Codex CLI sessions, worktrees, or handoff-style threads and a shared manual coordination protocol is needed. This skill defines the default, simplest collaboration mode: one canonical CONTEXT.md in the main repo folder, with all clients reading and updating it for durable shared state."
---

# Multi-Client Collaboration

Use this skill when the user is coordinating work across multiple CLI sessions, multiple worktrees, or multiple threads that need a shared manual protocol. Also use it when the user gives command-style prompts such as `init context`, `read context`, or `store context`.

This skill defines the default and simplest collaboration mode. It is intentionally lightweight. It does not provide locking, task claiming, or automated synchronization. Future modes may add those, but this skill establishes the baseline behavior.

## Default Mode

The default mode is `manual-context-sync`.

Core rule:

- Maintain one canonical `CONTEXT.md` in the main repo folder.

Implications:

- Reading the main-folder `CONTEXT.md` is mandatory startup behavior.
- If the canonical `CONTEXT.md` does not exist, create it in the main repo folder before substantial work.
- All clients must read the main-folder `CONTEXT.md` before substantial work.
- All clients must update that same file when a durable workflow decision changes.
- Worktrees may be used for editing, but a worktree-local `CONTEXT.md` is not the shared source of truth unless the workspace explicitly declares a different rule.
- Shared coordination markdown files should default to the main folder unless the workspace explicitly declares another rule.

## When To Use

Use this skill when any of the following are true:

- The user mentions multiple CLI sessions, multiple clients, multiple agents, or handoffs across sessions.
- The repo uses git worktrees and the user wants a shared workflow.
- Durable context needs to survive restarts or movement between worktrees.
- The user wants a simple shared coordination mechanism without introducing heavier process.
- The repository already has a `CONTEXT.md` or clearly needs one for ongoing work.
- The user says `init context`, `read context`, `store context`, or a close variant.

## Command Vocabulary

Use these command-style phrases as the default manual protocol:

- `init context`
- `read context`
- `store context`

Interpret them as follows:

### `init context`

- Use the `multi-client-collaboration` skill.
- Identify the main repo folder.
- Find the canonical main-folder `CONTEXT.md`.
- If it does not exist, create it.
- Load the latest shared context.
- State the canonical context path and the active edit target when useful.

### `read context`

- Use the `multi-client-collaboration` skill.
- Read the latest canonical main-folder `CONTEXT.md`.
- Summarize the parts relevant to the current task unless the user explicitly asks for the raw text.

### `store context`

- Use the `multi-client-collaboration` skill.
- Update the canonical main-folder `CONTEXT.md`.
- Store only durable and useful information that future sessions should rely on.

## Required Startup Procedure

Follow this sequence:

1. Identify the current checkout and whether it is a main checkout or a git worktree.
2. Identify the main repo folder.
3. Search for the canonical `CONTEXT.md` in the main repo folder.
4. If it does not exist, create it in the main repo folder.
5. Read the canonical `CONTEXT.md` before substantial work.
6. State which folder is the active edit target for the current task.
7. Update the main-folder `CONTEXT.md` only for durable decisions that future sessions should rely on.

## Repo Discovery

When the current session starts in a worktree, do not treat the worktree folder as the shared-context authority by default.

Use repository structure to identify:

1. The current checkout path
2. Whether it is a main checkout or a worktree
3. The main repo folder
4. The canonical `CONTEXT.md` path in that main repo folder

If the repository layout is ambiguous, resolve that ambiguity before relying on shared context.

## Conflict Rule

- If the current workspace state conflicts with `CONTEXT.md`, do not silently overwrite the shared context.
- Surface the mismatch, reconcile carefully, and ask the user when needed.
- Do not fork parallel shared context files to avoid a conflict unless the user explicitly asks for that.

## CLI Behaviors

### Startup Behavior

- At the start of ongoing repository work, worktree-based work, handoff-style work, or multi-session work, the CLI must locate the main repo folder and load its `CONTEXT.md`.
- If the main-folder `CONTEXT.md` does not exist, the CLI must create it before substantial work.
- Treat the main-folder `CONTEXT.md` as the latest shared context unless the workspace explicitly defines a different protocol.

### Store Behavior

- If the user asks to store context, save useful durable information into the main-folder `CONTEXT.md`.
- Store workflow rules, active worktree information, stable task decomposition, and other information that future sessions should rely on.
- Do not store temporary scratch notes, speculative ideas, or noisy status updates.

### Load Behavior

- If the user asks to load context or load the latest context, read the main-folder `CONTEXT.md`.
- Summarize the relevant contents for the current task instead of dumping the file unless the user explicitly asks for the raw text.

### Shared Markdown Rule

- Shared coordination markdown files must live in the main folder by default.
- Markdown files inside a worktree should be treated as local to that checkout unless the workspace explicitly marks them as shared.

### Worktree Rule

- A worktree is an editing and execution location, not automatically the shared-context location.
- If edits are made in a worktree, durable workflow decisions must still be reflected in the main-folder `CONTEXT.md`.
- Do not create parallel shared `CONTEXT.md` files across worktrees unless the workspace explicitly adopts that protocol.

## Recommended CONTEXT.md Structure

Use a lightweight, durable structure. `CONTEXT.md` is shared state, not a scratchpad.

Recommended sections:

- `Project`
- `Shared Workflow`
- `Stable Decisions`
- `Active Workstreams`
- `Pending Tasks`
- `Open Questions`
- `Change Log`

Suggested contents:

### Project

- Project name
- Overall objective
- Current stage or revision phase

### Shared Workflow

- Canonical context file location
- Main repo folder
- Reference checkout
- Role of the main checkout
- Active worktree paths
- Role of each active worktree
- Branch purposes
- Rule for where edits should happen

### Stable Decisions

- Accepted scope decisions
- Stable terminology or notation
- Structural decisions that future sessions should not rediscover

### Active Workstreams

- Current active branches
- Purpose of each branch or worktree
- Role of each checkout
- Short status where useful
- For the main checkout, prefer recording path, branch, role, purpose, and status
- For each active worktree, prefer recording path, branch, role, purpose, and status

### Pending Tasks

- Durable next tasks
- Reviewer-comment clusters still to address
- Work items that are likely to survive across sessions

### Open Questions

- Unresolved issues requiring user input
- Questions that affect multiple future steps

### Change Log

- High-level, durable workflow or revision updates
- Include date and local time to the minute, for example `2026-03-25 14:37`
- Only add an entry when the change is substantial and future sessions should rely on it
- Brief entries only
- Prefer milestone-style updates over detailed edit diaries

## What To Avoid In CONTEXT.md

- Temporary scratch notes
- Verbose command logs
- Minute-by-minute progress updates
- Trivial or non-substantial change-log entries
- Line-by-line edit inventories
- Information already obvious from git history unless it is needed for handoff clarity

## Quality Rule

Every entry in `CONTEXT.md` should help a future session make a decision faster.

## Example Minimum Template

```md
# Shared Context

## Project
- Name:
- Objective:
- Current stage:

## Shared Workflow
- Canonical context file:
- Main repo folder:
- Reference checkout:
- Main checkout role:
- Active worktree(s):
- Worktree roles:
- Edit rule:

## Stable Decisions
- ...

## Active Workstreams
- Branch:
  Path:
  Role:
  Purpose:
  Status:

## Pending Tasks
- ...

## Open Questions
- ...

## Change Log
- YYYY-MM-DD HH:MM: ...
```

## What Belongs In Shared Context

Good shared context:

- Active worktree path
- Active branch name
- Main repo folder path
- Which checkout is the reference copy
- Which checkout is the current edit target
- The role of the main checkout
- The role of each worktree
- Stable workflow rules
- Durable task decomposition decisions
- Open questions that affect multiple future threads

Do not store:

- Temporary scratch notes
- Speculative ideas that have not been accepted
- Verbose progress logs
- Repetitive status updates that will go stale quickly
- Non-substantial change-log entries

## Change Log Rule

- Use local time and record timestamps to the minute in `YYYY-MM-DD HH:MM` format.
- Add a change-log entry only for durable, substantial changes such as workflow-rule changes, role changes for the main checkout or a worktree, branch handoffs, milestone completions, or decisions that affect future sessions.
- Do not log routine progress, minor edits, or temporary experimentation.

## Checkout Role Rule

- Record the role of the main checkout explicitly, for example `reference checkout`, `integration checkout`, or `canonical context owner`.
- Record the role of each active worktree explicitly, for example `feature implementation`, `review fix`, `validation`, or `release prep`.
- Keep roles short and operational so another session can decide where to work next without rediscovering intent.

## Worktree Rules

- The main checkout is the canonical location for shared context unless the workspace explicitly documents another protocol.
- A worktree is an execution and editing location, not automatically the shared-context location.
- If edits are made in a worktree, shared workflow decisions should still be reflected in the main-folder `CONTEXT.md`.
- If multiple worktrees exist, record enough information in the canonical context to distinguish their purposes.

## Response Behavior

When this skill is active:

- Briefly state that you are using the manual shared-context protocol.
- If needed, state the canonical `CONTEXT.md` path and the active edit target.
- Keep context updates minimal and durable.
- Avoid inventing heavier coordination mechanisms unless the user asks for them.

## Future Extensions

This skill only defines the baseline mode. Future collaboration modes may add:

- Ownership or task-claiming rules
- Lock files
- Structured context schemas
- Branch-routing conventions
- Merge or handoff protocols

If a stronger collaboration mode is later introduced, it must explicitly override `manual-context-sync` rather than silently replacing it.
