FROM python:3.11-slim

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

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    libpq-dev \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir \
    django==3.2.10 \
    psycopg2-binary \
    langchain \
    slack-sdk \
    dialpad-python-sdk \
    requests-oauthlib

# Create necessary directories
RUN mkdir -p /opt/maxkb/app/apps/integrations \
    /opt/maxkb/app/apps/shipping \
    /var/lib/postgresql/data \
    /opt/maxkb/app/sandbox/python-packages

# Copy application code
COPY ./apps/integrations /opt/maxkb/app/apps/integrations/
COPY ./apps/shipping /opt/maxkb/app/apps/shipping/
COPY ./main.py /opt/maxkb/app/main.py

# Create entrypoint.sh file directly
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Function to log messages\n\
log_message() {\n\
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1"\n\
}\n\
\n\
log_message "Starting AutoMaxKB application..."\n\
\n\
# Run your application\n\
python /opt/maxkb/app/main.py start all "$@"\n\
' > /opt/maxkb/entrypoint.sh && \
    chmod +x /opt/maxkb/entrypoint.sh

# Expose the port
EXPOSE 8080

# Set the entrypoint script
ENTRYPOINT ["/opt/maxkb/entrypoint.sh"]
