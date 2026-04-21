"""Minimal Flask + SQLite backend for the MOVIE database demo.

Run:
    python backend/app.py
The server auto-creates the SQLite file and loads the seed data on first run.
Open http://127.0.0.1:5000/ in a browser.
"""
from __future__ import annotations

import os
import sqlite3
from flask import Flask, jsonify, request, send_from_directory

BASE_DIR     = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR     = os.path.dirname(BASE_DIR)
FRONTEND_DIR = os.path.join(ROOT_DIR, "frontend")
DB_PATH      = os.path.join(BASE_DIR, "movies.db")
SCHEMA_PATH  = os.path.join(BASE_DIR, "schema.sql")
SEED_PATH    = os.path.join(BASE_DIR, "seed.sql")


# --------------------------------------------------------------------------- #
# DB helpers
# --------------------------------------------------------------------------- #
def get_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db() -> None:
    """Create schema and load seed data if DB file does not yet exist."""
    fresh = not os.path.exists(DB_PATH)
    conn = get_conn()
    try:
        with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
            conn.executescript(f.read())
        if fresh:
            with open(SEED_PATH, "r", encoding="utf-8") as f:
                conn.executescript(f.read())
        conn.commit()
    finally:
        conn.close()


def run_select(sql: str, params: tuple = ()) -> list[dict]:
    conn = get_conn()
    try:
        rows = conn.execute(sql, params).fetchall()
        return [dict(r) for r in rows]
    finally:
        conn.close()


def run_write(sql: str, params: tuple = ()) -> int:
    conn = get_conn()
    try:
        cur = conn.execute(sql, params)
        conn.commit()
        return cur.rowcount
    finally:
        conn.close()


