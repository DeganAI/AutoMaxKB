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

# Create entrypoint script directly in the image
RUN echo '#!/bin/bash \n\
set -e \n\
\n\
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Starting AutoMaxKB..." \n\
\n\
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Running database migrations..." \n\
python /opt/maxkb/app/main.py upgrade_db \n\
\n\
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Collecting static files..." \n\
python /opt/maxkb/app/main.py collect_static \n\
\n\
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Starting application..." \n\
exec python /opt/maxkb/app/main.py start all "$@" \n\
' > /opt/maxkb/entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /opt/maxkb/entrypoint.sh

# Expose the port
EXPOSE 8080

# Set the entrypoint
ENTRYPOINT ["/opt/maxkb/entrypoint.sh"]
