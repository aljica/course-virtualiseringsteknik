from flask import Flask
import os
import psycopg2

app = Flask(__name__)

def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        port=os.getenv("DB_PORT")
    )

@app.route("/")
def index():
    return "Hello World from the webserver!"

@app.route("/secret")
def secret():
    db_user = os.getenv("DB_USER", "not set")
    db_password = os.getenv("DB_PASSWORD", "not set")
    db_name = os.getenv("DB_NAME", "not set")
    db_host = os.getenv("DB_HOST", "not set")
    db_port = os.getenv("DB_PORT", "not set")
    return f"DB_USER: {db_user}, DB_PASSWORD: {db_password}, DB_NAME: {db_name}, DB_HOST: {db_host}, DB_PORT: {db_port}"

@app.route("/visit")
def visit():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("INSERT INTO visits (served_by) VALUES (%s)", ("Server 1",))
    conn.commit()
    cur.execute("SELECT id, timestamp, served_by FROM visits ORDER BY timestamp DESC LIMIT 5")
    rows = cur.fetchall()
    cur.close()
    conn.close()

    response = "Server 2 is serving this request.\n\nLast 5 visits:\n"
    for row in rows:
        response += f"  [{row[1]}] {row[2]}\n"
    return response

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)