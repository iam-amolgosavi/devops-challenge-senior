# 📦 Simple Time Service

A simple Flask-based web service that returns the current timestamp and the requester's IP address in JSON format.
The application is containerized using Docker and runs on **Gunicorn**.

---

## 🚀 Features

- Returns current timestamp and IP address of the requester
- Properly handles `X-Forwarded-For` header for Load Balancer / Proxy scenarios
- Production-ready deployment with Gunicorn
- Built for running in Docker and Kubernetes

---

## 🛠️ Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- Python 3.9+ (optional for local runs)

---

## 🏗️ Build & Run Locally with Docker

### 1. Clone the Repository

```bash
 git clone https://github.com/iam-amolgosavi/devops-challenge-senior.git
 cd devops-challenge-senior/
 cd App/
  cd 'Simple time service'/
```

### 2. Build Docker Image

```bash
docker build -t service-app1:latest .
```

### 3. Run the Container

```bash
docker run -d -p 5000:5000 -e PORT=5000 service-app1:latest
```

### 4. Access the Service

Open your browser or use `curl`:
```
EC2 public IpAdress:5000
http://localhost:5000/
```

Sample Response:
```json
{
  "timestamp": "2025-07-10T12:12:30.123456",
  "ip": "127.0.0.1"
}
```

---

## 🔧 Environment Variables

| Variable | Default | Description                          |
|---------|---------|--------------------------------------|
| PORT    | 5000    | Port the app listens on inside Docker |

---

## ☁️ Running in AWS / Kubernetes / EKS

When deploying behind an AWS Load Balancer, the app automatically extracts the correct IP from the `X-Forwarded-For` header.

---

## ✅ Authentication for Terraform / AWS (if applicable)

If you're provisioning AWS infrastructure (e.g., with Terraform), authenticate using the AWS CLI:

```bash
aws configure
```
OR export credentials:

```bash
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=ap-south-1
```

## 📝 License

This project is licensed under the MIT License.

---

## 🔍 Author

- **Amol Gosavi**
- GitHub: [iam-amolgosavi]
