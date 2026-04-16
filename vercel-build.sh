#!/bin/bash
set -e

# 1. Install Flutter (Stable branch)
echo ">>> Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# 2. Verify Flutter is accessible
echo ">>> Flutter version:"
flutter --version

# 3. Get dependencies
echo ">>> Getting dependencies..."
flutter pub get

# 4. Build for Web with the correct base href
echo ">>> Building Flutter Web..."
flutter build web --release --base-href /

echo ">>> Build complete!"
