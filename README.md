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
skill.sh                 Manage skills in this repo and install them into Codex
```

## Conventions

- One folder per skill under `skills/`.
- Each skill must contain `SKILL.md`.
- Keep `SKILL.md` short and procedural.
- Put detailed notes in `references/`.
- Put reusable code in `scripts/`.
- Put templates and files used in outputs in `assets/`.
- Track status in `registry.yaml`: `draft`, `testing`, `stable`, `archived`.
- Add `version` in `registry.yaml` when you want to compare repo and global skill releases.

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

This repo includes a small CLI in `skill.sh` for installing and managing skills.

### List skills

```bash
./skill.sh list
./skill.sh list --status draft
./skill.sh list --installed
```

Output is normalized to the same shape where possible:

```text
skill-name [status | install | source | vX.Y.Z]
```

Examples:

- `paper-revision [testing | installed | in-myskills | v0.1.0]`
- `some-external-skill [installed | external]`

### Show skill metadata

```bash
./skill.sh show paper-revision
```

### Show repo/global status

Compare the repo copy and the installed global copy of a skill using `name` and `version` from `SKILL.md` frontmatter:

```bash
./skill.sh status
./skill.sh status paper-revision
```

### Install skills locally

Install all registered skills into `~/.codex/skills`:

```bash
./skill.sh
./skill.sh install --all
```

Install one or more named skills:

```bash
./skill.sh install paper-revision
./skill.sh install paper-revision slides
```

Install by status from `registry.yaml`:

```bash
./skill.sh install --status stable
./skill.sh install --status draft
```

### Pull a global skill back into the repo

If you edit an installed global skill first, you can pull that version back into this repo:

```bash
./skill.sh pull paper-revision
```

This replaces the repo copy at the path defined in `registry.yaml` with the currently installed global copy from `~/.codex/skills/<skill-id>`.

### Uninstall installed skills

Remove one or more installed skills from `~/.codex/skills`:

```bash
./skill.sh uninstall paper-revision
./skill.sh uninstall paper-revision some-other-skill
```

Remove all globally installed skills that are managed by this repo:

```bash
./skill.sh uninstall --all-managed
```

### Notes

- Running `./skill.sh` with no arguments defaults to installing all registered skills.
- Install is overwrite-based for the target skill folder in `~/.codex/skills`.
- Uninstall removes folders from `~/.codex/skills`.
- `registry.yaml` is the inventory used for listing, info, and status-based install.

## Suggested Workflow

- Draft new skills quickly.
- Promote them to `testing` while you are still exercising them in real tasks.
- Promote them to `stable` only when the trigger description and workflow hold up consistently.
- Archive old ideas by marking them `archived` instead of deleting them immediately.
