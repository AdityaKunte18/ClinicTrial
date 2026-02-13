#!/bin/bash
set -e

# Generate .env from Vercel environment variables
echo "SUPABASE_URL=$SUPABASE_URL" > .env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env

# Install Flutter
git clone https://github.com/flutter/flutter.git --branch stable --depth 1

# Build
flutter/bin/flutter pub get
flutter/bin/flutter build web --no-tree-shake-icons
