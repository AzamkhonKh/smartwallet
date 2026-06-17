#!/usr/bin/env bash

# ==============================================================================
# Recipe Wallet - Developer Utility Wrapper Script
# ==============================================================================

set -e

# Define paths relative to script location
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"

# Text styles
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_help() {
    echo -e "${BOLD}Recipe Wallet - Development Wrapper Utility${NC}"
    echo -e "Usage: ./manage.sh [command]"
    echo ""
    echo -e "${BOLD}Available Commands:${NC}"
    echo -e "  ${CYAN}setup${NC}      - Verify local environment prerequisites and initialize '.env'"
    echo -e "  ${CYAN}db-up${NC}      - Start PostgreSQL & Langfuse Docker containers in background"
    echo -e "  ${CYAN}db-down${NC}    - Stop database & Langfuse Docker containers"
    echo -e "  ${CYAN}backend${NC}    - Launch the Spring Boot backend locally in development mode"
    echo -e "  ${CYAN}frontend${NC}   - Start the Flutter frontend client (defaults to local device)"
    echo -e "  ${CYAN}run-all${NC}    - Spin up docker services and start the Spring Boot backend"
    echo -e "  ${CYAN}clean${NC}      - Clean Maven build artifacts and Flutter temporary files"
    echo -e "  ${CYAN}help${NC}       - Show this help menu"
    echo ""
}

check_tool() {
    local tool_name=$1
    if ! command -v "$tool_name" &> /dev/null; then
        log_warn "Prerequisite '$tool_name' was not found. Please install it to proceed."
        return 1
    else
        log_info "Prerequisite '$tool_name' is installed."
        return 0
    fi
}

case "$1" in
    setup)
        echo -e "${BOLD}Checking developer prerequisites...${NC}"
        check_tool "java" || true
        check_tool "docker" || true
        check_tool "flutter" || true
        
        # Setup .env file
        if [ ! -f "$SCRIPT_DIR/.env" ]; then
            log_info "Creating '.env' file from template..."
            cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
            log_warn "Created '.env' in root folder. Please fill in your API keys before starting services."
        else
            log_info "'.env' file already exists."
        fi
        echo -e "${GREEN}${BOLD}Setup verification complete!${NC}"
        ;;
        
    db-up)
        log_info "Starting PostgreSQL database and Langfuse services..."
        docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d
        log_info "Docker containers are up. PostgreSQL running on port 5433, Langfuse UI on port 3000."
        ;;
        
    db-down)
        log_info "Stopping database and Langfuse services..."
        docker compose -f "$SCRIPT_DIR/docker-compose.yml" down
        log_info "Docker services stopped."
        ;;
        
    backend)
        log_info "Launching Spring Boot backend..."
        if [ ! -f "$SCRIPT_DIR/.env" ]; then
            log_warn "Missing '.env' file. Running setup command first..."
            cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
            log_warn "Please populate '.env' keys, or backend might fail connecting to real APIs."
        fi
        
        cd "$BACKEND_DIR"
        # Export environment variables from .env for Maven execution
        export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
        ./mvnw spring-boot:run
        ;;
        
    frontend)
        log_info "Launching Flutter frontend..."
        cd "$FRONTEND_DIR"
        
        # Check if custom arguments or device flag passed
        if [ -n "$2" ]; then
            log_info "Running frontend with target device: $2"
            flutter run -d "$2"
        else
            log_info "Running frontend on default device/emulator..."
            flutter run
        fi
        ;;
        
    run-all)
        log_info "Starting Docker services..."
        docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d
        
        log_info "Launching Backend service..."
        cd "$BACKEND_DIR"
        export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
        ./mvnw spring-boot:run
        ;;
        
    clean)
        log_info "Cleaning backend maven build..."
        cd "$BACKEND_DIR"
        ./mvnw clean
        
        log_info "Cleaning frontend flutter..."
        cd "$FRONTEND_DIR"
        flutter clean
        
        log_info "Cleanup complete!"
        ;;
        
    help|*)
        print_help
        ;;
esac
