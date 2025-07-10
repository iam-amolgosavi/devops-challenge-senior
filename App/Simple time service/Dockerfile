# Use a slim Python 3.9 image for smaller image size
FROM python:3.9-slim-buster

# Set default port environment variable
ENV PORT=5000

# Set the working directory inside the container
WORKDIR /app

# Copy the Python dependencies first
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Create a non-root user for security
RUN groupadd -r simpletimeservice && \
    useradd --no-log-init -r -g simpletimeservice -u 1001 simpletimeservice

# Copy your application code
COPY app.py .

# Change ownership to the non-root user
RUN chown -R simpletimeservice:simpletimeservice /app

# Switch to non-root user
USER simpletimeservice

# Expose the container port (informational, actual port mapping happens in `docker run -p`)
EXPOSE 5000

# Start the application with Gunicorn using shell form to allow ENV substitution
CMD gunicorn -b 0.0.0.0:${PORT} app:app
