from flask import Flask, jsonify
from datetime import datetime
import json
import requests

app = Flask(__name__)
access_count = 0

@app.route('/time')
def current_time():
    global access_count
    access_count += 1
    response = requests.get('http://worldtimeapi.org/api/timezone/Europe/Moscow')
    if response.status_code == 200:
        data = response.json()
        return jsonify({'Time': data['datetime']})
    else:
        return jsonify({'error': 'Failed to fetch time'}), 500

@app.route('/statistics')
def statistics():
    return jsonify({'Access count': access_count})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
