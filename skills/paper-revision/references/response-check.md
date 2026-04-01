# Response Check

Use this reference when reviewing revision progress through the response letter.

Scope can be `single-comment`, `cluster`, or `full-response`.
Resolution can be `quick` or `detailed`.
In all cases, start from `response.tex` and review reviewer comments one by one within the chosen scope.
The user may also specify a particular checking focus, such as quoted-text accuracy, manuscript-response alignment, or whether a response truly closes the reviewer concern.

## Goal

Check reviewer comments through the response letter in a way that makes unfinished work visible.

The output should help answer:

- Which comments look addressed?
- Which comments remain incomplete?

The unit of tracking is one reviewer comment, identified by a stable internal ID such as `R1-C3`.
If a reviewer has a general comment before numbered comments, refer to it as `C0`, for example `R1-C0`.
When needed, quoted manuscript blocks can also be tracked with internal quote IDs such as `R1-C3-Q1`.

## Workflow

1. Choose the scope:
   - one specific comment
   - a cluster of comments
   - the full response letter
2. Identify any user-specified checking focus:
   - quoted manuscript text is accurate
   - manuscript and response are aligned
   - the response truly closes the reviewer concern
   - the response is sufficiently direct or complete
   - another explicitly stated verification target
3. Choose the resolution:
   - `quick` for a fast progress pass
   - `detailed` for a stricter closure check
4. Identify the relevant reviewer comments and response blocks in `response.tex`.
5. If a response contains quoted manuscript revisions, identify them with internal quote IDs such as `R1-C3-Q1`.
6. Apply the chosen focus while using the checklist. Give extra weight to the user-specified verification target instead of treating all checks as equally important.
7. For each comment, record the comment ID, short topic, status, and short reason.
8. In `quick`, apply the `Quick Checklist`.
9. In `detailed`, apply the `Quick Checklist` first, then the `Detailed Checklist`.

## Quick Checklist

Apply this checklist comment by comment.

1. `Response quality`
   - Is the response block empty?
   - Does the response actually address the reviewer’s concern?
   - Does it explain a revision, limitation, decision, or clarification?
   - Is it more than a vague acknowledgment?

2. `Claimed manuscript support`
   - If the response says the manuscript was revised, does the claimed edit exist in `main.tex`?
   - If the response quotes revised manuscript text, does that quoted text exist in `main.tex`?
   - If the response points to a section, figure, appendix, equation, title, or bibliography change, is that referenced change visibly present?
   - If the user specifically asks about quoted manuscript text, compare the quoted text in the response against the manuscript wording rather than checking only whether a quote exists.

3. `Quoted manuscript blocks`
   - If the response contains quoted manuscript revisions, treat them as separate objects.
   - When useful, track them with internal quote IDs such as `R1-C3-Q1`.
   - Check whether each quoted block exists in the manuscript and whether its cited location looks plausible.
   - If the response presents the quote as revised or added text, check whether there is visible revision markup somewhere within the quoted span in the manuscript.

4. `Quick judgment`
   - Assign a conservative status based on visible evidence.

## Detailed Checklist

Use this only after completing the `Quick Checklist`.

This is the comprehensive consistency pass. In `detailed`, follow the relevant shared conventions and rules from [../SKILL.md](../SKILL.md), especially:

- response and manuscript alignment conventions
- any repo-specific response-writing conventions already established in the source files

Use the internal comment IDs only for tracking and reference.

1. `Check the response itself`
   - Does the response directly answer the reviewer comment?
   - Is the response complete enough, or is it vague, partial, or evasive?
   - Does the response clearly explain what was changed, clarified, limited, or decided?
   - If the response quotes revised manuscript text, is the quotation presented carefully and specifically?

2. `Check the main-paper edit`
   - Is there a concrete corresponding change in the manuscript, figure, table, appendix, supplement, title, or bibliography?
   - If the response quotes revised text, does that text actually exist in the manuscript?
   - Is the cited manuscript location real and relevant?
   - If the user specifically asks about quote accuracy, verify that the quoted wording matches the manuscript source closely and that the cited location is appropriate.

