# Software Requirements Specification — MOVIE Database

## 1. Introduction

### 1.1 Purpose
A minimal web application that stores data about the movie industry and exposes a set of predefined SQL queries (basic, aggregate, join, nested, advanced) and data-modification operations through a simple browser UI.

### 1.2 Scope
- Store data about movies, actors, directors, production companies, genres, and quotes.
- Execute a fixed catalogue of queries over the data.
- Allow three data-modification operations: insert a new genre, update a production company address, delete quotes from old movies.

### 1.3 Definitions
- **Movie** — a film, identified by `(title, year)`.
- **Actor / Director** — a person, identified by `(name, date_of_birth)`.
- **Production Company** — the company that produces a movie.
- **Genre** — classification of a movie (e.g. Drama, Action).
- **Quote** — a quotable line spoken by an actor in a movie.

## 2. Overall Description

### 2.1 Product Perspective
Single-machine demo: SQLite file + Python Flask backend + one static HTML page.

### 2.2 User Classes
One user (the instructor/student). No authentication required.

### 2.3 Operating Environment
Python 3.8+, a modern browser. No external services.

### 2.4 Constraints
- Keep the implementation minimal — one `app.py`, one schema file, one seed file.
- Use SQLite (file-based, zero-config).

## 3. Functional Requirements

### 3.1 Data Management
- FR-1: The system shall persist movies, actors, directors, production companies, genres, movie–genre links, movie–actor links (with role), movie–director links, and quotes.

### 3.2 Queries (exposed in the UI as named buttons)

**Basic**
- FR-B1: Movies released after 2000.
- FR-B2: Genres of the movie "Inception".
- FR-B3: Number of movies per production company.
- FR-B4: Actors born after 1980.

**Aggregate**
- FR-A1: Average movie length per genre.
- FR-A2: Genre with the largest number of movies.
- FR-A3: Top 5 actors by number of movies.

**Join**
- FR-J1: All movies with their director names.
- FR-J2: Quotes from "The Dark Knight" with the speaking actor.
- FR-J3: Production company and address for movies directed by "Christopher Nolan".

**Nested**
- FR-N1: Movies whose actors also directed some movie.
- FR-N2: Actors who appeared in every movie directed by "Quentin Tarantino".
- FR-N3: Movies with more than 3 genres.

**Advanced**
- FR-X1: Movies with at least two directors.
- FR-X2: Actors who played more than one role in the same movie.
- FR-X3: Movies where the same actor spoke more than 3 quotes.

### 3.3 Data Modification
- FR-M1: Add a new genre "Sci-Fi".
- FR-M2: Update the address of "Warner Bros.".
- FR-M3: Delete every quote of movies released before 1990.

## 4. Non-Functional Requirements
- NFR-1 (Simplicity): The whole backend fits in a single Flask file.
- NFR-2 (Portability): Runs on any OS with Python; database is a single `.db` file.
- NFR-3 (Reproducibility): First start auto-creates the schema and loads seed data.
