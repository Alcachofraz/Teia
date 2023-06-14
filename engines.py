import json
import os

import requests

api_host = 'https://api.stability.ai'
url = f"{api_host}/v1/engines/list"

api_key = 'sk-DY0hd8PcPKrQCRtiGL6bzRObUbOmBjgGHuQJudHTGHdjcCZa'

response = requests.get(url, headers={
    "Authorization": f"Bearer {api_key}"
})

if response.status_code != 200:
    raise Exception("Non-200 response: " + str(response.text))

# Do something with the payload...
payload = response.json()

print(json.dumps(response.json(), sort_keys=True, indent=4))
