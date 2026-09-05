# Next.js 16 Project Wizard

> GitHub Template Repository **`greeun/nextjs-16-project-template`** 를 base 로
> 새 Next.js 16 프로젝트를 시작하는 Claude Code 스킬.

[English README](./README.md)

## 무엇을 하는가

이 스킬은 파일을 하나씩 스캐폴딩하지 **않는다**. 이미 통합·CI 검증(빌드/타입체크/lint/테스트)이
끝난 보일러플레이트를 가져온 뒤, 템플릿에 들어 있는 `init-from-template.sh` 를 실행해
프로젝트별 값(이름·포트 블록·DB명)을 치환하고 템플릿 흔적을 지운다. 그다음 `@withwiz/*` 패키지를
npm 게시 최신 버전으로 올린다.

스킬 자체는 보일러플레이트도, 폴백 스캐폴더도 갖고 있지 않다. 스킬이 담당하는 것은 절차뿐이다.
무엇을 물을지, 어떤 순서로 실행할지, 포트를 어떻게 예약할지, 무엇을 검증할지를 정한다. 스택과
치환 로직은 template repo 소유이므로, 보일러플레이트가 바뀌어도 이 스킬은 대개 손대지 않아도
된다. template repo 에 접근할 수 없으면 위저드는 파일을 수동으로 만들지 않고 멈춘다.

스택 표, 5단계 워크플로우, 흔적 제거 절차, 검증 명령, 문제 해결 목록은 모두
**[`SKILL.md`](./SKILL.md) 가 단일 기준**이다. 이 README 는 설치와 사용법만 다룬다.

## 설치

스킬은 `axt`(Agent eXtension Tool)로 관리한다. 이 저장소가 곧 extension vault 다.
`~/.axt/vault/skills` 가 이 저장소를 가리키므로 이 스킬은 이미 vault 항목으로 등록돼 있다.
**전역 `~/.claude/skills/` 링크는 생성하지 않는다.**

위저드를 실행할 프로젝트에 붙인다:

```bash
axt project init                              # .axt-profile.json 이 없을 때만
axt project add skills nextjs-project-wizard  # .axt-profile.json 에 기록
axt project sync                              # 프로필과 심링크 상태 동기화
```

확인: `axt skill list | grep nextjs-project-wizard`.
프로필과 실제 심링크의 차이는 `axt project status` 로 본다.

## 사용법

Claude Code 에 평문으로 요청한다:

```
새 프로젝트 생성해줘
```

**트리거 키워드** — `새 프로젝트`, `프로젝트 생성`, `프로젝트 세팅`,
`create project`, `scaffold project`, `init project`, `boilerplate setup`

위저드는 5단계로 진행한다. 정보 수집(이름 · 경로 · 워크스페이스 `PORTS.md` 기준 3자리 포트 블록)
→ `degit`(또는 `gh repo clone --depth=1` 후 `.git` 제거)으로 템플릿을 가져옴 → `init-from-template.sh` 실행 →
포트 블록 등록, `pnpm install`, `@withwiz/*` 를 `@latest` 로 최신화, DB 구동 → 타입체크·lint·테스트·
서버 구동과 템플릿 흔적 0 확인.

## 스킬 없이 템플릿만 쓸 때

```bash
npx degit greeun/nextjs-16-project-template my-saas && cd my-saas \
  && ./scripts/init-from-template.sh my-saas 180 \
  && pnpm install \
  && pnpm add @withwiz/toolkit@latest @withwiz/ui@latest @withwiz/auth-ui@latest \
  && docker compose up -d && pnpm db:migrate && pnpm db:seed && pnpm local
```

`degit` 은 `.git` 없이 파일만 가져오고, `init-from-template.sh` 가 새 히스토리를 시작한다.
`gh repo clone` 을 썼다면 `rm -rf my-saas/.git` 을 먼저 실행해야 템플릿 커밋이 딸려오지 않는다.
`pnpm install` 은 반드시
init 스크립트 뒤에 실행한다. 템플릿의 `postinstall`(`prisma generate`)이 스크립트가 `.env.local`
에 기록하는 `DATABASE_URL` 을 요구하기 때문이다.

## 저장소 구성

```
nextjs-project-wizard/
├── SKILL.md        # 에이전트 동작의 단일 기준
├── README.md       # 영문 문서
└── README.ko.md    # 이 파일
```

치환 스크립트(`init-from-template.sh`)는 이 저장소에 **없다**. Phase 2 에서 가져온 프로젝트의
`scripts/` 아래, 즉 template repo 안에 있다.

## 요구 사항

- Node.js >= 22, pnpm
- `npx`(degit 실행용), 대체 수단으로 `gh` CLI
- Docker (PostgreSQL 컨테이너용)
- Claude Code CLI

## 참고

- Template repo: <https://github.com/greeun/nextjs-16-project-template> (public, GitHub Template)
- 포트 표준: 워크스페이스 `PORTS.md`
- [Next.js 문서](https://nextjs.org/docs) · [Tailwind CSS 4](https://tailwindcss.com)

## 라이선스

MIT
