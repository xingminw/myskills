# myskills

Personal monorepo for Codex skills.

This repository serves two purposes:

1. Record the skills you create in one place.
2. Make those skills easy to install, copy, and evolve.

## Layout

```text
skills/                  Real skills you use
templates/skill-template Starting point for new skills
registry.yaml            Inventory of all skills
install.sh               Install one skill or all skills into Codex
```

## Conventions

- One folder per skill under `skills/`.
- Each skill must contain `SKILL.md`.
- Keep `SKILL.md` short and procedural.
- Put detailed notes in `references/`.
- Put reusable code in `scripts/`.
- Put templates and files used in outputs in `assets/`.
- Track status in `registry.yaml`: `draft`, `tested`, `stable`, `deprecated`.

## Create a New Skill

Copy the template:

```bash
cp -r templates/skill-template skills/my-new-skill
```

Then update:

- `skills/my-new-skill/SKILL.md`
- `skills/my-new-skill/agents/openai.yaml`
- `registry.yaml`

## Skill CLI

This repo includes a small CLI in `install.sh` for installing and managing skills.

### List skills

```bash
./install.sh list
./install.sh list --status draft
```

### Show skill metadata

```bash
./install.sh info paper-revision
```

### Validate the repo

Checks that:

- every skill folder contains `SKILL.md`
- every skill folder has a registry entry
- every registry entry points to a real path

```bash
./install.sh validate
```

### Install skills locally

Install all registered skills into `~/.codex/skills`:

```bash
./install.sh
./install.sh install --all
```

Install one or more named skills:

```bash
./install.sh install paper-revision
./install.sh install paper-revision slides
```

Install by status from `registry.yaml`:

```bash
./install.sh install --status stable
./install.sh install --status draft
```

### Notes

- Running `./install.sh` with no arguments defaults to installing all registered skills.
- Install is overwrite-based for the target skill folder in `~/.codex/skills`.
- `registry.yaml` is the inventory used for listing, info, and status-based install.

## Suggested Workflow

- Draft new skills quickly.
- Promote them to `tested` after a few successful uses.
- Promote them to `stable` only when the trigger description and workflow hold up consistently.
- Archive old ideas by marking them `deprecated` instead of deleting them immediately.
