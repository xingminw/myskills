---
name: drawio-workflows
version: 0.1.0
description: Use when working with draw.io figures, especially to export .drawio files to PDF or PNG, isolate one figure from a larger master canvas, and validate isolated figures with lightweight visual comparison. This skill captures a format-focused workflow where .drawio is the editable source, PDF is the final paper-facing output, PNG is the preview format, and SVG is only an intermediate bridge when needed.
---

# Draw.io Workflows

Use this skill for draw.io figure handling that needs a consistent export, isolation, and validation workflow.

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

## When To Use

- Use when the user wants to export `.drawio` to `PDF`.
- Use when the user wants to export `.drawio` to `PNG` for preview or validation.
- Use when a large master `.drawio` contains multiple figures and one figure should become a standalone editable `.drawio`.
- Use when the user wants to compare an isolated draw.io figure against an existing paper figure.
- Do not use when the task is mainly about editing the figure design inside the draw.io GUI with no export or isolation workflow concerns.

## Workflow

1. Confirm the file role before acting:
   - source `.drawio`
   - final `PDF`
   - preview `PNG`
   - intermediate `SVG` only if needed
2. Choose the workflow that matches the task:
   - for final paper-facing output, read [references/export-to-pdf.md](references/export-to-pdf.md)
   - for fast preview or validation output, read [references/export-to-png.md](references/export-to-png.md)
   - for extracting a figure from a master canvas, read [references/isolate-figure.md](references/isolate-figure.md)
3. Keep only durable outputs:
   - retain `.drawio` sources
   - retain final `PDF` outputs when needed
   - retain isolated `.drawio` outputs when created
   - avoid leaving temporary `SVG`, `PNG`, or export folders behind unless the user wants them kept
4. Validate before finishing:
   - use `PNG` comparison as the default quick validation step
   - check for missing elements, wrong layer order, misplaced labels, or obvious whitespace/layout shifts
   - prefer obvious visual correctness over pixel-perfect comparison

## Resources

- Read `references/export-to-pdf.md` for the preferred `.drawio -> SVG -> PDF` route.
- Read `references/export-to-png.md` for preview and validation output.
- Read `references/isolate-figure.md` for figure extraction from a large master file.
