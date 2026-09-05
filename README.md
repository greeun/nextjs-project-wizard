# Next.js 16 Project Wizard

> A Claude Code skill that starts a new Next.js 16 project from the
> **`greeun/nextjs-16-project-template`** GitHub Template Repository.

[한국어 README](./README.ko.md)

## What it does

The skill does **not** scaffold files one by one. It pulls a boilerplate that is already
integrated and CI-verified (build / typecheck / lint / test), runs the template's own
`init-from-template.sh` to substitute the per-project values (name, port block, database name)
and erase every trace of the template, then upgrades the `@withwiz/*` packages to their latest
published npm versions.

The skill itself carries no boilerplate and no fallback scaffolder. It owns the procedure only:
what to ask, in what order to run things, how to reserve ports, and what to verify. The stack
and the substitution logic live in the template repo, so the boilerplate can evolve without
touching this skill. If the template repo cannot be reached, the wizard stops instead of
hand-scaffolding files.

**[`SKILL.md`](./SKILL.md) is the single source of truth** for the stack table, the five phases,
the trace-removal steps, the verification commands and the troubleshooting list. This README
only covers installation and usage.

## Install

Skills are managed with `axt` (Agent eXtension Tool). This repository *is* the extension vault —
`~/.axt/vault/skills` points at it — so the skill is already available as a vault entry.
**Do not create a global `~/.claude/skills/` link.**

Attach it to whichever project you want to run the wizard from:

```bash
axt project init                              # only if .axt-profile.json does not exist yet
axt project add skills nextjs-project-wizard  # record it in .axt-profile.json
axt project sync                              # reconcile the symlinks with the profile
```

Verify with `axt skill list | grep nextjs-project-wizard`, or `axt project status` to compare the
profile against the links actually on disk.

## Usage

Ask Claude Code in plain language:

```
새 프로젝트 생성해줘
```

**Trigger keywords** — `새 프로젝트`, `프로젝트 생성`, `프로젝트 세팅`,
`create project`, `scaffold project`, `init project`, `boilerplate setup`.

The wizard then walks five phases: collect info (name · path · 3-digit port block from the
workspace `PORTS.md`) → fetch the template with `degit` (or `gh repo clone --depth=1` and drop `.git`) →
run `init-from-template.sh` → register the port block, `pnpm install`, upgrade `@withwiz/*` to
`@latest`, bring up the database → typecheck, lint, test, start the server and confirm zero
template traces.

## Using the template without the skill

```bash
npx degit greeun/nextjs-16-project-template my-saas && cd my-saas \
  && ./scripts/init-from-template.sh my-saas 180 \
  && pnpm install \
  && pnpm add @withwiz/toolkit@latest @withwiz/ui@latest @withwiz/auth-ui@latest \
  && docker compose up -d && pnpm db:migrate && pnpm db:seed && pnpm local
```

`degit` copies the files without a `.git`, and `init-from-template.sh` starts a fresh history.
If you use `gh repo clone` instead, run `rm -rf my-saas/.git` first, or the template's commits
end up in the new project. Run `pnpm install`
only after the init script, because the template's `postinstall` (`prisma generate`) needs the
`DATABASE_URL` that the script writes into `.env.local`.

## Repository layout

```
nextjs-project-wizard/
├── SKILL.md        # Single source of truth for the agent's behaviour
├── README.md       # This file (human-facing)
└── README.ko.md    # Korean version
```

The substitution script (`init-from-template.sh`) is **not** here — it lives inside the template
repo, under `scripts/` of the project you just fetched.

## Requirements

- Node.js >= 22, pnpm
- `npx` (for `degit`), or the `gh` CLI as a fallback
- Docker (for the PostgreSQL container)
- Claude Code CLI

## Reference

- Template repo: <https://github.com/greeun/nextjs-16-project-template> (public, GitHub Template)
- Port convention: the workspace-level `PORTS.md`
- [Next.js docs](https://nextjs.org/docs) · [Tailwind CSS 4](https://tailwindcss.com)

## License

MIT
