#!/usr/bin/env bash
set -euo pipefail

# setup-phpcs.sh — Install PHPCS with WordPress Coding Standards
#
# Usage: ./setup-phpcs.sh

echo "Setting up PHPCS with WordPress Coding Standards..."
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

# Install PHPCS
echo "Installing PHP_CodeSniffer..."
composer require --dev squizlabs/php_codesniffer --no-interaction 2>/dev/null || true

# Install WordPress Coding Standards
echo "Installing WordPress Coding Standards..."
composer require --dev wp-coding-standards/wpcs --no-interaction 2>/dev/null || true

# Install Composer installer for PHPCS standards
echo "Installing phpcodesniffer-composer-installer..."
composer require --dev dealerdirect/phpcodesniffer-composer-installer --no-interaction 2>/dev/null || true

# Verify installation
echo ""
echo "Verification:"
if vendor/bin/phpcs --version 2>/dev/null; then
  echo "PHPCS: installed"
else
  echo "PHPCS: FAILED to install"
  exit 1
fi

if vendor/bin/phpcs -i 2>/dev/null | grep -q "WordPress"; then
  echo "WPCS: registered"
else
  echo "WPCS: NOT registered — trying manual registration..."
  vendor/bin/phpcs --config-set installed_paths vendor/wp-coding-standards/wpcs 2>/dev/null || true
  if vendor/bin/phpcs -i 2>/dev/null | grep -q "WordPress"; then
    echo "WPCS: registered (manual)"
  else
    echo "WPCS: FAILED to register"
    exit 1
  fi
fi

echo ""
echo "Setup complete!"
echo ""
echo "Usage:"
echo "  vendor/bin/phpcs --standard=WordPress path/to/file.php"
echo "  vendor/bin/phpcbf --standard=WordPress path/to/file.php  # auto-fix"

# Create phpcs.xml.dist if it doesn't exist
if [ ! -f phpcs.xml.dist ]; then
  echo ""
  echo "Tip: Create a phpcs.xml.dist for project-specific configuration."
  echo "See the wp-phpcs skill references for templates."
fi
