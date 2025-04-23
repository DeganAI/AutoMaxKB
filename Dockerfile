# Base image from the original MaxKB
FROM 1panel/maxkb:latest

# Set labels for better maintainability
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="AutoMaxKB - AI-Powered Automated Shipping Coordination Platform"
LABEL version="1.0.0"

# Set working directory
WORKDIR /opt/maxkb

# Environment variables
ENV PYTHONPATH=/opt/maxkb/app
ENV PYTHONUNBUFFERED=1
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies (if needed beyond what's in the base image)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    dos2unix \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies for integrations
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    slack-sdk==2.20.3 \
    dialpad-python-sdk==0.2.1 \
    requests-oauthlib==1.3.1 \
    psycopg2-binary==2.9.9 \
    python-dotenv==1.0.0

# Create necessary directories for integrations
RUN mkdir -p /opt/maxkb/app/apps/integrations /opt/maxkb/app/apps/shipping

# Copy integration files
COPY ./apps/integrations /opt/maxkb/app/apps/integrations/
COPY ./apps/shipping /opt/maxkb/app/apps/shipping/

# Update URL configuration if you have a custom urls.py
# COPY ./urls.py /opt/maxkb/app/smartdoc/urls.py

# Copy any custom settings or configuration files
# COPY ./settings.py /opt/maxkb/app/smartdoc/settings.py

# Copy the entrypoint script
COPY ./entrypoint.sh /opt/maxkb/entrypoint.sh

# Fix line endings and make the entrypoint executable
RUN dos2unix /opt/maxkb/entrypoint.sh && \
    chmod +x /opt/maxkb/entrypoint.sh

# Create a volume for persistent data
VOLUME ["/var/lib/postgresql/data", "/opt/maxkb/app/sandbox/python-packages"]

# Expose ports
EXPOSE 8080

# Set the entrypoint script
ENTRYPOINT ["/opt/maxkb/entrypoint.sh"]

# Default command (can be overridden when running the container)
CMD ["start", "all"]
