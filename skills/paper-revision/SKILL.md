---
name: paper-revision
version: 0.1.0
description: Use when revising an academic paper and reviewer response package across manuscript, response letter, figures, appendix, and supplementary material. This skill organizes work into startup/context, response-centric checking, and revision execution, with special emphasis on verifying whether reviewer comments are truly addressed.
---

# Paper Revision

Use this skill for journal or conference paper revision work that involves a manuscript plus a reviewer-response package.

Read only the files needed for the current step. Keep the workflow comment-centric rather than file-centric.

## Startup And Context Load

Always do this first, regardless of the task.

1. Check whether `revision.log` exists. If it does, read the whole log.
2. Treat `revision.log` as durable revision memory rather than as an execution trace.
3. Locate the main revision artifacts:
   - manuscript source such as `main.tex`
   - response letter such as `response.tex`
   - figures
   - appendix or supplementary material
   - compiled PDFs if relevant
4. Perform a bounded orientation read:
   - in `main.tex`, read the title, abstract, introduction, contribution framing, and conclusion
   - in `response.tex`, read the overall reviewer/comment structure and the response blocks relevant to the current scope
   - inspect figures, appendix, supplement, or compiled PDFs only if they are clearly relevant to the current task
5. Treat the agent role as a stable workflow role, such as:
   - supervisory
   - editing
   - validation
   Confirm the role with the user when it is not already established.
6. Ask the user to specify or confirm the current task:
   - `Response Check`
   - `Revision Execution`
   Also confirm the current scope when it is not already clear:
   - a reviewer comment such as internal ID `R1-C3`
   - a reviewer cluster such as `Reviewer 2 literature comments`
   - a paper area such as `title and contribution framing`
   - a whole-document task such as `full-paper scan`
7. Read and respect the shared operating rules and conventions before doing task-specific work.
8. Before making durable edits, check the current branch, worktree or checkout target, and `git status`. If multiple worktrees or branches exist, confirm the active edit target and avoid assuming that the current checkout is the intended place for durable changes.

## Task Modes

Use one of these as the primary operating mode after startup.

### Response Check

Use this mode for response-centric review of revision status and reviewer-comment closure.

Read [references/response-check.md](references/response-check.md) before checking comments.

Goal:
- Review reviewer comments through the response letter, either at quick resolution or at detailed resolution.

Typical use cases:
- quick status check
- current revision status
- which comments are likely done
- what remains
- which comments still look risky
- is this comment really addressed
- audit the reviewer responses
- check whether manuscript and response are aligned

Core rule:
- Start from `response.tex` and review comments one by one. Use `quick` resolution for a coarse progress pass and `detailed` resolution for an evidence-based audit.

### Revision Execution

Use this mode when the user wants actual paper editing, response preparation, or concrete resolution of reviewer comments.

Read [references/revision-execution.md](references/revision-execution.md) before editing.

Goal:
- Convert reviewer concerns into coherent manuscript changes and aligned response-letter updates.

Typical use cases:
- address this reviewer comment
- revise the manuscript
- draft or update the response letter
- clean up framing, notation, or literature discussion
- narrow or defend claims based on the current evidence

Core rule:
- Update the manuscript first, then update the response so it reflects what is actually implemented.

## Shared Conventions And Rules

These rules apply across all task modes. Read them during startup and follow them throughout the task.

### Revision Log System

Use `revision.log` as a durable working memory for revision state.

Purpose:
- Record only durable items that should matter in later sessions.
- Preserve substantial edits, important ideas, concrete to-dos, stable findings, and durable decisions.
- Support both automatic logging and explicit user-directed logging.

What to log:
- `edit`
- `idea`
- `todo`
- `finding`
- `decision`

Do not log:
- routine file reads
- temporary exploration
- mode switches
- command-level activity
- short-lived thoughts that do not affect the revision

Automatic logging rule:
- Automatically append to `revision.log` when substantial revision state changes.
- Automatic logging is primarily tied to `Revision Execution`.
- Auto-log substantial manuscript or response edits.
- Auto-log durable ideas or revision decisions that should persist across sessions.
- Auto-log important unresolved issues or concrete to-dos.
- Do not log exploratory work unless it yields a durable outcome.
- `Response Check` normally does not write to `revision.log` unless it produces a durable to-do, decision, idea, or the user explicitly asks to log something.

