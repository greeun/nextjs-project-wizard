# Next.js 16 Project Wizard

> A Claude Code skill that starts a new Next.js 16 project from the
> **`greeun/nextjs-16-project-template`** GitHub Template Repository.

[한국어 README](./README.ko.md)

## What it does

The skill does **not** scaffold files one by one. It pulls a boilerplate that is already
integrated and CI-verified (build / typecheck / lint / test), then runs the template's own
`init-from-template.sh` to substitute the per-project values (name, port block, database name)
and to erase every trace of the template.

The skill itself carries no boilerplate. It owns the procedure — what to ask, in what order to
run things, how to reserve ports, and what to verify. The stack and the substitution logic live
in the template repo, so the boilerplate can evolve without touching this skill.

## Install

The skill has to be linked into `~/.claude/skills/` before Claude Code can activate it:

```bash
ln -s "$(pwd)/nextjs-project-wizard" ~/.claude/skills/nextjs-project-wizard
```

Verify with `ls -la ~/.claude/skills/ | grep nextjs`.

## Usage

Ask Claude Code in plain language:

```
새 프로젝트 생성해줘
```

**Trigger keywords** — `새 프로젝트`, `프로젝트 생성`, `프로젝트 세팅`,
`create project`, `scaffold project`, `init project`, `boilerplate setup`.

## What the template ships (fixed stack)

No stack picking — everything below is already wired up and verified in the template repo.

| Area | Contents |
|---|---|
| Stack | Next.js 16 · React 19 · TypeScript 5 · Prisma 7 · PostgreSQL 16 · Node 22 · pnpm |
| Auth | Full `@withwiz/toolkit` — sign in / sign up / sign out / refresh / me / password reset / email verification / magic link |
| OAuth | 5 providers on the backend (google · github · kakao · microsoft · meta), 3 UI buttons; only providers with an id + secret in env are enabled |
| Auth UI | `@withwiz/auth-ui` screens (sign in, sign up, reset, verify) — kept light even in dark mode |
| i18n | ko / en / ja · `[locale]` routing · automatic negotiation in the proxy |
| UI / theme | `@withwiz/ui` · Tailwind 4 · lightweight theme (light / dark / system, light by default, no flash) |
| Middleware | proxy (locale + auth gate) · API chain (`withPublicApi` / `withAuthApi`, rate limit) |
| Email | nodemailer SMTP via the toolkit's `SmtpEmailSender`; falls back to console when unconfigured |
| Infra | Docker (compose `postgres:16` + standalone Dockerfile) · Vitest + Playwright · 4 `.env` profiles |

withwiz packages resolve to their **published npm versions** (`^0.9.0` / `^0.1.0` / `^0.5.0`) — not `file:` deps.

## Workflow

```
Phase 1: Collect info (name · path · port block · domain)
    ↓
Phase 2: Fetch the template (gh repo clone --depth=1, then remove .git)
    ↓
Phase 3: Substitute values + erase template traces (init-from-template.sh)
    ↓
Phase 4: Register the port block in PORTS.md, install deps, set up the DB
    ↓
Phase 5: Verify and start the server
```

**Phase 1** asks for the project name (kebab-case), the target path, and a 3-digit port block.
The block is proposed from the workspace's `PORTS.md` — the wizard reads the next free block
first. Without a `PORTS.md` it must ask, and it never falls back to the default framework
ports (3000 / 5432).

**Phase 2** takes files only. The template repo is private, so `gh repo clone` is the primary
path; `degit` cannot authenticate against a private repo and is only usable if the repo is made
public. If the repo cannot be reached, the wizard stops and asks rather than hand-scaffolding
files, which would break stack consistency.

**Phase 3** is a single script run — see below.

**Phase 4** appends the new block to `PORTS.md`, then `pnpm install`, `docker compose up -d`,
`pnpm db:migrate`, `pnpm db:seed`.

**Phase 5** runs `tsc --noEmit`, `pnpm lint`, `pnpm local`, plus the trace check.

## No template traces

