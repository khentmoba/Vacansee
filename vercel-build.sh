#!/bin/bash

# 1. Install Flutter (Stable branch)
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# 2. Initialize Flutter
echo "Initializing Flutter..."
flutter doctor

# 3. Build the project for Web
echo "Building Flutter Web..."
flutter build web --release

# 4. Success message
echo "Build complete! Vercel will now deploy the build/web folder."
