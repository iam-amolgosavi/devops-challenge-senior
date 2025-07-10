# app.py
from flask import Flask, jsonify, request
from datetime import datetime
import os
import socket

app = Flask(__name__)

# Get the port from environment variable, default to 5000
PORT = int(os.environ.get("PORT", 5000))

@app.route('/')
def get_time_and_ip():
    """
    Returns the current timestamp and the visitor's IP address in JSON format.
    Handles X-Forwarded-For header for proxies.
    """
    current_time = datetime.now().isoformat()

    # Get client IP: prioritize X-Forwarded-For if available (for proxy/load balancer scenarios)
    # Otherwise, use request.remote_addr
    client_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    
    # If X-Forwarded-For contains multiple IPs (e.g., "client, proxy1, proxy2"), take the first one
    if client_ip and ',' in client_ip:
        client_ip = client_ip.split(',')[0].strip()

    # Fallback to a local IP if remote_addr is None (can happen in some test environments)
    if not client_ip:
        try:
            client_ip = socket.gethostbyname(socket.gethostname())
        except socket.gaierror:
            client_ip = "Unknown"

    response_data = {
        "timestamp": current_time,
        "ip": client_ip
    }
    return jsonify(response_data)

if __name__ == '__main__':
    # Run the Flask app
    # host='0.0.0.0' makes the server accessible from any IP address, not just localhost
    print(f"SimpleTimeService running on port {PORT}")
    app.run(host='0.0.0.0', port=PORT)

