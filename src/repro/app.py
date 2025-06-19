import atexit
import contextlib

import flask
import sqlanydb

app = flask.Flask(__name__)


@app.get("/")
def harmless():
    return "hi"

@app.get("/break-it")
def break_it():
    with contextlib.suppress(sqlanydb.OperationalError):
        sqlanydb.connect()

    return "graceful shutdown is broken now"

def say_bye():
    print("atexit called")

atexit.register(say_bye)
