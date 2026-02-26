import os
from flask import Flask
from flask_restful import Api


app = Flask(__name__, static_folder="static", template_folder="templates")
demo = Api(app)

app.config["WAF_INTEGRATION_URL"] = os.environ.get(
    "WAF_INTEGRATION_URL",
    "https://11d6b0301dc2.edge.sdk.awswaf.com/11d6b0301dc2/7b1208feb5e3/"
)

if __name__ == '__main__':
    app.run(debug=True)

from demo import routes # noqa
