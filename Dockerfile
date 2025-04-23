FROM 1panel/maxkb:latest

# Set working directory
WORKDIR /opt/maxkb

# Copy new integration files
COPY ./apps/integrations /opt/maxkb/app/apps/integrations/
COPY ./apps/shipping /opt/maxkb/app/apps/shipping/

# Install additional dependencies
RUN pip install --no-cache-dir \
    slack-sdk \
    dialpad-python-sdk \
    requests-oauthlib

# Environment variables
ENV PYTHONPATH=/opt/maxkb/app

# Update entrypoint if necessary
COPY ./entrypoint.sh /opt/maxkb/entrypoint.sh
RUN chmod +x /opt/maxkb/entrypoint.sh

ENTRYPOINT ["/opt/maxkb/entrypoint.sh"]
