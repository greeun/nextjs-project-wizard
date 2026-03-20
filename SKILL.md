---
name: nextjs-project-wizard
description: Use when user wants to create a new Next.js 15 project with Clean Architecture structure. Triggers on "새 프로젝트", "프로젝트 생성", "create project", "scaffold project", "init project", "프로젝트 세팅", "boilerplate setup".
---

# Next.js 15 Project Wizard

현재 url-shortener-mvp 프로젝트 구조를 기반으로 새 Next.js 15 프로젝트를 생성하는 인터랙티브 위저드.

## When to Use

- 새 Next.js 15 프로젝트 생성 요청
- url-shortener-mvp와 유사한 구조의 프로젝트 필요
- Clean Architecture 기반 웹앱 스캐폴딩

## Wizard Workflow

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

---

## Phase 1: 프로젝트 기본 정보 수집

**Goal**: 프로젝트 핵심 정보 파악

질문 (한 번에 하나씩):

1. "프로젝트 이름은 무엇인가요? (예: my-awesome-app)"
2. "프로젝트를 어느 경로에 생성할까요? (기본: 현재 디렉토리)"
3. "프로젝트의 주제/도메인은 무엇인가요? (예: 전자상거래, 블로그, SaaS)"
4. "프로젝트의 핵심 기능 3가지를 알려주세요."
5. "프로젝트 설명을 한 줄로 작성해주세요."

**Output**: 프로젝트 메타데이터

---

## Phase 2: 기술 스택 선택

**Goal**: 필요한 기술 스택 결정

### 2.1 데이터베이스

| 옵션 | 설명 |
|------|------|
| PostgreSQL + Prisma | 관계형 DB, ORM 포함 (권장) |
| MongoDB + Mongoose | NoSQL 문서 DB |
| SQLite + Prisma | 경량 로컬 DB |
| None | 데이터베이스 없음 |

### 2.2 캐시 시스템

| 옵션 | 설명 |
|------|------|
| Redis (Upstash) | 프로덕션 권장 |
| InMemory Only | 개발/소규모용 |
| Hybrid | Redis + InMemory 폴백 (권장) |
| None | 캐시 없음 |

### 2.3 인증 시스템

| 옵션 | 설명 |
|------|------|
| JWT + OAuth | Google, GitHub, Apple 지원 (권장) |
| JWT Only | 이메일/비밀번호만 |
| None | 인증 없음 |

### 2.4 UI 프레임워크

| 옵션 | 설명 |
|------|------|
| shadcn/ui + Tailwind | 현대적 컴포넌트 (권장) |
| Tailwind Only | CSS만 |
| None | 스타일링 없음 |

---

## Phase 3: 기능 모듈 선택

**Goal**: 포함할 기능 모듈 결정

### 필수 모듈 (자동 포함)

- 프로젝트 구조 (src/, docs/, scripts/)
- TypeScript 설정 (tsconfig.json, 경로 alias)
- ESLint + Prettier 설정
- 환경 변수 템플릿 (.env.example)
- 기본 스크립트 (local, dev, build)

### 선택 모듈

| 모듈 | 설명 | 기본값 |
|------|------|--------|
| i18n | 다국어 지원 (ko, en, ja) | Yes |
| Testing | Jest + Playwright 설정 | Yes |
| Middleware | API 미들웨어 체인 시스템 | Yes |
| Docker | Dockerfile + docker-compose | No |
| API Docs | Swagger/OpenAPI | No |
| Rate Limiting | API 요청 제한 | No |
| Email | Nodemailer + 큐 시스템 | No |
| Analytics | 클릭 추적, 통계 | No |

---

## Phase 4: 프로젝트 생성 실행

**Goal**: 프로젝트 파일 생성

### 4.1 디렉토리 구조 생성

```bash
mkdir -p {project-name}
cd {project-name}

# 핵심 디렉토리
mkdir -p src/app/api
mkdir -p src/app/\[locale\]
mkdir -p src/components/ui
mkdir -p src/components/layouts
mkdir -p src/lib/services
mkdir -p src/lib/validators
mkdir -p src/lib/hooks
mkdir -p src/lib/constants
mkdir -p src/lib/utils
mkdir -p src/lib/middleware
mkdir -p src/shared/@withwiz/constants
mkdir -p src/shared/@withwiz/utils
mkdir -p src/shared/@withwiz/validators
mkdir -p src/shared/@withwiz/middleware
mkdir -p src/shared/@withwiz/error
mkdir -p src/shared/@withwiz/auth
mkdir -p src/shared/@withwiz/logger
mkdir -p src/types
mkdir -p prisma
mkdir -p docs/claude
mkdir -p scripts/database
mkdir -p scripts/build
mkdir -p tests/01-unit
mkdir -p tests/02-integration
mkdir -p tests/03-api
mkdir -p tests/04-e2e
```

### 4.2 환경 변수 파일 생성

프로젝트 환경별 설정 파일 (.env.*):

