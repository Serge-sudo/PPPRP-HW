import requests
import time

for i in range(12):
    try:
        response = requests.get('http://time-service.default.svc.cluster.local:5000/statistics')
        with open('/data/logfile.log', 'w') as file:
            file.write(response.text + '\n')
    except Exception as e:
        print(f"Failed to fetch statistics: {str(e)}")
    time.sleep(5)
