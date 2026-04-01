# Revision Execution

Use this reference when the user wants actual manuscript editing, response preparation, or concrete resolution of reviewer comments.

## Goal

Turn reviewer concerns into coherent paper revisions and aligned response-letter updates.

The goal is not merely to add text. The goal is to produce the minimum sufficient revision that genuinely resolves the concern while improving the final paper.

## Revision Scope

Use revision execution for a concrete revision target, such as:

- one specific reviewer comment
- a small cluster of closely related comments
- one local manuscript issue tied to several comments

The working unit should be small enough that the manuscript edit, response update, and alignment check can be handled as one coherent task.

## When To Use

Use revision execution when the user asks for:

- manuscript edits
- response-letter drafting or cleanup
- concrete handling of a reviewer comment
- claim narrowing or scope adjustment
- restructuring for clarity
- improvements to notation, framing, literature discussion, or technical explanation

## Workflow

Follow this sequence unless the user asks for a narrower task:

1. `Define the target`
   - Identify the relevant reviewer comment or small comment cluster and assign stable internal IDs such as `R1-C3`.
   - Prefer one coherent revision task per issue cluster rather than one edit per comment.
   - Separate the reviewer’s exact wording from the actual issue that needs to be resolved in the paper.
   - Define the concrete revision target before moving to diagnosis or editing.

2. `Diagnose the issue`
   - Classify the reviewer concern before choosing the fix.
   - Typical issue types:
     - reader-facing ambiguity
     - reviewer-only clarification
     - overstated claim
     - missing evidence
     - validation request
     - pure typo or notation fix
     - novelty or scope challenge
   - For novelty or scope challenges, test whether the current manuscript is:
     - unclear about the object of contribution
     - overstating demonstrated evidence
     - failing to distinguish formulation, inference, and validation

3. `Choose the revision move`
   - Choose the minimum honest revision move that resolves the concern without overstating what the paper now supports.
   - Available moves:
     - manuscript edit plus response update
     - response-only clarification
     - claim adjustment
     - limitation clarification
     - no manuscript change beyond correction in the response
     - added evidence if needed
   - Key judgment rules:
     - Do not decide too early that every comment requires manuscript edits.
     - Do not rely on the response letter alone when the same confusion is likely to affect future readers.
     - When a reviewer asks about an extension or capability, do not collapse these three questions into one.
     - If the formulation genuinely supports something, do not weaken the paper unnecessarily.
     - Distinguish carefully between:
       - already supported by the formulation
       - clarified in the revision
       - not separately validated or elaborated in the present paper
     - If a request cannot be fully implemented, narrow the manuscript claim and explain the limitation clearly.

4. `Edit the manuscript`
   - Read the local manuscript context carefully before editing.
   - Editorial integration:
     - Revise only as much local context as needed to make the final passage read naturally.
     - Do not optimize for minimizing edit operations if that harms flow or clarity.
     - Prefer a coherent local rewrite over a tiny but awkward patch.
     - Additive edits are often fine, but do not append new sentences mechanically when that would make the prose clunky, repetitive, or logically disjoint.
     - Choose the revision style that best fits the local context:
       - add a sentence when the surrounding logic is already sound
       - replace a sentence when the old wording should be superseded
       - locally restructure a short passage when that is the cleanest way to preserve flow
     - Treat revision as editorial integration, not just content accumulation. New material should read as part of the paper rather than as an obvious patch.
   - Manuscript-grounded reasoning:
     - Use the manuscript's own logic, terminology, and modeling objects when answering comments whenever possible.
     - If a reviewer comment seems confused, first identify whether the paper has not clearly defined the object under discussion before deciding how much to concede.
   - Marking revised text:
     - Follow the manuscript's existing revision-marking convention, such as red text, rather than inventing a new marking style.
     - Mark the substantive revised portion of a passage, not necessarily the entire surrounding paragraph.
     - Use revision markup to make real changes visible, not to color large unchanged spans for convenience.
     - If a response letter presents a passage as revised or added, make sure the corresponding quoted manuscript span contains visible revision markup somewhere within it.
     - Keep revision marking consistent across the manuscript, figures, captions, appendix, and any other revised supporting material when those items are cited in the response.
   - Addressing inline comments and placeholders:
     - Treat obvious author notes, placeholders, inline drafting prompts, and revision hints as editing instructions rather than publishable manuscript prose.
     - Use local context to decide whether to implement, rewrite, or remove them.
     - Do not preserve them literally unless they are clearly intended to remain.
     - Do not apply this rule to legitimate notation, citations, editorial interpolation, or other content that is clearly intended to remain in the paper.