| 파일 | 용도 | 특징 |
|------|------|------|
| `.env.example` | 템플릿 | 버전 관리에 포함, 실제 값 없음 |
| `.env.local` | 로컬 개발 | 개인 환경, InMemory 캐시, Rate Limit 비활성화 |
| `.env.dev` | 공유 개발 | 개발 DB, Redis+InMemory Hybrid |
| `.env.production` | 프로덕션 | 실제 서비스, Redis, Rate Limit 활성화 |
| `.env.test` | 테스트 | 포트 3555, 로깅 최소화, InMemory 전용 |

**환경별 주요 설정 차이**:

```
                    .env.local    .env.dev     .env.production  .env.test
----------------------------------------------------------------
PORT                3000          3000         -                3555
CACHE_REDIS         false         true         true             false
CACHE_INMEMORY      true          true         true             true
RATE_LIMIT          false         true         true             false
LOG_LEVEL           debug         debug        warn             error
LOG_CONSOLE         true          true         true             false
```

### 4.3 스크립트 파일 생성

환경별 실행 스크립트 (`scripts/` 디렉토리):

| 스크립트 | 명령어 | 용도 |
|---------|--------|------|
| `local-startup.sh` | `npm run local` | 로컬 개발 서버 (.env.local) |
| `dev-startup.sh` | `npm run dev` | 공유 개발 환경 (.env.dev) |
| `build.sh` | `npm run build:prod` | 프로덕션 빌드 (.env.production) |
| `start.sh` | `npm run start:prod` | 프로덕션 서버 시작 |
| `test-server-startup.sh` | `npm run test:server` | E2E 테스트 서버 (.env.test, 포트 3555) |

**package.json scripts 섹션**:
```json
{
  "scripts": {
    "local": "./scripts/local-startup.sh",
    "dev": "./scripts/dev-startup.sh",
    "build:prod": "./scripts/build.sh",
    "start:prod": "./scripts/start.sh",
    "test:server": "./scripts/test-server-startup.sh"
  }
}
```

### 4.4 미들웨어 시스템 생성

Express.js 스타일 미들웨어 체인 (`src/shared/@withwiz/middleware/`):

| 파일 | 역할 |
|------|------|
| `types.ts` | IApiContext, TApiMiddleware 타입 |
| `middleware-chain.ts` | MiddlewareChain 클래스 |
| `auth.ts` | JWT 인증, 관리자 권한 검증 |
| `cors.ts` | CORS 헤더 설정 |
| `error-handler.ts` | AppError, ZodError 처리 |
| `rate-limit.ts` | IP 기반 요청 제한 |
| `security.ts` | TRACE/TRACK 차단, Content-Type 검증 |
| `init-request.ts` | requestId, locale, startTime 초기화 |
| `response-logger.ts` | 요청/응답 로깅 |
| `wrappers.ts` | withPublicApi, withAuthApi, withAdminApi |
| `index.ts` | 통합 내보내기 |

**API 래퍼 사용 예시**:
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

**미들웨어 체인 순서**:
```
errorHandlerMiddleware → securityMiddleware → corsMiddleware
       ↓
initRequestMiddleware → authMiddleware (선택) → rateLimitMiddleware
       ↓
responseLoggerMiddleware → handler
```

### 4.5 설정 파일 생성

**package.json** 템플릿:
```json
{
  "name": "{project-name}",
  "version": "0.1.0",
  "private": true,
  "engines": {
    "node": ">=20.0.0 <24.0.0",
    "npm": ">=10.0.0"
  },
  "scripts": {
    "local": "scripts/local-startup.sh",
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint . --ext .ts,.tsx",
    "test": "jest",
    "test:e2e": "npx playwright test",
    "prisma:generate": "prisma generate",
    "prisma:migrate:dev": "prisma migrate dev"
  }
}
```

**tsconfig.json** 템플릿:
```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"],
      "@withwiz/*": ["./src/shared/@withwiz/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

**next.config.js** 템플릿:
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  experimental: {
    serverActions: { bodySizeLimit: '2mb' }
  },
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: '**' }
    ]
  }
};
module.exports = nextConfig;
```

### 4.6 핵심 파일 생성

**src/app/layout.tsx**:
```tsx
import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: '{project-name}',
  description: '{project-description}'
};

export default function RootLayout({
  children
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <body>{children}</body>
    </html>
  );
}
```

**src/app/page.tsx**:
```tsx
export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1 className="text-4xl font-bold">{project-name}</h1>
      <p className="mt-4 text-lg text-gray-600">{project-description}</p>
    </main>
  );
}
```

**src/app/globals.css**:
```css
@import "tailwindcss";
```

### 4.7 의존성 설치

```bash
# 핵심 의존성
npm install next@15 react@19 react-dom@19 typescript

# Tailwind CSS 4
npm install tailwindcss@4 @tailwindcss/postcss

# 선택적 의존성 (Phase 2 선택에 따라)
# Database: npm install @prisma/client prisma
# Cache: npm install @upstash/redis
# Auth: npm install jose bcryptjs
# UI: npx shadcn@latest init

# 개발 의존성
npm install -D @types/node @types/react @types/react-dom eslint eslint-config-next
```

