
# python:3.9-slim-buster is a good choice for smaller image size
FROM python:3.9-slim-buster
# This allows the application to pick up the port dynamically
ENV PORT=5000

# Set the working directory inside the container
WORKDIR /app

# Copy only the requirements file first to leverage Docker layer caching
COPY requirements.txt .

# Install Python dependencies

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Create a non-root user and group
# This is a crucial security practice.
# simpletimeservice: The user and group name
# -u 1001: Assign a specific UID (User ID)
# -g simpletimeservice: Assign the user to the simpletimeservice group
# -s /bin/bash: Set the shell (optional, but good for debugging if needed)
# -D: Do not create a home directory
RUN groupadd -r simpletimeservice && useradd --no-log-init -r -g simpletimeservice -u 1001 simpletimeservice

# Copy the application code into the container
COPY app.py .

# Change ownership of the /app directory to the non-root user
# This ensures the non-root user has necessary permissions
RUN chown -R simpletimeservice:simpletimeservice /app

# Switch to the non-root user
# All subsequent commands will run as this user
USER simpletimeservice

# Expose the port the application listens on
# This is for documentation and network configuration
EXPOSE ${PORT}

CMD ["gunicorn", "-b", "0.0.0.0:${PORT}", "app:app"]

