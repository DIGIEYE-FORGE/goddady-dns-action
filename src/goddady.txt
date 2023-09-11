import requests
import json
import re
import os

GODDADY_API_KEY = os.environ.get("GODDADY_API_KEY")
GODDADY_API_SECRET = os.environ.get("GODDADY_API_SECRET")
DOMAINS_FILTER = os.environ.get("DOMAINS_FILTER")
HOSTNAME = os.environ.get("HOSTNAME")
IP_ADDRESS = os.environ.get("IP_ADDRESS")
AUTHZ_HEADER = f'sso-key {GODDADY_API_KEY}:{GODDADY_API_SECRET}'

def getRecordDomain(host):
    domains = DOMAINS_FILTER.split(",")
    for domain in domains:
        substring_pattern = re.escape(domain)
        match = re.search(substring_pattern, host)
        if match:
            matched_text = match.group()  # Get the matched text
            print(f"Matched domain: {matched_text}")
            return matched_text
        else:
            print(f"No matched domain found in {host}")
            exit('ERROR: the HOSTNAME provided ("{}") does not matched any domain'.format(host))


def getRecordName(hostname):
    domains = DOMAINS_FILTER.split(",")
    for domain in domains:
        # Define the fixed substring to search for
        substring_to_match = domain

        # Escape the substring using re.escape
        escaped_substring = re.escape(substring_to_match)

        # Define a regex pattern to match the escaped substring
        domain_pattern = r'^(.*?)(?=\.' + escaped_substring + r'|$)'

        # Use re.search() to find matches
        match = re.search(domain_pattern, hostname)

        if match:
            extracted_domain = match.group(1)
            print(f"Extracted Domain: {extracted_domain}")
            return extracted_domain
        else:
            print("No match found.")
            exit('ERROR: Cannot extract the name of the HOSTNAME provided ("{}") '.format(hostname))
            


def getDomainRecordByName(name, domain):
    custom_headers = {
        'Authorization': AUTHZ_HEADER,
    }

    http_url = f'https://api.godaddy.com/v1/domains/{domain}/records/A/{name}'
    response = requests.get(http_url, headers=custom_headers)
    if response.status_code == 200:
        # Parse the response content into a JSON object
        json_data = json.loads(response.text)
        # Print the response content (the HTML content in this case)

        if len(json_data) == 0:
            print(f'{name} record not found')
        else:
            print(json_data)
    else:
        print(
            f'HTTP GET request failed with status code {response.status_code}')


def getDomainRecords(domain):
    custom_headers = {
        'Authorization': AUTHZ_HEADER,
    }

    http_url = f'https://api.godaddy.com/v1/domains/{domain}/records'
    print(f'http_rul {http_url}')
    response = requests.get(http_url, headers=custom_headers)
    if response.status_code == 200:
        # Parse the response content into a JSON object
        json_data = json.loads(response.text)
        # Print the response content (the HTML content in this case)
        print(json_data)
    else:
        print(
            f'HTTP GET request failed with status code {response.status_code}')


def createDomainRecords(name, ip_address="154.144.241.232", ttl=600, domain="digieye.io"):
    headers = {
        'Content-Type': 'application/json',
        'Authorization': AUTHZ_HEADER,
    }

    url = f'https://api.godaddy.com/v1/domains/{domain}/records'

    patch_data = [{
        "data": ip_address,
        "type": 'A',
        "name": name,
        "ttl": ttl
    }]

    # Convert the dictionary to a JSON string
    json_data = json.dumps(patch_data)
    # Send the PATCH request
    response = requests.patch(url, data=json_data, headers=headers)

    # Check if the request was successful (status code 200 or 204 for success)
    if response.status_code in [200, 204]:
        print('PATCH request was successful')
    else:
        print(f'PATCH request failed with status code {response.status_code}')


def updateDomainRecord(host, ip_address="154.144.241.232", type='A', ttl=600):
    name = getRecordName(host)
    domain = getRecordDomain(host)

    headers = {
        'Content-Type': 'application/json',
        'Authorization': AUTHZ_HEADER,
    }

    url = f'https://api.godaddy.com/v1/domains/{domain}/records/{type}/{name}'

    put_data = [{
        "data": ip_address,
        "ttl": ttl
    }]

    # Convert the dictionary to a JSON string
    json_data = json.dumps(put_data)
    # Send the PATCH request
    response = requests.put(url, data=json_data, headers=headers)

    # Check if the request was successful (status code 200 or 204 for success)
    if response.status_code in [200, 204]:
        print('PUT request was successful')
        return True
    else:
        print(f'PUT request failed with status code {response.status_code}')
        return False


def deleteDomainRecord(name, type='A', domain="digieye.io"):
    headers = {
        'Authorization': AUTHZ_HEADER,
    }

    url = f'https://api.godaddy.com/v1/domains/{domain}/records/{type}/{name}'

    # Send the PATCH request
    response = requests.delete(url, headers=headers)

    # Check if the request was successful (status code 200 or 204 for success)
    if response.status_code in [200, 204]:
        print('DELETE request was successful')
    else:
        print(f'DELETE request failed with status code {response.status_code}')