# --------------------------------------------------------------------------- #
# Query catalogue
# --------------------------------------------------------------------------- #
# Each entry: id -> (human title, SQL).  Frontend builds buttons from /api/queries.
QUERIES: dict[str, tuple[str, str]] = {
    # ---- 1. Basic ----------------------------------------------------------
    "B1": ("Movies released after 2000", """
        SELECT title, year, length_min
        FROM Movie
        WHERE year > 2000
        ORDER BY year, title
    """),
    "B2": ("Genres of 'Inception'", """
        SELECT g.name AS genre
        FROM Genre g
        JOIN MovieGenre mg ON mg.genre_id = g.genre_id
        JOIN Movie     m  ON m.movie_id  = mg.movie_id
        WHERE m.title = 'Inception'
        ORDER BY g.name
    """),
    "B3": ("Movies produced per production company", """
        SELECT pc.name AS company, COUNT(m.movie_id) AS movie_count
        FROM ProductionCompany pc
        LEFT JOIN Movie m ON m.company_id = pc.company_id
        GROUP BY pc.company_id, pc.name
        ORDER BY movie_count DESC, pc.name
    """),
    "B4": ("Actors born after 1980", """
        SELECT name, date_of_birth
        FROM Actor
        WHERE date_of_birth > '1980-12-31'
        ORDER BY date_of_birth
    """),

    # ---- 2. Aggregate ------------------------------------------------------
    "A1": ("Average movie length per genre", """
        SELECT g.name AS genre,
               ROUND(AVG(m.length_min), 1) AS avg_length_min,
               COUNT(*) AS movies
        FROM Genre g
        JOIN MovieGenre mg ON mg.genre_id = g.genre_id
        JOIN Movie m       ON m.movie_id  = mg.movie_id
        GROUP BY g.genre_id, g.name
        ORDER BY avg_length_min DESC
    """),
    "A2": ("Genre with the highest number of movies", """
        SELECT g.name AS genre, COUNT(*) AS movies
        FROM Genre g
        JOIN MovieGenre mg ON mg.genre_id = g.genre_id
        GROUP BY g.genre_id, g.name
        HAVING COUNT(*) = (
            SELECT MAX(c) FROM (
                SELECT COUNT(*) AS c
                FROM MovieGenre
                GROUP BY genre_id
            )
        )
    """),
    "A3": ("Top 5 actors by number of movies", """
        SELECT a.name, COUNT(DISTINCT ma.movie_id) AS movies
        FROM Actor a
        JOIN MovieActor ma ON ma.actor_id = a.actor_id
        GROUP BY a.actor_id, a.name
        ORDER BY movies DESC, a.name
        LIMIT 5
    """),

    # ---- 3. Join -----------------------------------------------------------
    "J1": ("All movies with their directors", """
        SELECT m.title, m.year, d.name AS director
        FROM Movie m
        JOIN MovieDirector md ON md.movie_id    = m.movie_id
        JOIN Director d       ON d.director_id  = md.director_id
        ORDER BY m.year, m.title, d.name
    """),
    "J2": ("Quotes from 'The Dark Knight' with actors", """
        SELECT a.name AS actor, q.text AS quote
        FROM Quote q
        JOIN Movie m ON m.movie_id = q.movie_id
        JOIN Actor a ON a.actor_id = q.actor_id
        WHERE m.title = 'The Dark Knight'
        ORDER BY a.name
    """),
    "J3": ("Production company + address for Christopher Nolan films", """
        SELECT m.title, m.year, pc.name AS company, pc.address
        FROM Movie m
        JOIN ProductionCompany pc ON pc.company_id   = m.company_id
        JOIN MovieDirector md     ON md.movie_id     = m.movie_id
        JOIN Director d           ON d.director_id   = md.director_id
        WHERE d.name = 'Christopher Nolan'
        ORDER BY m.year
    """),

    # ---- 4. Nested ---------------------------------------------------------
    "N1": ("Movies whose actors are also directors", """
        SELECT DISTINCT m.title, m.year, a.name AS actor_also_director
        FROM Movie m
        JOIN MovieActor ma ON ma.movie_id = m.movie_id
        JOIN Actor a       ON a.actor_id  = ma.actor_id
        WHERE (a.name, a.date_of_birth) IN (
            SELECT name, date_of_birth FROM Director
        )
        ORDER BY m.year, m.title
    """),
    "N2": ("Actors appearing in ALL Tarantino-directed movies", """
        SELECT a.name
        FROM Actor a
        WHERE NOT EXISTS (
            SELECT 1
            FROM Movie m
            JOIN MovieDirector md ON md.movie_id    = m.movie_id
            JOIN Director d       ON d.director_id  = md.director_id
            WHERE d.name = 'Quentin Tarantino'
              AND NOT EXISTS (
                    SELECT 1 FROM MovieActor ma
                    WHERE ma.movie_id = m.movie_id
                      AND ma.actor_id = a.actor_id
              )
        )
        AND EXISTS (
            SELECT 1 FROM MovieDirector md
            JOIN Director d ON d.director_id = md.director_id
            WHERE d.name = 'Quentin Tarantino'
        )
    """),
    "N3": ("Movies belonging to more than 3 genres", """
        SELECT m.title, m.year,
               (SELECT COUNT(*) FROM MovieGenre mg WHERE mg.movie_id = m.movie_id) AS genres
        FROM Movie m
        WHERE (SELECT COUNT(*) FROM MovieGenre mg WHERE mg.movie_id = m.movie_id) > 3
        ORDER BY genres DESC, m.title
    """),

    # ---- 5. Advanced -------------------------------------------------------
    "X1": ("Movies with at least two directors", """
        SELECT m.title, m.year, COUNT(md.director_id) AS directors
        FROM Movie m
        JOIN MovieDirector md ON md.movie_id = m.movie_id
        GROUP BY m.movie_id, m.title, m.year
        HAVING COUNT(md.director_id) >= 2
        ORDER BY directors DESC, m.title
    """),
    "X2": ("Actors who played more than one role in the same movie", """
        SELECT a.name AS actor, m.title, COUNT(*) AS roles
        FROM MovieActor ma
        JOIN Actor a ON a.actor_id = ma.actor_id
        JOIN Movie m ON m.movie_id = ma.movie_id
        GROUP BY ma.movie_id, ma.actor_id
        HAVING COUNT(*) > 1
        ORDER BY roles DESC, a.name
    """),
    "X3": ("Movies where the same actor spoke more than 3 quotes", """
        SELECT m.title, a.name AS actor, COUNT(*) AS quote_count
        FROM Quote q
        JOIN Movie m ON m.movie_id = q.movie_id
        JOIN Actor a ON a.actor_id = q.actor_id
        GROUP BY q.movie_id, q.actor_id
        HAVING COUNT(*) > 3
        ORDER BY quote_count DESC
    """),
}

