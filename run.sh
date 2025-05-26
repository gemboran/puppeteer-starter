#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default mode
MODE="dev"

# Function to print section headers
print_header() {
  echo -e "\n${BLUE}===========================${NC}"
  echo -e "${GREEN}$1${NC}"
  echo -e "${BLUE}===========================${NC}\n"
}

# Function to handle errors
handle_error() {
  echo -e "\n${RED}ERROR: $1${NC}"
  exit 1
}

# Function to show help
show_help() {
  echo -e "${CYAN}Usage:${NC}"
  echo -e "  $0 [options]"
  echo
  echo -e "${CYAN}Options:${NC}"
  echo -e "  -d, --dev     Run in development mode (non-headless, with devtools) [default]"
  echo -e "  -p, --prod    Run in production mode (headless, no devtools)"
  echo -e "  -h, --help    Show this help message"
  echo
  exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dev)
      MODE="dev"
      shift
      ;;
    -p|--prod)
      MODE="prod"
      shift
      ;;
    -h|--help)
      show_help
      ;;
    *)
      handle_error "Unknown option: $1"
      ;;
  esac
done

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  handle_error "Docker is not installed. Please install Docker first."
fi

# Check if Docker Compose is installed
if ! command -v docker &> /dev/null || ! docker compose version &> /dev/null; then
  handle_error "Docker Compose is not installed or not available. Please install Docker with Compose support first."
fi

# Create screenshots directory if it doesn't exist
if [ ! -d "screenshots" ]; then
  print_header "Creating screenshots directory"
  mkdir -p screenshots
  chmod 777 screenshots
fi

# Build the Docker image
print_header "Building Docker image"
docker build -t puppeteer-bun . || handle_error "Failed to build Docker image"

# Run with Docker Compose
print_header "Running container with Docker Compose in ${MODE} mode (resource limits: 1 CPU, 1GB RAM)"
echo -e "${YELLOW}Press Ctrl+C to stop the container when finished${NC}"

if [ "$MODE" == "dev" ]; then
  echo -e "${CYAN}Development mode:${NC} Browser will open in non-headless mode with DevTools enabled"
  docker compose --profile dev up
else
  echo -e "${CYAN}Production mode:${NC} Browser will run in headless mode without DevTools"
  docker compose --profile prod up
fi

# Show screenshots
print_header "Screenshots generated"
ls -la screenshots/

echo -e "\n${GREEN}Done! The screenshots are saved in the 'screenshots' directory.${NC}"
