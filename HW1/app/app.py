from flask import Flask
from datetime import datetime
import json

app = Flask(__name__)
access_count = 0

@app.route('/time')
def current_time():
    global access_count
    access_count += 1
    return json.dumps({'Time': datetime.now().isoformat()})

@app.route('/statistics')
def statistics():
    return json.dumps({'Access count': access_count})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
