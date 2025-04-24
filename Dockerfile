FROM 1panel/maxkb:latest

# Set working directory
WORKDIR /opt/maxkb

# Environment variables
ENV PYTHONPATH=/opt/maxkb/app

# Install additional dependencies
RUN pip install --no-cache-dir \
    slack-sdk \
    dialpad-python-sdk \
    requests-oauthlib

# Copy new integration files
COPY ./apps/integrations /opt/maxkb/app/apps/integrations/
COPY ./apps/shipping /opt/maxkb/app/apps/shipping/

# Expose the port
EXPOSE 8080

# Start command
CMD ["python", "/opt/maxkb/app/main.py", "start", "all"]