# Data modifications — each is a (title, sql, params) triple.
MODIFICATIONS: dict[str, tuple[str, str, tuple]] = {
    "M1": ("Add new genre 'Sci-Fi'",
           "INSERT OR IGNORE INTO Genre (name) VALUES (?)",
           ("Sci-Fi",)),
    "M2": ("Update address of 'Warner Bros.'",
           "UPDATE ProductionCompany SET address = ? WHERE name = ?",
           ("3400 Riverside Dr, Burbank, CA 91505", "Warner Bros.")),
    "M3": ("Delete quotes from movies released before 1990",
           "DELETE FROM Quote WHERE movie_id IN (SELECT movie_id FROM Movie WHERE year < 1990)",
           ()),
}


# --------------------------------------------------------------------------- #
# HTTP routes
# --------------------------------------------------------------------------- #
app = Flask(__name__, static_folder=None)


@app.route("/")
def index():
    return send_from_directory(FRONTEND_DIR, "index.html")


@app.route("/<path:path>")
def static_files(path: str):
    return send_from_directory(FRONTEND_DIR, path)


@app.route("/api/queries")
def list_queries():
    categories = {
        "1. Basic":         ["B1", "B2", "B3", "B4"],
        "2. Aggregate":     ["A1", "A2", "A3"],
        "3. Join":          ["J1", "J2", "J3"],
        "4. Nested":        ["N1", "N2", "N3"],
        "5. Advanced":      ["X1", "X2", "X3"],
        "6. Modifications": ["M1", "M2", "M3"],
    }
    payload = {}
    for cat, ids in categories.items():
        payload[cat] = [
            {"id": qid,
             "title": (QUERIES[qid][0] if qid in QUERIES else MODIFICATIONS[qid][0]),
             "kind":  ("select" if qid in QUERIES else "modify")}
            for qid in ids
        ]
    return jsonify(payload)


@app.route("/api/query/<qid>")
def run_query(qid: str):
    if qid not in QUERIES:
        return jsonify({"error": f"unknown query id {qid}"}), 404
    title, sql = QUERIES[qid]
    try:
        rows = run_select(sql)
    except sqlite3.Error as e:
        return jsonify({"error": str(e), "sql": sql}), 400
    columns = list(rows[0].keys()) if rows else []
    return jsonify({"id": qid, "title": title, "sql": sql.strip(),
                    "columns": columns, "rows": rows})


@app.route("/api/modify/<mid>", methods=["POST"])
def run_modification(mid: str):
    if mid not in MODIFICATIONS:
        return jsonify({"error": f"unknown modification id {mid}"}), 404
    title, sql, params = MODIFICATIONS[mid]
    try:
        affected = run_write(sql, params)
    except sqlite3.Error as e:
        return jsonify({"error": str(e), "sql": sql}), 400
    return jsonify({"id": mid, "title": title, "sql": sql.strip(),
                    "params": list(params), "rows_affected": affected})


@app.route("/api/reset", methods=["POST"])
def reset_db():
    """Drop the DB file and recreate + reseed it (handy after running M1-M3)."""
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
    init_db()
    return jsonify({"status": "reset", "db": os.path.basename(DB_PATH)})


if __name__ == "__main__":
    init_db()
    app.run(host="127.0.0.1", port=5000, debug=True)
