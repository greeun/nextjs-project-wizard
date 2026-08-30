# Next.js 16 Project Wizard

> GitHub Template Repository **`greeun/nextjs-16-project-template`** 를 base 로
> 새 Next.js 16 프로젝트를 시작하는 Claude Code 스킬.

[English README](./README.md)

## 무엇을 하는가

이 스킬은 파일을 하나씩 스캐폴딩하지 **않는다**. 이미 통합·CI 검증(빌드/타입체크/lint/테스트)이
끝난 보일러플레이트를 가져온 뒤, 템플릿에 들어 있는 `init-from-template.sh` 를 실행해
프로젝트별 값(이름·포트 블록·DB명)을 치환하고 템플릿 흔적을 지운다.

스킬 자체는 보일러플레이트를 갖고 있지 않다. 스킬이 담당하는 것은 절차다 — 무엇을 물을지,
어떤 순서로 실행할지, 포트를 어떻게 예약할지, 무엇을 검증할지. 스택과 치환 로직은 template repo
소유이므로, 보일러플레이트가 바뀌어도 이 스킬은 대개 손대지 않아도 된다.

## 설치

Claude Code 가 인식하려면 `~/.claude/skills/` 에 심링크를 생성해야 한다:

```bash
ln -s "$(pwd)/nextjs-project-wizard" ~/.claude/skills/nextjs-project-wizard
```

확인: `ls -la ~/.claude/skills/ | grep nextjs`

## 사용법

Claude Code 에 평문으로 요청한다:

```
새 프로젝트 생성해줘
```

**트리거 키워드** — `새 프로젝트`, `프로젝트 생성`, `프로젝트 세팅`,
`create project`, `scaffold project`, `init project`, `boilerplate setup`

## 템플릿이 제공하는 것 (고정 스택)

스택 선택 과정은 없다. 아래는 전부 template repo 에 이미 통합·검증돼 있다.

| 영역 | 내용 |
|---|---|
| 스택 | Next.js 16 · React 19 · TypeScript 5 · Prisma 7 · PostgreSQL 16 · Node 22 · pnpm |
| 인증 | `@withwiz/toolkit` 전 기능 — 로그인 / 회원가입 / 로그아웃 / refresh / me / 비밀번호 찾기·재설정 / 이메일 인증 / 매직링크 |
| OAuth | 백엔드 5종(google · github · kakao · microsoft · meta) · UI 버튼 3종. env 에 id 와 secret 이 있는 것만 활성화 |
| 인증 UI | `@withwiz/auth-ui` 화면(로그인 / 가입 / 재설정 / 인증) — 다크 모드에서도 라이트로 격리 |
| i18n | ko / en / ja · `[locale]` 라우팅 · proxy 자동 협상 |
| UI·테마 | `@withwiz/ui` · Tailwind 4 · 경량 테마(light / dark / system, 기본 light, no-flash) |
| 미들웨어 | proxy(로케일 + auth 게이트) · API 체인(`withPublicApi` / `withAuthApi`, rate limit) |
| 이메일 | nodemailer SMTP(toolkit `SmtpEmailSender`). 미설정 시 콘솔 폴백 |
| 인프라 | Docker(compose `postgres:16` + standalone Dockerfile) · Vitest + Playwright · `.env` 4프로필 |

withwiz 패키지는 **npm 게시 버전**(`^0.9.0` / `^0.1.0` / `^0.5.0`)을 사용한다 — `file:` dep 이 아니다.

## 워크플로우

```
Phase 1: 정보 수집 (이름 · 경로 · 포트 블록 · 도메인)
    ↓
Phase 2: 템플릿 가져오기 (gh repo clone --depth=1 후 .git 제거)
    ↓
Phase 3: 값 치환 + 템플릿 흔적 제거 (init-from-template.sh)
    ↓
Phase 4: PORTS.md 등록 + 의존성·DB 셋업
    ↓
Phase 5: 검증 및 서버 구동
```

**Phase 1** — 프로젝트 이름(kebab-case), 생성 경로, 3자리 포트 블록을 묻는다. 포트 블록은
워크스페이스 `PORTS.md` 에서 다음 빈 블록을 먼저 확인해 제안한다. `PORTS.md` 가 없으면 반드시
사용자에게 묻고, 기본 프레임워크 포트(3000 / 5432)로 넘어가지 않는다.

**Phase 2** — 파일만 가져온다. template repo 가 private 이므로 `gh repo clone` 이 1차 경로다.
`degit` 은 private repo 인증을 하지 못하므로 저장소가 public 일 때만 쓸 수 있다. 저장소에 접근할
수 없으면 임의로 파일을 수동 스캐폴딩하지 않고 멈춰서 사용자에게 묻는다 — 수동 생성은 스택 정합성을
깨뜨린다.

**Phase 3** — 스크립트 한 번으로 끝난다. 아래 참고.

**Phase 4** — `PORTS.md` 에 새 블록 행을 추가한 뒤 `pnpm install`, `docker compose up -d`,
`pnpm db:migrate`, `pnpm db:seed`.

**Phase 5** — `tsc --noEmit`, `pnpm lint`, `pnpm local` 과 흔적 검사.

## 템플릿 흔적을 남기지 않는다

