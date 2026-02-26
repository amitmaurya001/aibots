function handler(event) {
  try {
    var req = event.request || {};
    if (!req.headers) req.headers = {};

    var ua = '';
    var uaHeader = req.headers['user-agent'];
    if (uaHeader && typeof uaHeader.value === 'string') {
      ua = uaHeader.value.toLowerCase();
    }

    var pattern = "${bot_user_agent_pattern}";
    var re = new RegExp(pattern, "i");
    var isBot = re.test(ua) ? "1" : "0";

    // header shape for CF Functions
    req.headers['x-bot'] = { value: isBot };

    // plain concatenation so you can see the values
    // console.log("tag-bot ua='" + ua + "' isBot=" + isBot + " uri=" + (req.uri || "/"));

    return req;
  } catch (e) {
    try { console.log("tag-bot ERROR: " + (e && e.message ? e.message : String(e))); } catch (_e) {}
    return event.request || {};
  }
}