3. `Check quoted manuscript text`
   - If a response contains multiple quoted manuscript blocks, check them one by one.
   - When useful, track them with internal quote IDs such as `R1-C3-Q1`.
   - Does each quote match the manuscript wording source closely?
   - Is each cited page and section correct in the current rendered manuscript?
   - Is the quote-location format consistent with the response conventions?
   - If the response presents the quote as revised or added text, does the quoted span contain visible revision markup somewhere within it?
   - Do not require the entire quoted paragraph to be revision-marked; require at least one substantive revised portion within the quoted span.

4. `Check response-paper consistency`
   - Does the response accurately describe what the manuscript now does?
   - Does the response overclaim?
   - If the response relies on a limitation, clarification, or narrowing move, does the manuscript actually make that move clearly enough?
   - If the response says something was revised in the paper, is that revision integrated coherently rather than only weakly implied?
   - For validation or comparison comments, is the manuscript support sufficient rather than only discursive?
   - For notation or derivation comments, is the fix visible near the relevant equations or appendix?
   - For figure comments, does the actual figure or caption support the response?
   - For framing or scope comments, does the revised framing appear in the key manuscript sections?

5. `Check convention alignment`
   - Does the response follow the response/manuscript alignment conventions in `SKILL.md`?
   - If the response quotes revised manuscript text, is the quote faithful to the manuscript wording source?
   - If the response gives a location, is that location appropriate and consistent with the rendered manuscript?
   - Are the paper and response using consistent wording, labels, and framing for the same revision?
   - Does the response use the expected response style, formatting, and tone established in the repo?

6. `Overall evaluation`
   - Based on the response, the manuscript edit, and their consistency, what is the final status?
   - What is still missing, if anything?
   - Make sure the judgment is consistent with the shared conventions in `SKILL.md`, not just with local surface matching.

7. `Suggested actions`
   - Summarize the concrete issues that remain unsatisfied.
   - State what should be changed next in the response, the manuscript, or both.
   - If the issue cannot be fully resolved, say whether the next action should be claim narrowing, limitation clarification, added evidence, or a more direct response strategy.

## Output

Use one shared lower-case status system for both `quick` and `detailed`:

- `done`
  - In `quick`, use this only when the response appears substantive and clearly linked to a concrete revision.
  - In `detailed`, use this only when the response and manuscript together close the comment.

- `partial`
  - Some meaningful progress exists, but the comment still looks unresolved.

- `open`
  - No meaningful resolution is present.

- `error`
  - Something is clearly wrong or mismatched.
  - Examples include a wrong quote, a wrong page or section, a claimed manuscript change that does not exist, or a quote presented as revised text without any visible revision markup in the quoted span.

Always present results in three parts:

### 1. Summary Table

Include all checked comments.

Use only:

- `ID`
- `Status`
- `Brief comment`

For CLI readability:

- prefer a plain-text aligned table over a wide markdown table when the output is long
- keep brief comments short enough to avoid excessive line wrapping
- keep the table narrow and easy to scan vertically
- render status values in a strong plain-text form such as `[done]`, `[partial]`, `[open]`, or `[error]`

### 2. Outstanding Items

List only unresolved comments, meaning comments labeled `partial`, `open`, or `error`.

For each unresolved comment, use a fuller itemized note.

Use this structure:

```md
- `ID` Topic
    Current state:
    What is present now:
    What is still missing:
    Recommended next action:
```

For CLI readability:

- separate unresolved items clearly with blank lines
- start each unresolved item with the comment ID so it is easy to scan
- keep field labels consistent across items
- indent the detail lines under each item consistently

### 3. Overview Evaluation

End with a short narrative overview of the checked scope.

Include:

- counts by status
- main remaining issues
- whether the remaining work is minor cleanup, major revision, or likely new experiment / claim narrowing

For CLI readability:

- keep the overview short
- prefer 2-4 lines rather than a long paragraph