생성된 프로젝트는 템플릿의 git 히스토리도, "이 repo 는 템플릿이다" 류의 문서·주석도 승계하지
않는다. `init-from-template.sh` 가 한 번의 실행으로 4가지를 처리한다:

| 단계 | 내용 |
|---|---|
| 값 치환 | 이름 · DB명 · 포트(`179xx` → `{BLOCK}xx`, 문서에 쓰인 `179xx` 리터럴 표기 포함) |
| `.env.local` 생성 | `.env.example` 복사 + `JWT_SECRET` 랜덤 주입 |
| **흔적 제거** | README 의 "템플릿으로 새 프로젝트 시작" 절 삭제 · `CLAUDE.md` / `prisma/schema.prisma` / `.gitignore` 의 보일러플레이트 안내 주석 삭제 · i18n 사전 3개 언어의 `meta.description` 에서 보일러플레이트 표현 정리 |
| **히스토리 새로 시작** | `git init -b main` + `chore: init <이름>` 커밋 1개. 스크립트 자신은 그 커밋에서 제외한 뒤 실행 종료 시 자동 삭제 |

`.git` 이 이미 있으면, origin 이 template repo 를 가리킬 때**만** 제거·재초기화한다. 그 외에는
건드리지 않고 경고만 내므로 남의 커밋이 사라지지 않는다. git identity 가 설정돼 있지 않으면 커밋만
건너뛴다 — 빈 저장소가 되므로 템플릿 히스토리는 여전히 0이다.

## 스킬 없이 템플릿만 쓸 때

```bash
gh repo clone greeun/nextjs-16-project-template my-saas -- --depth=1 \
  && rm -rf my-saas/.git && cd my-saas \
  && ./scripts/init-from-template.sh my-saas 180 \
  && pnpm install && docker compose up -d && pnpm db:migrate && pnpm db:seed && pnpm local
```

`rm -rf my-saas/.git` 가 템플릿 히스토리를 끊고, `init-from-template.sh` 가 새 히스토리를
시작한다. 두 단계 중 하나라도 건너뛰면 템플릿 커밋이 그대로 딸려온다.

## 생성된 프로젝트 검증

넷 다 출력이 없어야(마지막은 커밋 1개) 통과다:

```bash
grep -rn "nextjs-16-project-template\|nextjs_16_project_template" . --exclude-dir=.git --exclude-dir=node_modules
grep -rni "보일러플레이트\|boilerplate\|ボイラープレート\|use this template\|degit\|init-from-template" . --exclude-dir=.git --exclude-dir=node_modules
grep -rn "179" . --exclude-dir=.git --exclude-dir=node_modules --exclude=pnpm-lock.yaml
git log --oneline    # 커밋 1개(chore: init <이름>) 또는 0개
```

`pnpm-lock.yaml` 안의 `179` 는 패키지 버전(`caniuse-lite@1.0.30001799`)이므로 무시한다.

이후 앱 자체를 확인한다 — `/` 가 `/{locale}` 로 리다이렉트되는지, 홈이 정상 렌더되는지, ko/en/ja
언어 전환이 동작하는지, `/{locale}/admin` 이 미인증 시 `/login` 으로 게이트되는지, 시드 Owner
계정으로 로그인되는지, 테마·언어 변경을 포함해 콘솔 에러가 0인지.

## 문제 해결

| 문제 | 해결 |
|---|---|
| private repo 에서 `degit` 실패 | `gh repo clone` 사용 |
| 포트 충돌 | `PORTS.md` 에서 빈 블록 재확인, 또는 블록 내 예비 포트 사용 |
| `prisma generate` 실패 | `pnpm prisma generate` |
| pnpm 이 빌드를 건너뜀(`IGNORED_BUILDS`) | `pnpm-workspace.yaml` 의 `allowBuilds:` 해당 항목을 `true` 로 설정 |

## 저장소 구성

```
nextjs-project-wizard/
├── SKILL.md                  # 에이전트 동작의 단일 진실 공급원
├── README.md                 # 영문 문서
├── README.ko.md              # 이 파일
└── scripts/
    └── create-project.sh     # 구버전 오프라인 폴백 — 아래 참고
```

`scripts/create-project.sh` 는 template repo 방식 이전의 스캐폴더다. Next.js 15 기준으로 빈
디렉토리 골격만 만들며 의존성·통합이 없고, 표준 워크플로우에서는 사용하지 않는다. template repo 에
전혀 접근할 수 없는 상황의 최후 폴백 용도로만 남겨 두었다.

치환 스크립트(`init-from-template.sh`)는 이 저장소에 **없다**. Phase 2 에서 가져온 프로젝트의
`scripts/` 아래, 즉 template repo 안에 있다.

## 요구 사항

- Node.js >= 22, pnpm
- `gh` CLI 인증(`gh auth status`) + `greeun/nextjs-16-project-template` 접근 권한
- Docker (PostgreSQL 컨테이너용)
- Claude Code CLI

## 참고

- Template repo: <https://github.com/greeun/nextjs-16-project-template> (private, GitHub Template)
- 포트 표준: 워크스페이스 `PORTS.md`
- [Next.js 문서](https://nextjs.org/docs) · [Tailwind CSS 4](https://tailwindcss.com)

## 라이선스

MIT
