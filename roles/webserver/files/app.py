from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def index():
    return "Hello World from the webserver!"

@app.route("/secret")
def secret():
    db_user = os.getenv("DB_USER", "not set")
    db_password = os.getenv("DB_PASSWORD", "not set")
    return f"DB_USER: {db_user}, DB_PASSWORD: {db_password}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)