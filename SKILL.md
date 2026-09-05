---
name: nextjs-project-wizard
description: Use when user wants to create a new Next.js 16 project with withwiz integration. Triggers on "새 프로젝트", "프로젝트 생성", "create project", "scaffold project", "init project", "프로젝트 세팅", "boilerplate setup".
version: 1.2.0
---

# Next.js 16 Project Wizard

GitHub Template Repository **`greeun/nextjs-16-project-template`** 를 base 로 새 Next.js 16 프로젝트를
빠르게 시작하는 인터랙티브 위저드. 파일을 일일이 생성하지 않고, 검증된 보일러플레이트를
가져와(`gh repo clone --depth=1` + `.git` 제거) `init-from-template.sh` 로 프로젝트별 값
(이름·포트·DB)을 치환하고 템플릿 흔적을 지운다.

> 이전 버전은 프로젝트 파일을 직접 스캐폴딩했다. 현재는 **template repo 방식**이다 —
> 보일러플레이트 자체가 CI 검증(빌드/타입/lint/test)된 상태로 유지되므로 더 안정적이고 빠르다.

## When to Use

- 새 Next.js 16 프로젝트 생성 요청
- withwiz(toolkit/ui/auth-ui) 기반 웹앱 스캐폴딩
- 인증·i18n·Docker·테스트가 갖춰진 보일러플레이트 필요

## 템플릿이 제공하는 것 (고정 스택)

template repo `greeun/nextjs-16-project-template` 에 이미 통합·검증돼 있다 — Phase 2 의 스택 선택은 불필요:

| 영역 | 내용 |
|---|---|
| 스택 | Next.js 16 · React 19 · TypeScript 5 · Prisma 7 · PostgreSQL 16 · Node 22 · pnpm |
| 인증 | `@withwiz/toolkit` 전 기능 — 로그인/회원가입/로그아웃/refresh/me/비번찾기·재설정/이메일인증/매직링크 |
| OAuth | 백엔드 5종(google·github·kakao·microsoft·meta) · UI 버튼 3종 · env 에 id+secret 있는 것만 활성 |
| 인증 UI | `@withwiz/auth-ui` 화면(로그인/가입/재설정/인증) — 다크에서 라이트 격리 |
| i18n | ko/en/ja · `[locale]` 라우팅 · proxy 자동 협상 |
| UI/테마 | `@withwiz/ui` · Tailwind 4 · 경량 테마(light/dark/system, 기본 light, no-flash) |
| 미들웨어 | proxy(로케일+auth 게이트) · API 체인(withPublicApi/withAuthApi, rate limit) |
| 이메일 | nodemailer SMTP(toolkit SmtpEmailSender), 미설정 시 콘솔 폴백 |
| 인프라 | Docker(compose postgres:16 + standalone Dockerfile) · Vitest + Playwright · .env 4프로필 |

withwiz 패키지는 **npm 게시 최신 버전**을 쓴다 (file: dep 아님). 템플릿의 `package.json`·lock 은
게시 시점에 고정돼 있어 최신에 뒤처질 수 있으므로, **Phase 4 에서 반드시 `@latest` 로 올린다.**

---

## Wizard Workflow

```
Phase 1: 정보 수집 (이름·경로·포트블록·도메인)
    ↓
Phase 2: 템플릿 가져오기 (gh repo clone --depth=1 + .git 제거)
    ↓
Phase 3: 치환 + 템플릿 흔적 제거 (init-from-template.sh)
    ↓
Phase 4: PORTS.md 등록 + 의존성(withwiz 최신화)/DB 셋업
    ↓
Phase 5: 검증 및 서버 구동
```

---

## Phase 1: 정보 수집

질문 (한 번에 하나씩, 또는 AskUserQuestion 으로 묶어서):

1. "프로젝트 이름은? (kebab-case, 예: my-saas)"
2. "어느 경로에 생성할까요? (기본: 현재 워크스페이스 아래 `<이름>`)"
3. "포트 블록 번호는? (3자리, 예: 180 → 18000번대)"
   - 워크스페이스 루트의 **`PORTS.md`** 에서 **"다음 빈 블록"을 먼저 확인**해 제안한다.
   - PORTS.md 가 없으면 기본 프레임워크 포트(3000/5432) 금지 — 반드시 사용자에게 묻는다.
4. (선택) "프로젝트 도메인/핵심 기능은?" — CLAUDE.md·홈 카피 보강용. 생략 가능.

**산출**: `PROJECT_NAME`, `TARGET_PATH`, `PORT_BLOCK`(3자리)

---

## Phase 2: 템플릿 가져오기

히스토리 없이 파일만 가져온다. **template 이 private 이므로 `gh` 인증 clone 이 1차**
(degit 은 private repo 인증을 못 해 실패한다 — public 전환 시에만 사용):

