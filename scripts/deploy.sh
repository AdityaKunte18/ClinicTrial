#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "Building Flutter web..."
/Users/adityakunte/development/flutter/bin/flutter build web --no-tree-shake-icons

echo "Deploying to Vercel..."
npx vercel deploy --prod build/web

echo "Done!"
