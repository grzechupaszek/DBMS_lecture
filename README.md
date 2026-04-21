# MOVIE Database — DBMS lecture demo

Minimal end-to-end example of a tiny database application:

- **Design docs** in [docs/](docs/)
  - [SRS](docs/SRS.md) — requirements
  - [ER diagram](docs/ER_diagram.md) — entities + relationships (Mermaid)
  - [Relations](docs/relations.md) — relational schema + entity/weak-entity notes
- **Database** — SQLite, schema in [backend/schema.sql](backend/schema.sql), seed data in [backend/seed.sql](backend/seed.sql)
- **Backend** — Flask, one file: [backend/app.py](backend/app.py)
- **Frontend** — one static HTML page + vanilla JS in [frontend/](frontend/)

## Project structure

```
DBMS_lecture/
├── docs/
│   ├── SRS.md
│   ├── ER_diagram.md
│   └── relations.md
├── backend/
│   ├── app.py          # Flask app
│   ├── schema.sql      # CREATE TABLE statements
│   └── seed.sql        # sample data
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── requirements.txt
└── README.md
```

## Run

```bash
python -m venv .venv
source .venv/bin/activate       # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python backend/app.py
```

Open <http://127.0.0.1:5000/>.

On the very first start the backend creates `backend/movies.db` and loads the seed data. Use the **Reset database** button in the UI (or `POST /api/reset`) to drop it and reload.

## What the UI does

The left column lists every required query from the assignment, grouped by category (Basic / Aggregate / Join / Nested / Advanced / Modifications). Clicking a query runs it on the server and shows:

- the actual SQL that was executed,
- the rows returned (for SELECTs) or rows affected (for modifications).

## Query catalogue

| ID  | Type        | Description |
| --- | ----------- | ----------- |
| B1  | Basic       | Movies released after 2000 |
| B2  | Basic       | Genres of the movie "Inception" |
| B3  | Basic       | Number of movies per production company |
| B4  | Basic       | Actors born after 1980 |
| A1  | Aggregate   | Average movie length per genre |
| A2  | Aggregate   | Genre with the highest number of movies |
| A3  | Aggregate   | Top 5 actors by number of movies |
| J1  | Join        | All movies with their directors |
| J2  | Join        | Quotes from "The Dark Knight" with actors |
| J3  | Join        | Company + address of Christopher Nolan's films |
| N1  | Nested      | Movies whose actors are also directors |
| N2  | Nested      | Actors appearing in every Tarantino movie |
| N3  | Nested      | Movies belonging to more than 3 genres |
| X1  | Advanced    | Movies with at least two directors |
| X2  | Advanced    | Actors playing more than one role in the same movie |
| X3  | Advanced    | Movies where the same actor spoke more than 3 quotes |
| M1  | Modify      | Add new genre "Sci-Fi" |
| M2  | Modify      | Update "Warner Bros." address |
| M3  | Modify      | Delete quotes of pre-1990 movies |
