FROM python:3.13.2-alpine

# Set the working directory
WORKDIR /app

# Copy the Python app
COPY src/ /app/src

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Give ownership of the working directory to the non-root user
RUN chown -R appuser:appgroup /app

# Install dependencies
RUN apk add --no-cache curl

# Download the precompiled Shoutrrr binary (no Go required)
RUN curl -sL "https://github.com/containrrr/shoutrrr/releases/download/v0.8.0/shoutrrr_linux_amd64.tar.gz" \
    -o /tmp/shoutrrr.tar.gz \
    && tar -xzf /tmp/shoutrrr.tar.gz -C /usr/local/bin \
    && chmod +x /usr/local/bin/shoutrrr \
    && rm /tmp/shoutrrr.tar.gz

# Copy requirements file
COPY --link requirements.txt .

# Install the requirements using uv
RUN pip install -r requirements.txt

# Switch to non-root user
USER appuser

WORKDIR /app/src

CMD ["uvicorn app:app --host 0.0.0.0 --port $API_PORT"]
