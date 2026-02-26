# origin-request Lambda@Edge
# Forward ONLY bot requests to a SECONDARY CF distribution (custom origin),
# prefixing the URI with the request TLD (com/de/...) and always ending in /index.html.

import re
import json

TARGET_CF_DOMAIN = "${target_cf_domain}"                     # e.g. dxxxxxxxxxxxx.cloudfront.net
ALLOWED_PREFIXES = json.loads('${allowed_prefixes_json}')    # e.g. ["com", "de"]
BOT_UA_RE        = re.compile(r"${bot_user_agent_pattern}", re.I)  # e.g. testbot|udemybot

def handler(event, context):
    req = event["Records"][0]["cf"]["request"]
    headers = req.get("headers", {})

    # Only route bots
    ua = (headers.get("user-agent", [{"value": ""}])[0]["value"] or "").lower()
    if not BOT_UA_RE.search(ua):
        return req

    # TLD → prefix; if not allowed, don't touch the request
    host = (headers.get("host", [{"value": ""}])[0]["value"] or "").lower()
    tld  = host.rsplit(".", 1)[-1] if "." in host else host
    if tld not in ALLOWED_PREFIXES:
        return req

    # Build: /{tld}{original_uri}/index.html (normalize slashes)
    uri = req.get("uri", "/")
    if not uri.startswith("/"):
        uri = "/" + uri
    if not uri.startswith(f"/{tld}/"):
        uri = f"/{tld}{uri}"
    if not uri.endswith("/"):
        uri += "/"
    uri += "index.html"

    # Switch origin to SECONDARY CF (custom) and set Host accordingly
    req["origin"] = {
        "custom": {
            "domainName": TARGET_CF_DOMAIN,
            "port": 443,
            "protocol": "https",
            "path": "",
            "sslProtocols": ["TLSv1.2"],
            "readTimeout": 5,
            "keepaliveTimeout": 5,
            "customHeaders": {}
        }
    }
    req["headers"]["host"] = [{ "key": "host", "value": TARGET_CF_DOMAIN }]
    req["uri"] = uri

    # Optional breadcrumb for debugging in POP region logs:
    # print(f"edge: bot -> {TARGET_CF_DOMAIN} tld={tld} uri={uri}")

    return req
