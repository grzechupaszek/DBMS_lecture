# Relations (Relational Schema)

Primary keys are underlined in the PK column; foreign keys are listed in the FK column.

| Relation | Attributes | PK | FK |
| --- | --- | --- | --- |
| `ProductionCompany` | `company_id`, `name`, `address` | `company_id` | — |
| `Movie` | `movie_id`, `title`, `year`, `length_min`, `company_id`, `plot_outline` | `movie_id` | `company_id → ProductionCompany` |
| `Genre` | `genre_id`, `name` | `genre_id` | — |
| `MovieGenre` | `movie_id`, `genre_id` | (`movie_id`, `genre_id`) | `movie_id → Movie`, `genre_id → Genre` |
| `Actor` | `actor_id`, `name`, `date_of_birth` | `actor_id` | — |
| `Director` | `director_id`, `name`, `date_of_birth` | `director_id` | — |
| `MovieActor` | `movie_id`, `actor_id`, `role` | (`movie_id`, `actor_id`, `role`) | `movie_id → Movie`, `actor_id → Actor` |
| `MovieDirector` | `movie_id`, `director_id` | (`movie_id`, `director_id`) | `movie_id → Movie`, `director_id → Director` |
| `Quote` | `quote_id`, `movie_id`, `actor_id`, `text` | `quote_id` | `movie_id → Movie`, `actor_id → Actor` |

## Entities vs. relationships
- **Strong entities:** `Movie`, `Actor`, `Director`, `ProductionCompany`, `Genre`.
- **Weak entity:** `Quote` — exists only as a line said by an actor inside a movie.
- **Associative tables (many-to-many):** `MovieGenre`, `MovieActor` (with `role` attribute), `MovieDirector`.

## Candidate keys (alternative to the surrogate IDs)
- `Movie`: `(title, year)`
- `Actor` / `Director`: `(name, date_of_birth)`
- `ProductionCompany`: `name`
- `Genre`: `name`

The schema uses integer surrogate keys for simplicity and faster joins.

## Notes on design choices
- `Actor` and `Director` are kept as **separate tables** because the brief describes them as two entities with separate roles. A person who both acts and directs appears in both tables with the same `(name, date_of_birth)` — this is exactly how the query *"movies whose actors are also directors"* is resolved.
- `MovieActor.role` is part of the primary key so the same actor can play several roles in one movie (supports advanced query X2).
