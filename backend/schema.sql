PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS ProductionCompany (
    company_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT NOT NULL UNIQUE,
    address    TEXT
);

CREATE TABLE IF NOT EXISTS Movie (
    movie_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    title        TEXT    NOT NULL,
    year         INTEGER NOT NULL,
    length_min   INTEGER,
    company_id   INTEGER,
    plot_outline TEXT,
    UNIQUE (title, year),
    FOREIGN KEY (company_id) REFERENCES ProductionCompany(company_id)
);

CREATE TABLE IF NOT EXISTS Genre (
    genre_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name     TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS MovieGenre (
    movie_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES Movie(movie_id)   ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)   ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Actor (
    actor_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT NOT NULL,
    date_of_birth DATE,
    UNIQUE (name, date_of_birth)
);

CREATE TABLE IF NOT EXISTS Director (
    director_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT NOT NULL,
    date_of_birth DATE,
    UNIQUE (name, date_of_birth)
);

CREATE TABLE IF NOT EXISTS MovieActor (
    movie_id INTEGER NOT NULL,
    actor_id INTEGER NOT NULL,
    role     TEXT    NOT NULL,
    PRIMARY KEY (movie_id, actor_id, role),
    FOREIGN KEY (movie_id) REFERENCES Movie(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES Actor(actor_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS MovieDirector (
    movie_id    INTEGER NOT NULL,
    director_id INTEGER NOT NULL,
    PRIMARY KEY (movie_id, director_id),
    FOREIGN KEY (movie_id)    REFERENCES Movie(movie_id)       ON DELETE CASCADE,
    FOREIGN KEY (director_id) REFERENCES Director(director_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Quote (
    quote_id INTEGER PRIMARY KEY AUTOINCREMENT,
    movie_id INTEGER NOT NULL,
    actor_id INTEGER NOT NULL,
    text     TEXT    NOT NULL,
    FOREIGN KEY (movie_id) REFERENCES Movie(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES Actor(actor_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS User (
    user_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    role     TEXT NOT NULL DEFAULT 'user'
);
