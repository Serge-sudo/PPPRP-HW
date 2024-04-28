from flask import Flask, Response
import requests
import time

app = Flask(__name__)

@app.route('/metrics')
def metrics():
    try:
        response = requests.get('http://time-service.default.svc.cluster.local:5000/statistics')
        request_count = response.json()['Access count']
        return Response(f"request_count {request_count}\n", mimetype="text/plain")
    except requests.exceptions.RequestException as e:
        return Response(f"# HELP request_count The number of times the service has been accessed.\n# TYPE request_count counter\nrequest_count 0\n", mimetype="text/plain")

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5020)
