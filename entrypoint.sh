#!/bin/bash
set -e

# Function to log messages
log_message() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Wait for database to be ready
wait_for_database() {
  log_message "Waiting for database to be ready..."
  # The original MaxKB uses PostgreSQL, so we need to wait for it
  until pg_isready -h localhost -p 5432; do
    log_message "PostgreSQL is unavailable - sleeping"
    sleep 2
  done
  log_message "PostgreSQL is up - continuing"
}

# Initialize directories if they don't exist
initialize_directories() {
  log_message "Initializing directories..."
  mkdir -p /var/lib/postgresql/data
  mkdir -p /opt/maxkb/app/sandbox/python-packages
  
  # Ensure proper permissions
  chown -R postgres:postgres /var/lib/postgresql/data
}

# Setup integration services
setup_integrations() {
  log_message "Setting up integration services..."
  
  # Create URL routes for integrations
  if [ ! -f /opt/maxkb/app/setup_complete ]; then
    log_message "First-time setup: Configuring integration routes"
    # Your integration setup commands can go here
    touch /opt/maxkb/app/setup_complete
  fi
}

# Run database migrations
run_migrations() {
  log_message "Running database migrations..."
  python /opt/maxkb/app/main.py upgrade_db
}

# Collect static files
collect_static() {
  log_message "Collecting static files..."
  python /opt/maxkb/app/main.py collect_static
}

# Start the application
start_application() {
  log_message "Starting AutoMaxKB application..."
  
  # Check if we're running in dev mode
  if [ "$DEV_MODE" = "true" ]; then
    log_message "Starting in development mode..."
    python /opt/maxkb/app/main.py dev web
  else
    # Start in production mode
    log_message "Starting in production mode..."
    python /opt/maxkb/app/main.py start all
  fi
}

# Main execution
main() {
  log_message "Starting AutoMaxKB container..."
  
  initialize_directories
  wait_for_database
  setup_integrations
  run_migrations
  collect_static
  
  # If custom command is provided, run it instead
  if [ "$1" ]; then
    log_message "Running custom command: $@"
    exec "$@"
  else
    # Otherwise start the application
    start_application
  fi
}

# Run the main function
main "$@"
