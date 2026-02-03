# Next.js 15 Project Wizard

> Claude Code 스킬: url-shortener-mvp 프로젝트 구조를 기반으로 새 Next.js 15 프로젝트를 생성하는 인터랙티브 위저드

## 개요

이 스킬은 프로덕션 레벨의 Next.js 15 프로젝트를 빠르게 스캐폴딩합니다. Clean Architecture, 미들웨어 체인, 환경별 설정 등 실무에서 검증된 구조를 제공합니다.

### 주요 특징

- **Next.js 15 + React 19** - 최신 App Router 기반
- **TypeScript** - 완전한 타입 지원
- **Tailwind CSS 4** - 최신 CSS 프레임워크
- **Clean Architecture** - `src/lib/` (비즈니스) + `src/shared/@withwiz/` (공용)
- **미들웨어 시스템** - Express 스타일 API 미들웨어 체인
- **환경별 설정** - local, dev, production, test 환경 분리

## 사용 방법

### Claude Code에서 호출

```
새 프로젝트 생성해줘
```

또는

```
/nextjs-project-wizard
```

### 트리거 키워드

- "새 프로젝트", "프로젝트 생성", "프로젝트 세팅"
- "create project", "scaffold project", "init project"
- "boilerplate setup"

## 위저드 워크플로우

```
Phase 1: 프로젝트 기본 정보 수집
         ↓
Phase 2: 기술 스택 선택
         ↓
Phase 3: 기능 모듈 선택
         ↓
Phase 4: 프로젝트 생성 실행
         ↓
Phase 5: 검증 및 서버 구동
```

### Phase 1: 프로젝트 기본 정보

| 질문 | 예시 |
|------|------|
| 프로젝트 이름 | `my-awesome-app` |
| 생성 경로 | `~/projects/` |
| 주제/도메인 | 전자상거래, 블로그, SaaS |
| 핵심 기능 3가지 | 사용자 인증, 상품 관리, 결제 |
| 한 줄 설명 | "실시간 협업 문서 편집기" |

### Phase 2: 기술 스택

#### 데이터베이스
| 옵션 | 설명 |
|------|------|
| PostgreSQL + Prisma | 관계형 DB, ORM 포함 (권장) |
| MongoDB + Mongoose | NoSQL 문서 DB |
| SQLite + Prisma | 경량 로컬 DB |
| None | 데이터베이스 없음 |

#### 캐시 시스템
| 옵션 | 설명 |
|------|------|
| Hybrid | Redis + InMemory 폴백 (권장) |
| Redis (Upstash) | 프로덕션 권장 |
| InMemory Only | 개발/소규모용 |

#### 인증 시스템
| 옵션 | 설명 |
|------|------|
| JWT + OAuth | Google, GitHub, Apple 지원 (권장) |
| JWT Only | 이메일/비밀번호만 |
| None | 인증 없음 |

### Phase 3: 기능 모듈

#### 필수 모듈 (자동 포함)
- 프로젝트 구조 (`src/`, `docs/`, `scripts/`)
- TypeScript 설정 (경로 alias)
- ESLint + Prettier
- 환경 변수 템플릿

#### 선택 모듈
| 모듈 | 설명 | 기본값 |
|------|------|--------|
| i18n | 다국어 지원 (ko, en, ja) | Yes |
| Testing | Jest + Playwright | Yes |
| Middleware | API 미들웨어 체인 | Yes |
| Docker | Dockerfile + compose | No |
| Rate Limiting | API 요청 제한 | No |

## 생성되는 프로젝트 구조

```
my-project/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── api/               # API Routes
│   │   ├── [locale]/          # i18n 라우트
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── globals.css
│   ├── components/
│   │   ├── ui/               # shadcn/ui 컴포넌트
│   │   └── layouts/
│   ├── lib/                   # 비즈니스 로직
│   │   ├── services/
│   │   ├── validators/
│   │   ├── hooks/
│   │   ├── constants/
│   │   └── utils/
│   ├── shared/@withwiz/       # 재사용 가능 코드
│   │   ├── middleware/       # API 미들웨어
│   │   ├── constants/
│   │   ├── utils/
│   │   ├── error/
│   │   ├── auth/
│   │   └── logger/
│   └── types/
├── prisma/
│   └── schema.prisma
├── scripts/
│   ├── local-startup.sh       # npm run local
│   ├── dev-startup.sh         # npm run dev
│   ├── build.sh              # npm run build:prod
│   ├── start.sh              # npm run start:prod
│   └── test-server-startup.sh # npm run test:server
├── tests/
│   ├── 01-unit/
│   ├── 02-integration/
│   ├── 03-api/
│   └── 04-e2e/
├── docs/
│   └── claude/
├── .env.example
├── .env.local                 # 로컬 개발
├── .env.dev                   # 공유 개발
├── .env.production            # 프로덕션
├── .env.test                  # 테스트
├── package.json
├── tsconfig.json
├── next.config.js
├── postcss.config.mjs
├── components.json            # shadcn/ui
├── CLAUDE.md
└── .gitignore
```

## 환경 설정

### 환경별 차이점

| 설정 | .env.local | .env.dev | .env.production | .env.test |
|------|------------|----------|-----------------|-----------|
| PORT | 3000 | 3000 | - | 3555 |
| CACHE_REDIS | false | true | true | false |
| CACHE_INMEMORY | true | true | true | true |
| RATE_LIMIT | false | true | true | false |
| LOG_LEVEL | debug | debug | warn | error |

