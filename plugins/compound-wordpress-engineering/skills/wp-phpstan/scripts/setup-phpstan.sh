#!/usr/bin/env bash
set -euo pipefail

# setup-phpstan.sh — Install PHPStan with WordPress extensions
#
# Usage: ./setup-phpstan.sh

echo "Setting up PHPStan with WordPress extensions..."
echo ""

# Check for Composer
if ! command -v composer &>/dev/null; then
  echo "Error: Composer is required but not installed."
  echo "Install: https://getcomposer.org/download/"
  exit 1
fi

# Check for composer.json
if [ ! -f composer.json ]; then
  echo "No composer.json found. Initializing..."
  composer init --no-interaction --stability=stable
fi

# Install PHPStan
echo "Installing PHPStan..."
composer require --dev phpstan/phpstan --no-interaction 2>/dev/null || true

# Install WordPress extension
echo "Installing PHPStan WordPress extension..."
composer require --dev szepeviktor/phpstan-wordpress --no-interaction 2>/dev/null || true

# Verify installation
echo ""
echo "Verification:"
if vendor/bin/phpstan --version 2>/dev/null; then
  echo "PHPStan: installed"
else
  echo "PHPStan: FAILED to install"
  exit 1
fi

# Create phpstan.neon if it doesn't exist
if [ ! -f phpstan.neon ] && [ ! -f phpstan.neon.dist ]; then
  cat > phpstan.neon << 'NEOF'
includes:
  - vendor/szepeviktor/phpstan-wordpress/extension.neon

parameters:
  level: 5
  paths:
    - .
  excludePaths:
    - vendor
    - node_modules
    - tests
    - build
NEOF
  echo "Created: phpstan.neon"
else
  echo "Config already exists."
fi

echo ""
echo "Setup complete!"
echo ""
echo "Usage:"
echo "  vendor/bin/phpstan analyse"
echo "  vendor/bin/phpstan analyse --level=5 includes/"
