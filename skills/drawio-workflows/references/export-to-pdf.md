# Export draw.io to PDF

Use this when you need the final paper-facing figure output.

## Preferred Route

Use a two-step internal conversion:

1. Export `.drawio` to `SVG` with the Docker-based `drawio-export` workflow.
2. Convert that `SVG` to `PDF` with `rsvg-convert`.

The `SVG` here is only an intermediate layer. It does not need to be kept as a retained project artifact.

## Why This Route Is Preferred

- direct `draw.io` to `PDF` export has been less reliable in this workflow
- the `SVG` bridge preserves vector structure
- `rsvg-convert` has been a better fit than `Inkscape` in this workflow
- the final retained output is the `PDF`

## Retained Output

- keep `PDF`
- do not treat `SVG` as a required retained output

## Practical Note

Think of this workflow as:

`draw.io` -> internal `SVG` -> `rsvg-convert` -> final `PDF`