### 스크립트 사용법

```bash
# 로컬 개발 (개인 환경)
npm run local

# 공유 개발 환경
npm run dev

# 프로덕션 빌드
npm run build:prod

# 프로덕션 서버 시작
npm run start:prod

# E2E 테스트 서버 (포트 3555)
npm run test:server
```

## 미들웨어 시스템

### API 래퍼 사용

```typescript
// src/app/api/example/route.ts
import { withPublicApi, withAuthApi, withAdminApi } from '@withwiz/middleware';
import { NextResponse } from 'next/server';

// 공개 API (인증 불필요)
export const GET = withPublicApi(async (ctx) => {
  return NextResponse.json({ message: 'Hello' });
});

// 인증 필요 API
export const POST = withAuthApi(async (ctx) => {
  const userId = ctx.user!.id;
  return NextResponse.json({ userId });
});

// 관리자 전용 API
export const DELETE = withAdminApi(async (ctx) => {
  return NextResponse.json({ deleted: true });
});
```

### 커스텀 미들웨어 체인

```typescript
import { withCustomApi, MiddlewareChain } from '@withwiz/middleware';
import { errorHandlerMiddleware } from '@withwiz/middleware';
import { initRequestMiddleware } from '@withwiz/middleware';
import { createRateLimitMiddleware } from '@withwiz/middleware';

export const POST = withCustomApi(
  async (ctx) => {
    return NextResponse.json({ data: 'custom' });
  },
  (chain) => chain
    .use(errorHandlerMiddleware)
    .use(initRequestMiddleware)
    .use(createRateLimitMiddleware('custom'))
);
```

### 미들웨어 체인 순서

```
errorHandlerMiddleware
       ↓
securityMiddleware (TRACE/TRACK 차단, Content-Type 검증)
       ↓
corsMiddleware
       ↓
initRequestMiddleware (requestId, locale, startTime)
       ↓
authMiddleware (선택적)
       ↓
adminMiddleware (선택적)
       ↓
rateLimitMiddleware
       ↓
responseLoggerMiddleware
       ↓
handler (비즈니스 로직)
```

## 의존성 규칙

```
✅ 허용 (단방향):
src/app/        → src/shared/@withwiz/
src/lib/        → src/shared/@withwiz/
src/components/ → src/shared/@withwiz/

❌ 금지 (역방향):
src/shared/@withwiz/ → src/lib/
src/shared/@withwiz/ → src/app/
```

`src/shared/@withwiz/`는 프로젝트에 독립적이어야 하며, 다른 프로젝트에서 그대로 재사용 가능해야 합니다.

## 프로젝트 타입별 추천 설정

| 프로젝트 타입 | DB | 캐시 | 인증 | 추가 모듈 |
|--------------|-----|------|------|----------|
| SaaS | PostgreSQL | Hybrid | JWT+OAuth | Rate Limit, Analytics |
| 블로그 | PostgreSQL | InMemory | JWT Only | i18n |
| 이커머스 | PostgreSQL | Hybrid | JWT+OAuth | Email, Analytics |
| 포트폴리오 | SQLite | None | None | - |
| API 서버 | PostgreSQL | Redis | JWT | Rate Limit, API Docs |

## 템플릿 목록

### 설정 파일
- `package.json.template` - Node 20+, Next.js 15, React 19
- `tsconfig.json.template` - 경로 alias (@/*, @withwiz/*)
- `next.config.js.template` - standalone, 보안 헤더
- `postcss.config.mjs.template` - Tailwind CSS 4
- `components.json.template` - shadcn/ui

### 환경 변수
- `.env.example.template`
- `.env.local.template`
- `.env.dev.template`
- `.env.production.template`
- `.env.test.template`

### 스크립트
- `scripts/local-startup.sh.template`
- `scripts/dev-startup.sh.template`
- `scripts/build.sh.template`
- `scripts/start.sh.template`
- `scripts/test-server-startup.sh.template`

### 미들웨어
- `types.ts.template` - IApiContext, TApiMiddleware
- `middleware-chain.ts.template` - MiddlewareChain 클래스
- `auth.ts.template` - JWT 인증
- `cors.ts.template` - CORS 설정
- `error-handler.ts.template` - AppError 처리
- `rate-limit.ts.template` - Rate Limiting
- `security.ts.template` - 보안 헤더
- `init-request.ts.template` - 요청 초기화
- `response-logger.ts.template` - 로깅
- `wrappers.ts.template` - API 래퍼
- `index.ts.template` - 통합 export

## 문제 해결

| 문제 | 해결 |
|------|------|
| prisma generate 실패 | `npx prisma generate` 실행 |
| TypeScript 경로 에러 | tsconfig.json paths 확인 |
| 빌드 실패 | `rm -rf .next && npm run build` |
| 포트 충돌 | `PORT=3001 npm run dev` |
| JWT 에러 | JWT_SECRET 32자 이상 확인 |

## 요구사항

- Node.js >= 20.0.0
- npm >= 10.0.0
- Claude Code CLI

## 라이선스

MIT

## 참조

- [url-shortener-mvp](https://github.com/your-repo/url-shortener-mvp) - 원본 프로젝트
- [Next.js 15 Documentation](https://nextjs.org/docs)
- [Tailwind CSS 4](https://tailwindcss.com)
- [shadcn/ui](https://ui.shadcn.com)