```bash
# 방법 A — gh clone 후 .git 제거 (private 권장)
gh auth status   # 인증 확인
gh repo clone greeun/nextjs-16-project-template "<TARGET_PATH>" -- --depth=1 \
  && rm -rf "<TARGET_PATH>/.git"

# 방법 B — repo 가 public 일 때만: degit (가장 가벼움)
npx degit greeun/nextjs-16-project-template "<TARGET_PATH>"
```

> GitHub UI "Use this template" 도 가능하나, 위저드는 CLI 로 진행한다.

> **원칙: 템플릿 흔적을 남기지 않는다.** 생성된 프로젝트는 template repo 의 git 히스토리도,
> "이 repo 는 템플릿이다" 류의 문서·주석도 승계하지 않는다. 히스토리는 Phase 3 에서 새로 시작하고,
> 문서·주석 정리도 Phase 3 이 처리한다. 여기서는 `.git` 제거만 확실히 한다 —
> `ls -d "<TARGET_PATH>/.git"` 가 "No such file" 이어야 다음 단계로 넘어간다.

> **템플릿 저장소 접근 불가 시**: 방법 A(`gh repo clone`)가 인증/권한/네트워크로 실패하고
> 방법 B(degit)도 private 라 불가하면, **여기서 멈추고** 사용자에게 다음을 안내한다 —
> (1) `gh auth status` 로 인증 확인, (2) `greeun/nextjs-16-project-template` 접근 권한 요청,
> (3) 저장소가 public 이면 degit 재시도. **임의로 파일을 수동 스캐폴딩하지 말 것**(스택 정합성 깨짐).
> 이 스킬에는 폴백 스캐폴더가 없다. 템플릿에 접근할 수 없으면 프로젝트를 만들지 않는다.

---

## Phase 3: 치환 + 템플릿 흔적 제거

template 의 `init-from-template.sh` 한 번으로 끝난다:

```bash
cd "<TARGET_PATH>"
./scripts/init-from-template.sh <PROJECT_NAME> <PORT_BLOCK>
#   예: ./scripts/init-from-template.sh my-saas 180
#   → 이름 nextjs-16-project-template→my-saas, 포트 17900→18000(/01/05/06/30), DB nextjs_16_project_template→my_saas
```

스크립트가 하는 일 4가지:

| 단계 | 내용 |
|---|---|
| 값 치환 | 이름·DB명·포트(`179xx`→`{BLOCK}xx`, 문서의 `179xx` 표기 포함) |
| `.env.local` 생성 | `.env.example` 복사 + `JWT_SECRET` 랜덤 주입 |
| **흔적 제거** | README "템플릿으로 새 프로젝트 시작" 절 삭제 · CLAUDE.md/schema.prisma/.gitignore 의 보일러플레이트 안내 주석 삭제 · i18n `meta.description` 3개 언어의 "보일러플레이트/boilerplate/ボイラープレート" 표현 정리 |
| **히스토리 새로 시작** | `git init -b main` + `chore: init <이름>` 커밋 1개. 스크립트 자신은 커밋에서 제외하고 실행 후 자동 삭제 |

`.git` 이 이미 있으면 origin 이 template repo 를 가리킬 때만 제거·재초기화하고,
그 외에는 건드리지 않고 경고만 낸다(남의 커밋 보호). git identity 미설정이면 커밋만 건너뛴다 —
빈 저장소가 되므로 템플릿 히스토리는 여전히 0.

치환 검증(샘플): `17900→{BLOCK}00`, `17901→{BLOCK}01`, `17905→05`, `17906→06`, `17930→30`.

---

## Phase 4: PORTS.md 등록 + 셋업

1. 워크스페이스 `PORTS.md` 1군 표에 새 블록 행 추가 + "다음 빈 블록" 갱신:
   ```
   | {BLOCK}xx | {PROJECT_NAME} | 앱 {BLOCK}00✓ · DB {BLOCK}01✓ · 테스트 {BLOCK}05✓ · 테스트DB {BLOCK}06✓ · Studio {BLOCK}30✓ — 위저드 생성(nextjs-16-project-template 템플릿) |
   ```
2. 의존성 설치 + **withwiz 최신화**:
   ```bash
   pnpm install                      # Phase 3 이후에 실행 — postinstall(prisma generate)이 .env.local 의 DATABASE_URL 을 요구한다
   pnpm add @withwiz/toolkit@latest @withwiz/ui@latest @withwiz/auth-ui@latest
   #   package.json 범위와 lock 을 npm 게시 최신 버전으로 갱신. 템플릿 고정 버전을 그대로 쓰지 않는다.
   pnpm ls @withwiz/toolkit @withwiz/ui @withwiz/auth-ui   # 설치 버전 확인
   ```
   최신화 후 `pnpm typecheck && pnpm lint && pnpm test` 가 실패하면 그 버전의 호환성 문제이므로
   사용자에게 알리고, 실패한 패키지만 직전 버전으로 되돌린다. 템플릿의 `pnpm-workspace.yaml` 에
   남아 있는 `minimumReleaseAgeExclude` 항목(`@withwiz/ui@0.2.0`)은 구버전 잔재이므로 제거한다.