### 4.8 CLAUDE.md 생성

```markdown
# CLAUDE.md

## Basic Requirements

**Language Preference**: 모든 대화와 문서는 한국어로 작성

**Local Environment**: `npm run local` 명령으로 로컬 서버 실행

## Project Overview

{project-description}

**Tech Stack**: Next.js 15, React 19, TypeScript, {selected-stack}

## Essential Commands

\`\`\`bash
npm run local     # 로컬 서버
npm run build     # 프로덕션 빌드
npm run test      # 테스트 실행
\`\`\`

## Architecture

\`\`\`
src/
├── app/          # Next.js App Router
├── components/   # React 컴포넌트
├── lib/          # 비즈니스 로직
├── shared/       # 재사용 가능 코드
└── types/        # TypeScript 타입
\`\`\`

## Dependency Rules

- `src/lib/` → `src/shared/@withwiz/` (단방향만 허용)
- `src/shared/@withwiz/` → `src/lib/` (금지)
```

---

## Phase 5: 검증 및 서버 구동

**Goal**: 프로젝트가 정상 작동하는지 확인

### 5.1 파일 구조 검증

```bash
# 필수 파일 확인
ls -la package.json tsconfig.json next.config.js
ls -la src/app/layout.tsx src/app/page.tsx
```

### 5.2 의존성 설치 확인

```bash
npm install
```

### 5.3 빌드 테스트

```bash
npm run build
```

### 5.4 개발 서버 구동

```bash
npm run dev
# 또는
npm run local
```

### 5.5 최종 검증

- [ ] 서버가 에러 없이 시작됨
- [ ] http://localhost:3000 접속 가능
- [ ] 홈 페이지 렌더링 정상
- [ ] TypeScript 에러 없음
- [ ] ESLint 에러 없음

---

## Quick Reference

### 프로젝트 타입별 추천 설정

| 프로젝트 타입 | DB | 캐시 | 인증 | 추가 모듈 |
|--------------|-----|------|------|----------|
| SaaS | PostgreSQL | Hybrid | JWT+OAuth | Rate Limit, Analytics |
| 블로그 | PostgreSQL | InMemory | JWT Only | i18n |
| 이커머스 | PostgreSQL | Hybrid | JWT+OAuth | Email, Analytics |
| 포트폴리오 | SQLite | None | None | - |
| API 서버 | PostgreSQL | Redis | JWT | Rate Limit, API Docs |

### Common Issues

| 문제 | 해결 |
|------|------|
| prisma generate 실패 | `npx prisma generate` 실행 |
| TypeScript 경로 에러 | tsconfig.json paths 확인 |
| 빌드 실패 | `rm -rf .next && npm run build` |
| 포트 충돌 | `PORT=3001 npm run dev` |

---

## Resources

### Templates (생성 시 자동 적용)

**설정 파일**:
- `package.json.template` - Node 20+, Next.js 15, React 19
- `tsconfig.json.template` - 경로 alias (@/*, @withwiz/*)
- `next.config.js.template` - standalone output, 보안 헤더
- `postcss.config.mjs.template` - Tailwind CSS 4
- `components.json.template` - shadcn/ui New York 스타일
- `.gitignore.template` - Node.js 표준

**환경 변수**:
- `.env.example.template` - 전체 변수 템플릿
- `.env.local.template` - 로컬 개발 환경
- `.env.dev.template` - 공유 개발 환경
- `.env.production.template` - 프로덕션 환경
- `.env.test.template` - 테스트 환경 (포트 3555)

**스크립트**:
- `scripts/local-startup.sh.template` - 로컬 서버
- `scripts/dev-startup.sh.template` - 개발 서버
- `scripts/build.sh.template` - 프로덕션 빌드
- `scripts/start.sh.template` - 프로덕션 서버
- `scripts/test-server-startup.sh.template` - 테스트 서버

**미들웨어 시스템** (`src/shared/@withwiz/middleware/`):
- `types.ts.template` - IApiContext, TApiMiddleware
- `middleware-chain.ts.template` - MiddlewareChain 클래스
- `auth.ts.template` - JWT 인증 미들웨어
- `cors.ts.template` - CORS 헤더 설정
- `error-handler.ts.template` - AppError 처리
- `rate-limit.ts.template` - In-Memory Rate Limiting
- `security.ts.template` - 보안 헤더 및 검증
- `init-request.ts.template` - 요청 초기화
- `response-logger.ts.template` - 응답 로깅
- `wrappers.ts.template` - withPublicApi, withAuthApi, withAdminApi
- `index.ts.template` - 통합 export

**소스 코드**:
- `src/app/layout.tsx.template` - 루트 레이아웃
- `src/app/page.tsx.template` - 홈 페이지
- `src/app/globals.css.template` - Tailwind CSS 기본

### Reference
- 원본 프로젝트: url-shortener-mvp (현재 프로젝트)
- 의존성 규칙: docs/DEPENDENCY_RULES.md
- 아키텍처: docs/claude/ARCHITECTURE.md
