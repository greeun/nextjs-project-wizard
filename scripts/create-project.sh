#!/bin/bash
# Next.js 15 Project Generator Script
# Usage: ./create-project.sh <project-name> <target-path>

set -e

PROJECT_NAME="${1:-my-nextjs-app}"
TARGET_PATH="${2:-.}"
FULL_PATH="$TARGET_PATH/$PROJECT_NAME"

echo "Creating Next.js 15 project: $PROJECT_NAME"
echo "Target path: $FULL_PATH"

# Create project directory
mkdir -p "$FULL_PATH"
cd "$FULL_PATH"

# Create directory structure
echo "Creating directory structure..."
mkdir -p src/app/api
mkdir -p src/app/\[locale\]
mkdir -p src/components/ui
mkdir -p src/components/layouts
mkdir -p src/components/commons
mkdir -p src/lib/services
mkdir -p src/lib/validators
mkdir -p src/lib/hooks
mkdir -p src/lib/constants
mkdir -p src/lib/utils
mkdir -p src/lib/middleware
mkdir -p src/lib/config
mkdir -p src/shared/@withwiz/constants
mkdir -p src/shared/@withwiz/utils
mkdir -p src/shared/@withwiz/validators
mkdir -p src/shared/@withwiz/hooks
mkdir -p src/types
mkdir -p prisma
mkdir -p docs/claude
mkdir -p scripts/database
mkdir -p tests/01-unit
mkdir -p tests/02-integration
mkdir -p tests/03-api
mkdir -p tests/04-e2e
mkdir -p public

echo "Directory structure created successfully!"
echo ""
echo "Next steps:"
echo "1. cd $FULL_PATH"
echo "2. npm install"
echo "3. Configure .env.local"
echo "4. npm run dev"