Manual logging rule:
- If the user explicitly asks to log something, append it to `revision.log` even if no file edits occurred.
- When the user asks to log something, preserve the substance of the request rather than rewriting it into a different decision.

Suggested entry categories:
- `edit`
- `idea`
- `todo`
- `finding`
- `decision`

Suggested entry format:

```text
[YYYY-MM-DD HH:MM]
type: edit | idea | todo | finding | decision
scope: short scope label
files: optional comma-separated file list
summary: one concise durable statement
```

Logging style:
- Keep entries concise, factual, and durable.
- Prefer one meaningful entry over several narrow ones.
- Log the revision significance, not the mechanics of how the work was performed.

### Conventions

#### Comment Naming Convention

- Assign stable internal IDs to reviewer comments, such as `R1-C3`, `R2-C1`, or `AE-C2`.
- If a reviewer has a general comment before numbered comments, label it as `C0`, for example `R1-C0`.
- Use these IDs only for internal tracking and internal communication across manuscript edits, response checks, and log entries.
- If one revision task addresses several closely related comments, list all relevant IDs together rather than inventing a new category.

#### Internal Quote Naming Convention

- When a response contains quoted manuscript revisions, assign stable internal quote IDs such as `R1-C3-Q1`, `R1-C3-Q2`, or `R2-C1-Q1`.
- Use these IDs only for internal tracking and internal communication during response checking or cleanup.
- Treat each quote as a separate object when verifying wording accuracy, location accuracy, and formatting consistency.

#### Response And Manuscript Alignment Conventions

Use these rules whenever the response letter quotes revised manuscript text:

- Treat `main.tex` or the manuscript source as the wording source of truth.
- Treat the generated PDF as the location source of truth for fixed rendered numbering and page placement.
- Use one consistent quote-location format throughout the response letter, preferably `Page X, Section Y`.
- Do not mix formats such as `Introduction` in one place and `Section 1` in another when both refer to manuscript locations.
- After manuscript restructuring, re-check quote locations against the current rendered PDF rather than relying on older page or section numbers.
- If the response presents a passage as revised or added, the corresponding quoted passage in the manuscript should contain visible revision markup somewhere within that quoted span.
- Do not require the entire quoted paragraph to be revision-marked; unchanged surrounding context may remain unmarked.
- Do not use manuscript `\ref{...}` labels inside `response.tex` when the response letter is compiled separately.
- Replace cross-file references with rendered labels from the PDF, such as `Appendix B`, `Section 5.1`, or `Equation (4)`.
- Bibliography citations are an exception to the cross-file-reference rule. When quoted manuscript text contains `\cite{...}` commands and the response letter can compile against the shared bibliography, preserve those citations rather than stripping them out.
- Prefer quoting only the minimum revised passage needed to answer the reviewer comment.
- Keep the response letter honest: quote only text that actually exists in the manuscript source.
- Before editing the response letter, inspect the repository's existing response-letter conventions and follow them rather than inventing a new format.
- Learn local conventions from the current source files, macros, and compiled outputs when available.
- Do not rely on automatic cross-file numbering inside the response letter.
- Write reviewer responses as self-contained arguments, not as placeholders followed by quotes.
- Answer the reviewer’s actual concern directly and explicitly.
- State your understanding of the issue, the reasoning behind the fix, and what changed in the manuscript.
- Use quoted revised text as supporting evidence, not as a substitute for explanation.
- Integrate quotes organically into the response flow instead of mechanically appending them at the end.
- Keep the response professional, concise, and specific to the reviewer’s comment.
- Make sure the logic of the response corresponds clearly to the logic of the comment.
- Treat the response letter as an argument, not as an edit log.
- Resolve the reviewer’s concern in prose before using manuscript quotes as evidence.
- Separate the reviewer’s exact wording from the actual issue that needs to be resolved in the paper.
- If different parts of the response rely on different evidence, place each quote immediately after the point it supports rather than bundling all quotes at the end.
- For simple typo fixes or pure wording corrections, a direct response without quotation may be better than forced quoting.
- When comparing with prior work, explain the comparison at the level of the actual inference target, uncertainty target, assumption set, or evidence, rather than relying only on broad labels.
