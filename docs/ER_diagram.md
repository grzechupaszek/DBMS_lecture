# ER Diagram

Rendered with Mermaid (GitHub/VS Code preview will draw it automatically).

```mermaid
erDiagram
    PRODUCTION_COMPANY ||--o{ MOVIE : produces
    MOVIE ||--o{ MOVIE_GENRE : classified_as
    GENRE ||--o{ MOVIE_GENRE : classifies
    MOVIE ||--o{ MOVIE_ACTOR : features
    ACTOR ||--o{ MOVIE_ACTOR : plays_in
    MOVIE ||--o{ MOVIE_DIRECTOR : directed_by_link
    DIRECTOR ||--o{ MOVIE_DIRECTOR : directs_link
    MOVIE ||--o{ QUOTE : has
    ACTOR ||--o{ QUOTE : speaks

    PRODUCTION_COMPANY {
        int company_id PK
        string name
        string address
    }
    MOVIE {
        int movie_id PK
        string title
        int year
        int length_min
        int company_id FK
        string plot_outline
    }
    GENRE {
        int genre_id PK
        string name
    }
    MOVIE_GENRE {
        int movie_id FK
        int genre_id FK
    }
    ACTOR {
        int actor_id PK
        string name
        date date_of_birth
    }
    DIRECTOR {
        int director_id PK
        string name
        date date_of_birth
    }
    MOVIE_ACTOR {
        int movie_id FK
        int actor_id FK
        string role
    }
    MOVIE_DIRECTOR {
        int movie_id FK
        int director_id FK
    }
    QUOTE {
        int quote_id PK
        int movie_id FK
        int actor_id FK
        string text
    }
```

## Cardinality notes
- **Movie — ProductionCompany:** many-to-one (each movie has exactly one production company; one company has many movies).
- **Movie — Genre:** many-to-many (`MOVIE_GENRE`).
- **Movie — Actor:** many-to-many with attribute `role` (`MOVIE_ACTOR`). An actor can have several roles in the same movie — the PK is `(movie_id, actor_id, role)`.
- **Movie — Director:** many-to-many (`MOVIE_DIRECTOR`). A director may also appear in `MOVIE_ACTOR` for the same movie (directors can act).
- **Quote — Movie/Actor:** each quote belongs to one movie and is spoken by one actor who appears in that movie.
