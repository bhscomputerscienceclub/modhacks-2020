import requests
import json


url = 'https://api.edamam.com/api/food-database/v2/parser'
data = {
"app_id":"8add3e70",
"app_key": "683c1aeb66ea0781dfff37d90754f831",
"upc": "04954806"
}

a = requests.get(url,params=data)
th = json.loads(a.text)

print(th)