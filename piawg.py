import requests
import json
from requests_toolbelt.adapters import host_header_ssl
import ssl
import subprocess
import urllib.parse

# PIA issues its own certificates, so requests below are verified against this
# CA rather than the system trust store.
PIA_CA = 'ca.rsa.4096.crt'


def pia_ssl_context():
    """Build the SSL context used to talk to PIA endpoints.

    PIA's root CA was issued in 2014 with a basicConstraints extension that is
    not marked critical, which RFC 5280 requires of a CA certificate. Python
    3.13 began enabling ssl.VERIFY_X509_STRICT on default contexts, and that
    check rejects the certificate outright. Clear only that one flag: the
    signature chain, the validity dates and the hostname are all still
    verified, and passing cafile keeps trust pinned to PIA_CA alone rather
    than widening it to the system CAs.
    """
    context = ssl.create_default_context(cafile=PIA_CA)
    context.verify_flags &= ~ssl.VERIFY_X509_STRICT
    # create_default_context() already refuses TLS below 1.2. State the floor so
    # that it stays a property of this context and not of the Python defaults.
    context.minimum_version = ssl.TLSVersion.TLSv1_2
    return context


class PIAHostHeaderSSLAdapter(host_header_ssl.HostHeaderSSLAdapter):
    """HostHeaderSSLAdapter that verifies using pia_ssl_context().

    PIA publishes IP addresses rather than hostnames, so the adapter matches
    the certificate against the Host header instead of the URL.
    """

    def init_poolmanager(self, *args, **kwargs):
        kwargs['ssl_context'] = pia_ssl_context()
        return super().init_poolmanager(*args, **kwargs)


class piawg:
    def __init__(self):
        self.server_list = {}
        self.get_server_list()
        self.region = None
        self.token = None
        self.publickey = None
        self.privatekey = None
        self.connection = None

    def get_server_list(self):
        r = requests.get('https://serverlist.piaservers.net/vpninfo/servers/v4')
        # Only process first line of response, there's some base64 data at the end we're ignoring
        data = json.loads(r.text.splitlines()[0])
        for server in data['regions']:
            self.server_list[server['name']] = server

    def set_region(self, region_name):
        self.region = region_name

    def get_token(self, username, password):
        # Get common name and IP address for metadata endpoint in region
        meta_cn = self.server_list[self.region]['servers']['meta'][0]['cn']
        meta_ip = self.server_list[self.region]['servers']['meta'][0]['ip']

        # Some tricks to verify PIA certificate, even though we're sending requests to an IP and not a proper domain
        # https://toolbelt.readthedocs.io/en/latest/adapters.html#requests_toolbelt.adapters.host_header_ssl.HostHeaderSSLAdapter
        s = requests.Session()
        s.mount('https://', PIAHostHeaderSSLAdapter())
        s.verify = PIA_CA

        r = s.get("https://{}/authv3/generateToken".format(meta_ip), headers={"Host": meta_cn},
                  auth=(username, password))
        try:
            data = r.json()
        except ValueError:
            # A rejected login, or a meta host having a bad day, answers with an
            # empty or non-JSON body. Report that as a failed login rather than
            # letting a JSONDecodeError escape: generate-config.py treats False
            # as "ask for the credentials again".
            return False
        if r.status_code == 200 and data.get('status') == 'OK':
            self.token = data['token']
            return True
        else:
            return False

    def generate_keys(self):
        # check=True: a failing wg returns an empty string on stdout, which would
        # otherwise become an empty PrivateKey in the generated configuration.
        self.privatekey = subprocess.run(['wg', 'genkey'], stdout=subprocess.PIPE, encoding="utf-8",
                                         check=True).stdout.strip()
        self.publickey = subprocess.run(['wg', 'pubkey'], input=self.privatekey, stdout=subprocess.PIPE,
                                        encoding="utf-8", check=True).stdout.strip()

    def addkey(self):
        # Get common name and IP address for wireguard endpoint in region
        cn = self.server_list[self.region]['servers']['wg'][0]['cn']
        ip = self.server_list[self.region]['servers']['wg'][0]['ip']

        s = requests.Session()
        s.mount('https://', PIAHostHeaderSSLAdapter())
        s.verify = PIA_CA

        r = s.get("https://{}:1337/addKey?pt={}&pubkey={}".format(ip, urllib.parse.quote(self.token),
                                                                  urllib.parse.quote(self.publickey)), headers={"Host": cn})
        if r.status_code == 200 and r.json()['status'] == 'OK':
            self.connection = r.json()
            return True, r.content
        else:
            return False, r.content
