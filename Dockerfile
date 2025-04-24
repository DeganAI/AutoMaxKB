FROM 1panel/maxkb:latest

# Set working directory
WORKDIR /opt/maxkb

# Set labels for better maintainability
LABEL maintainer="AutoMaxKB Maintainer"
LABEL description="AutoMaxKB - AI-Powered Automated Shipping Coordination Platform"
LABEL version="1.0.0"

# Environment variables
ENV PYTHONPATH=/opt/maxkb/app
ENV PYTHONUNBUFFERED=1
ENV TZ=UTC

# Install additional dependencies
RUN pip install --no-cache-dir \
    slack-sdk \
    dialpad-python-sdk \
    requests-oauthlib

# Copy new integration files
COPY ./apps/integrations /opt/maxkb/app/apps/integrations/
COPY ./apps/shipping /opt/maxkb/app/apps/shipping/

# Create entrypoint.sh file directly
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Function to log messages\n\
log_message() {\n\
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1"\n\
}\n\
\n\
# Initialize directories if they do not exist\n\
log_message "Initializing directories..."\n\
mkdir -p /var/lib/postgresql/data\n\
mkdir -p /opt/maxkb/app/sandbox/python-packages\n\
\n\
# Run database migrations\n\
log_message "Running database migrations..."\n\
python /opt/maxkb/app/main.py upgrade_db\n\
\n\
# Collect static files\n\
log_message "Collecting static files..."\n\
python /opt/maxkb/app/main.py collect_static\n\
\n\
# Start the application\n\
log_message "Starting AutoMaxKB application..."\n\
exec python /opt/maxkb/app/main.py start all "$@"\n\
' > /opt/maxkb/entrypoint.sh && \
    chmod +x /opt/maxkb/entrypoint.sh

# Expose the port that MaxKB runs on
EXPOSE 8080

# Set the entrypoint script
ENTRYPOINT ["/opt/maxkb/entrypoint.sh"]