3. DB:
   ```bash
   docker compose up -d              # postgres:16, 호스트 포트 {BLOCK}01
   pnpm db:migrate                   # 최초 마이그레이션 생성
   pnpm db:seed                      # Owner 계정(.env.local OWNER_*)
   ```

---

## Phase 5: 검증 및 서버 구동

```bash
pnpm typecheck              # tsc --noEmit
pnpm lint                   # eslint
pnpm test                   # vitest
pnpm local                  # → http://localhost:{BLOCK}00
```

템플릿 흔적 0 확인 (셋 다 출력이 없어야 통과):

```bash
grep -rn "nextjs-16-project-template\|nextjs_16_project_template" . --exclude-dir=.git --exclude-dir=node_modules
grep -rni "보일러플레이트\|boilerplate\|ボイラープレート\|use this template\|degit\|init-from-template" . --exclude-dir=.git --exclude-dir=node_modules
grep -rn "179" . --exclude-dir=.git --exclude-dir=node_modules --exclude=pnpm-lock.yaml
git log --oneline        # 커밋 1개(chore: init <이름>) 또는 0개여야 한다
```

> `pnpm-lock.yaml` 의 `179` 는 패키지 버전(`caniuse-lite@1.0.30001799`)이라 무시한다.

최종 체크리스트:
- [ ] `/` → `/{locale}` 리다이렉트
- [ ] 홈 렌더 정상, 언어 전환(ko/en/ja) 동작
- [ ] `/{locale}/admin` → 미인증 시 `/login` 게이트
- [ ] 로그인(시드 Owner 계정) → admin 진입
- [ ] 콘솔 에러 0 (테마/언어변경 포함)
- [ ] 템플릿 흔적 0 (위 grep 4종)
- [ ] withwiz 3종이 `npm view <pkg> version` 과 같은 최신 버전

---

## Quick Reference

### 한 줄 요약 흐름
```bash
gh repo clone greeun/nextjs-16-project-template my-saas -- --depth=1 \
  && rm -rf my-saas/.git && cd my-saas \
  && ./scripts/init-from-template.sh my-saas 180 \
  && pnpm install \
  && pnpm add @withwiz/toolkit@latest @withwiz/ui@latest @withwiz/auth-ui@latest \
  && docker compose up -d && pnpm db:migrate && pnpm db:seed && pnpm local
```
`rm -rf my-saas/.git` 가 템플릿 히스토리를 끊고, `init-from-template.sh` 가 새 히스토리를 시작한다.
이 두 단계를 건너뛰면 템플릿 커밋이 그대로 딸려온다. `pnpm add ...@latest` 가 withwiz 를 최신화한다.

### 프로젝트 타입별 추가 설정 (template 위에 얹기)
| 타입 | 추가 작업 |
|---|---|
| SaaS | OAuth env 채우기, 도메인 모델 prisma 추가 |
| 블로그 | i18n 유지, 글/카테고리 모델 추가 |
| API 서버 | 페이지 최소화, `withAuthApi` 라우트 확장 |

### Common Issues
| 문제 | 해결 |
|---|---|
| degit private 실패 | `gh repo clone` 방법 A 사용 |
| `pnpm install` 이 postinstall 에서 `Cannot resolve environment variable: DATABASE_URL` | `.env.local` 이 없다. Phase 3(`init-from-template.sh`)을 먼저 실행한다 |
| withwiz 최신화 후 typecheck/lint 실패 | 실패 패키지만 직전 버전으로 고정하고 사용자에게 보고 |
| 포트 충돌 | PORTS.md에서 빈 블록 재확인, 블록 내 예비 포트 사용 |
| prisma generate 실패 | `pnpm prisma generate` |
| pnpm 빌드 무시(IGNORED_BUILDS) | `pnpm-workspace.yaml` 의 `allowBuilds:` 항목을 `true` 로 |

### Reference
- **Template repo**: https://github.com/greeun/nextjs-16-project-template (private, GitHub Template)
- 치환 스크립트: `scripts/init-from-template.sh` — **template repo 안에 있다**(Phase 2 에서 가져온 프로젝트의 `scripts/` 아래). 이 스킬 폴더에는 없다.
- 포트 표준: 워크스페이스 `PORTS.md`
- withwiz 최신 버전 확인: `npm view @withwiz/toolkit version` (ui · auth-ui 동일)
