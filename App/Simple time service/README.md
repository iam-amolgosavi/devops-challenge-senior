SimpleTimeService
SimpleTimeService is a minimalist microservice built with Python Flask that returns the current timestamp and the IP address of the client in a JSON format. It's designed to be lightweight, containerized, and easily deployable.

Features
Current Timestamp: Provides the server's current date and time in ISO format.

Client IP Address: Returns the IP address of the incoming request, handling X-Forwarded-For headers for proxy/load balancer compatibility.

Containerized: Packaged as a Docker image for consistent environments and easy deployment.

Non-Root Execution: Configured to run as a non-root user within the Docker container for enhanced security.

Prerequisites
Before you begin, ensure you have the following installed:

Python 3.9+ (for local development/testing)

Docker

A DockerHub account (if you plan to publish the image)

Getting Started
Follow these steps to get SimpleTimeService up and running.

1. Clone the Repository (or create files)
If you have these files locally, ensure they are in the same directory:

app.py

Dockerfile

requirements.txt

2. Local Development (Optional)
If you want to run the Flask application directly (without Docker) for development or testing:

Create a virtual environment (recommended):

python3 -m venv venv
source venv/bin/activate # On Windows: .\venv\Scripts\activate

Install dependencies:

pip install -r requirements.txt

Run the application:

python app.py

The service will start on http://0.0.0.0:5000 (or the port specified by the PORT environment variable).

3. Dockerization
Building the Docker Image
Navigate to the directory containing app.py, Dockerfile, and requirements.txt. Then, build the Docker image:

docker build -t <YOUR_DOCKERHUB_USERNAME>/simpletimeservice:latest .

Replace <YOUR_DOCKERHUB_USERNAME> with your DockerHub username.

The . indicates that the Dockerfile is in the current directory.

Running the Docker Container Locally
Once the image is built, you can run it:

docker run -p 5000:5000 <YOUR_DOCKERHUB_USERNAME>/simpletimeservice:latest

This command maps port 5000 on your host machine to port 5000 inside the container. You can now access the service at http://localhost:5000.

Testing the Service
Open your web browser or use curl:

curl http://localhost:5000

You should see a JSON response similar to this:

{
  "ip": "172.17.0.1", # This will be the IP of your Docker host or client
  "timestamp": "2023-10-27T10:30:00.123456"
}

Publishing to DockerHub
To make your image publicly available, first log in to DockerHub:

docker login

Then, push your image:

docker push <YOUR_DOCKERHUB_USERNAME>/simpletimeservice:latest

Once pushed, anyone can pull your image using docker pull <YOUR_DOCKERHUB_USERNAME>/simpletimeservice:latest.

Application Structure
app.py: The core Python Flask application.

Dockerfile: Defines the steps to build the Docker image.

requirements.txt: Lists Python dependencies.

Security Considerations
The Docker image is configured to run the application as a non-root user (simpletimeservice with UID 1001) for improved security.

The application explicitly handles X-Forwarded-For headers to correctly identify client IPs when behind proxies or load balancers.

Contributing
Feel free to fork this repository, make improvements, and submit pull requests.

License
This project is open-source and available under the MIT License.
