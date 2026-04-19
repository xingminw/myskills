# Isolate a Figure from the Master draw.io

Use this when a large master `.drawio` file contains many figures on one canvas, and one figure needs to be extracted as a standalone editable `.drawio`.

## Goal

Extract one grouped figure from the master file into:

- `figures/isolated/fig-x.drawio`

## Current Workflow

1. In the master `.drawio`, manually create a high-level `group` for the target figure.
2. Confirm which paper figure that group corresponds to by using the LaTeX figure order and caption.
3. Read the master `.drawio` XML and identify the target group.
4. Treat that group as the root of a subtree and collect all descendant `mxCell` elements.
5. Create a new `.drawio` file that keeps only:
   - base root cells `0` and `1`
   - the selected group subtree
6. Apply one uniform coordinate shift so the extracted content lands on a smaller local page.
7. Patch any cells that do not survive isolation correctly.
   - Example: for Fig. 8, the `Junction` circle needed an explicit white fill color.
8. Save the result under `figures/isolated/`, for example:
   - `figures/isolated/fig-8.drawio`

## Validation

Use PNG comparison as the default validation step.

1. Convert the current paper figure into a reference PNG.
2. Export the isolated `.drawio` into a candidate PNG.
3. Compare the two PNG files directly and look for obvious differences.

Focus on:

- missing or extra elements
- wrong layer order
- lines showing through filled shapes
- shifted labels or symbols
- clearly wrong whitespace or placement

This validation does not need to be pixel-perfect. The goal is to catch obvious visual regressions before keeping the isolated `.drawio`.

## What Worked So Far

- Fig. 8 has been validated as a working example.
- The extracted figure content was correct.
- The isolated file remained editable.

## Known Limitations

- Group IDs are not stable if figures are regrouped later.
- Some visual styles may depend on surrounding context and need explicit repair after extraction.
- The extracted figure can still land in a slightly awkward position on the new page.
- Temporary PNG, PDF, or SVG exports are useful for checking, but should not necessarily be kept.

## Practical Guidance

- Keep the isolated `.drawio` as the primary retained output.
- Generate `PNG` only for checking.
- Generate `SVG` only as an intermediate bridge when needed.
- Generate `PDF` only when a paper-facing output is needed.