5. `Update the response`
   - Response purpose:
     - Update the response letter after the manuscript so it reflects actual implemented changes.
     - Treat the response letter as an argument, not as an edit log.
     - Resolve the reviewer’s concern in prose before using manuscript quotes as evidence.
   - Use of evidence and quotes:
     - If different parts of the response rely on different evidence, place each quote immediately after the point it supports rather than bundling all quotes at the end.
     - For simple typo fixes or pure wording corrections, a direct response without quotation may be better than forced quoting.
     - When quoting from the manuscript, follow the shared conventions in [../SKILL.md](../SKILL.md), especially for wording fidelity, quote-location format, rendered page and section references, and visible revision markup within quoted revised spans.
   - Comparison and framing responses:
     - When comparing with prior work, explain the comparison at the level of the actual inference target, uncertainty target, assumption set, or evidence, rather than relying only on broad labels.

6. `Align and verify`
   - Response-to-manuscript consistency:
     - Confirm that the response letter reflects what was actually implemented.
     - Confirm that response claims do not overstate what the paper now does.
     - If the response says something was revised, clarified, added, removed, or narrowed, confirm that the change is actually visible in the manuscript or supporting files.
   - Quote and location verification:
     - If quoted manuscript text is used, confirm that it matches the manuscript wording source.
     - Confirm that cited page and section locations are correct in the current rendered manuscript.
     - Confirm that quote-location formatting is consistent.
     - If the response presents a quote as revised or added text, confirm that the quoted span contains visible revision markup somewhere within it.
   - Convention alignment:
     - Re-read the shared conventions in [../SKILL.md](../SKILL.md) before finalizing the revision task.
     - Confirm that the manuscript edit, response update, quoted text, quote locations, revision markup, and response style all follow those conventions.
     - Treat convention violations as real revision issues, not cosmetic issues.
   - Global coherence:
     - Make sure the manuscript, figures, appendix, and response letter tell the same story.
     - For scope, novelty, or validation comments, confirm that the framing is consistent across the key manuscript sections and the response letter.
     - Confirm that the final package resolves the real reviewer concern rather than only improving the local wording.

## Logging

Use `revision.log` during revision execution to record durable revision outcomes, not drafting mechanics.

- Logging rules:
  - Read `revision.log` before beginning substantial revision work.
  - After a substantial manuscript edit, append an `edit` entry.
  - After a substantial response-letter update, append an `edit` entry if it materially changes how the reviewer concern is addressed.
  - When revision work produces a durable strategy choice, interpretation, or claim-narrowing decision, append a `decision` entry.
  - When revision work identifies an unresolved issue that should be handled later, append a `todo` entry.
  - When revision work produces a useful durable insight that should persist across sessions, append an `idea` entry.
  - Prefer one combined log entry per coherent revision outcome rather than multiple narrow entries.
  - Do not log intermediate drafting steps, local wording tweaks, or temporary experiments unless they change durable revision state.
- What counts as substantial:
  - materially revises the paper’s framing, claim, scope, or interpretation
  - adds or removes a technical explanation, derivation, limitation, or comparison
  - changes how a reviewer concern is answered in `response.tex`
  - revises a structured passage rather than only a typo-level correction
  - changes manuscript-response alignment in a durable way
- What does not count as substantial by default:
  - typo fixes
  - punctuation cleanup
  - local wording polish with no revision-level effect
  - temporary draft text that is later replaced

## Closing Check

After substantial editing, run a final audit:

- Re-check title, abstract, introduction, methods, figures, appendix, and response letter.
- Remove placeholders, TODOs, colored revision notes, and stale claims.
- Confirm every response claim is true in the revised paper.
