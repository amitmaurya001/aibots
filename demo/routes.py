import os
from demo import app
from flask import send_from_directory, render_template, current_app


@app.route('/test', methods=['GET'])
def test():
    return render_template("test.html", waf_integration_url=current_app.config["WAF_INTEGRATION_URL"])


@app.route("/ping", methods=['GET'])
def ping():
    return "OK", 200

@app.route("/bot-protected/ping", methods=['GET'])
def protected_ping():
    return "OK (bot-protected)", 200

@app.route('/favicon.ico')
def favicon():
    return send_from_directory(
        os.path.join(app.root_path, 'static'),
        'favicon.ico', mimetype='image/vnd.microsoft.icon'
    )
