#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
  echo -e "\n${BLUE}===========================${NC}"
  echo -e "${GREEN}$1${NC}"
  echo -e "${BLUE}===========================${NC}\n"
}

# Function to check command existence
check_command() {
  if command -v $1 &> /dev/null; then
    echo -e "${GREEN}✓${NC} $1 is installed"
    if [ -n "$2" ]; then
      eval "$2"
    fi
  else
    echo -e "${RED}✗${NC} $1 is not installed"
    return 1
  fi
}

# Function to check version requirements
check_version() {
  local version=$1
  local required=$2
  local name=$3
  
  if [[ "$version" == *"$required"* ]]; then
    echo -e "   ${GREEN}✓${NC} $name version $version is compatible"
  else
    echo -e "   ${YELLOW}⚠${NC} $name version $version might not be fully compatible (expected $required)"
  fi
}

print_header "Environment Check for Puppeteer with Bun"

# Check required tools
echo "Checking required tools:"
check_command "docker" "docker_version=\$(docker --version)"
check_command "docker compose" "compose_version=\$(docker compose version)"
check_command "bun" "bun_version=\$(bun --version)"

# Print version information
if [ -n "$docker_version" ]; then
  echo -e "\nVersion information:"
  echo -e "- Docker: $docker_version"
fi

if [ -n "$compose_version" ]; then
  echo -e "- Docker Compose: $compose_version"
fi

if [ -n "$bun_version" ]; then
  echo -e "- Bun: $bun_version"
  check_version "$bun_version" "1.0" "Bun"
fi

# Check project configuration
print_header "Project Configuration Check"

# Check if Dockerfile exists
if [ -f "Dockerfile" ]; then
  echo -e "${GREEN}✓${NC} Dockerfile found"
else
  echo -e "${RED}✗${NC} Dockerfile not found"
fi

# Check if docker-compose.yml exists
if [ -f "docker-compose.yml" ]; then
  echo -e "${GREEN}✓${NC} docker-compose.yml found"
else
  echo -e "${RED}✗${NC} docker-compose.yml not found"
fi

# Check if package.json exists
if [ -f "package.json" ]; then
  echo -e "${GREEN}✓${NC} package.json found"
  
  # Check if puppeteer is in package.json
  if grep -q '"puppeteer"' package.json; then
    echo -e "   ${GREEN}✓${NC} Puppeteer dependency found in package.json"
  else
    echo -e "   ${RED}✗${NC} Puppeteer dependency not found in package.json"
  fi
else
  echo -e "${RED}✗${NC} package.json not found"
fi

# Check for index.ts
if [ -f "index.ts" ]; then
  echo -e "${GREEN}✓${NC} index.ts found"
else
  echo -e "${RED}✗${NC} index.ts not found"
fi

# Check if screenshots directory exists
if [ -d "screenshots" ]; then
  echo -e "${GREEN}✓${NC} Screenshots directory exists"
  
  # Check if screenshots directory is writable
  if [ -w "screenshots" ]; then
    echo -e "   ${GREEN}✓${NC} Screenshots directory is writable"
  else
    echo -e "   ${RED}✗${NC} Screenshots directory is not writable"
    echo -e "   Run: chmod 777 screenshots"
  fi
else
  echo -e "${YELLOW}⚠${NC} Screenshots directory does not exist (will be created at runtime)"
fi

print_header "Ready to Run"
echo -e "You can now run the application with the following commands:"
echo -e ""
echo -e "${CYAN}# Run in development mode (browser visible, DevTools enabled)${NC}"
echo -e "./run.sh --dev"
echo -e ""
echo -e "${CYAN}# Run in production mode (headless, no DevTools)${NC}"
echo -e "./run.sh --prod"
echo -e ""
echo -e "${CYAN}# Or use Docker Compose directly${NC}"
echo -e "docker compose --profile dev up    # Development mode"
echo -e "docker compose --profile prod up   # Production mode"