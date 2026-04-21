---
name: drawio-workflows
version: 0.1.0
description: Use when working with draw.io figures, especially to export .drawio files to PDF or PNG and validate outputs with lightweight visual comparison. This skill captures a format-focused workflow where .drawio is the editable source, PDF is the final paper-facing output, PNG is the preview format, and SVG is only an intermediate bridge when needed.
---

# Draw.io Workflows

Use this skill for draw.io figure handling that needs a consistent export and validation workflow.

Stay format-focused rather than project-specific.

## File Roles

Treat these file roles as stable defaults throughout the workflow:

- `.drawio` is the editable source of truth.
- `PDF` is the final paper-facing output.
- `PNG` is the quick preview and validation format.
- `SVG` is an internal vector bridge used only when needed during conversion.

These roles are not interchangeable. Prefer decisions that preserve this separation of responsibilities.

In particular:

- retain `.drawio` as the durable editable source
- retain `PDF` when a final paper-ready artifact is needed
- generate `PNG` for quick checking, comparison, and validation
- do not treat `SVG` as a normal retained deliverable unless the user explicitly wants to keep it

## Default Export Method

Treat the export mechanism as a workflow-level convention rather than a per-format detail.

Use the Docker-based `drawio-export` workflow as the default way to export from `.drawio`.

Apply that default consistently unless there is a clear project-specific reason to do otherwise.

In practice:

- use the Docker-based route when exporting draw.io outputs
- for `PDF`, first use the Docker-based route to export `SVG`
- then convert `SVG` to `PDF` in a separate step
- for `PNG`, export directly from `.drawio` to `PNG`
- keep commands, wrappers, and invocation details secondary to the workflow choice itself
- do not describe the `SVG -> PDF` step as part of the Docker-based export itself

This skill is meant to capture the stable workflow choice, not to overfit to one exact command line.

## When To Use

- Use when the user wants to export `.drawio` to `PDF`.
- Use when the user wants to export `.drawio` to `PNG` for preview or validation.
- Use when the user wants to compare a draw.io export against an existing figure or expected output.
- Do not use when the task is mainly about editing the figure design inside the draw.io GUI with no export or isolation workflow concerns.

## Workflow

1. Confirm the file role before acting:
   - source `.drawio`
   - final `PDF`
   - preview `PNG`
   - intermediate `SVG` only if needed
2. Choose the workflow that matches the task:
   - for final paper-facing output, use `.drawio -> SVG -> PDF`
   - for fast preview or validation output, use `.drawio -> PNG`
3. Keep only durable outputs:
   - retain `.drawio` sources
   - retain final `PDF` outputs when needed
   - avoid leaving temporary `SVG`, `PNG`, or export folders behind unless the user wants them kept
4. Validate before finishing:
   - use `PNG` comparison as the default quick validation step
   - check for missing elements, wrong layer order, misplaced labels, or obvious whitespace/layout shifts
   - prefer obvious visual correctness over pixel-perfect comparison

## Output Modes

### PDF Output

Use this when you need the final paper-facing figure output.

Why this route is preferred:

- direct `draw.io` to `PDF` export has been less reliable in this workflow
- the `SVG` bridge preserves vector structure before the final `PDF` is produced
- the final retained output is the `PDF`

Retained output:

- keep `PDF`
- do not treat `SVG` as a required retained output

Practical note:

`draw.io` -> internal `SVG` -> final `PDF`

### PNG Output

Use this when you need a fast preview or a validation image.

Purpose:

- quick visual inspection
- side-by-side comparison with an existing paper figure
- general lightweight checking

Role of PNG:

`PNG` is not the final paper-facing figure format.

It is the easiest format for:

- human review
- validation
- obvious-difference checking

Practical note:

`draw.io` -> `PNG` for preview and comparison
