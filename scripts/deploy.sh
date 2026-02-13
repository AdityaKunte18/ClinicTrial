#!/bin/bash
set -e

echo "Building Flutter web..."
/Users/adityakunte/development/flutter/bin/flutter build web --no-tree-shake-icons

echo "Deploying to Vercel..."
cd build/web
npx vercel --prod

echo "Done!"