A generated project inherits neither the template's git history nor its "this repo is a
template" prose. `init-from-template.sh` does four things in one run:

| Step | Contents |
|---|---|
| Substitute values | Name, database name, ports (`179xx` → `{BLOCK}xx`, including the literal `179xx` used in docs) |
| Create `.env.local` | Copy `.env.example`, inject a random `JWT_SECRET` |
| **Erase traces** | Delete the README's "start a new project from this template" section; strip the boilerplate notes from `CLAUDE.md`, `prisma/schema.prisma` and `.gitignore`; clean the "boilerplate" wording out of `meta.description` in all three i18n dictionaries |
| **Restart history** | `git init -b main` plus a single `chore: init <name>` commit. The script excludes itself from that commit and deletes itself afterwards |

If a `.git` already exists, it is removed and re-initialized **only** when its origin points at
the template repo — otherwise the script leaves it alone and warns, so nobody's commits are
destroyed. When no git identity is configured the commit is skipped; the repository is then
empty, which still means zero template history.

## Using the template without the skill

```bash
gh repo clone greeun/nextjs-16-project-template my-saas -- --depth=1 \
  && rm -rf my-saas/.git && cd my-saas \
  && ./scripts/init-from-template.sh my-saas 180 \
  && pnpm install && docker compose up -d && pnpm db:migrate && pnpm db:seed && pnpm local
```

`rm -rf my-saas/.git` cuts the template history; `init-from-template.sh` starts a fresh one.
Skipping either step drags the template's commits into the new project.

## Verifying a generated project

All four must come back empty (or with a single commit):

```bash
grep -rn "nextjs-16-project-template\|nextjs_16_project_template" . --exclude-dir=.git --exclude-dir=node_modules
grep -rni "boilerplate\|보일러플레이트\|ボイラープレート\|use this template\|degit\|init-from-template" . --exclude-dir=.git --exclude-dir=node_modules
grep -rn "179" . --exclude-dir=.git --exclude-dir=node_modules --exclude=pnpm-lock.yaml
git log --oneline    # exactly one commit (chore: init <name>), or none
```

The `179` hits inside `pnpm-lock.yaml` are a package version (`caniuse-lite@1.0.30001799`) — ignore them.

Then check the app itself: `/` redirects to `/{locale}`, the home page renders, the language
switcher works across ko/en/ja, `/{locale}/admin` gates unauthenticated visitors to `/login`,
the seeded Owner account can sign in, and the console stays clean through theme and locale changes.

## Troubleshooting

| Problem | Fix |
|---|---|
| `degit` fails on the private repo | Use `gh repo clone` instead |
| Port conflict | Re-check the free block in `PORTS.md`, or use a spare port inside the block |
| `prisma generate` fails | `pnpm prisma generate` |
| pnpm skips builds (`IGNORED_BUILDS`) | Set the entry under `allowBuilds:` in `pnpm-workspace.yaml` to `true` |

## Repository layout

```
nextjs-project-wizard/
├── SKILL.md                  # Single source of truth for the agent's behaviour
├── README.md                 # This file (human-facing)
├── README.ko.md              # Korean version
└── scripts/
    └── create-project.sh     # Legacy offline fallback — see below
```

`scripts/create-project.sh` predates the template-repo approach. It creates an empty Next.js 15
directory skeleton with no dependencies and no integration, and the standard workflow never uses
it. It exists only for the case where the template repo is completely unreachable.

The substitution script (`init-from-template.sh`) is **not** here — it lives inside the template
repo, under `scripts/` of the project you just fetched.

## Requirements

- Node.js >= 22, pnpm
- `gh` CLI, authenticated (`gh auth status`) with access to `greeun/nextjs-16-project-template`
- Docker (for the PostgreSQL container)
- Claude Code CLI

## Reference

- Template repo: <https://github.com/greeun/nextjs-16-project-template> (private, GitHub Template)
- Port convention: the workspace-level `PORTS.md`
- [Next.js docs](https://nextjs.org/docs) · [Tailwind CSS 4](https://tailwindcss.com)

## License

MIT
