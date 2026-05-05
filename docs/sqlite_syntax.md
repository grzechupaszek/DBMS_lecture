# SQLite Syntax Reference

## SELECT

```sql
-- all rows
SELECT * FROM Movie;

-- specific columns
SELECT title, year FROM Movie;

-- with condition
SELECT * FROM Movie WHERE year > 2010;

-- sorted
SELECT * FROM Movie ORDER BY year DESC;

-- limited
SELECT * FROM Movie LIMIT 5;

-- join two tables
SELECT m.title, g.name
FROM Movie m
JOIN MovieGenre mg ON m.movie_id = mg.movie_id
JOIN Genre g ON mg.genre_id = g.genre_id;
```

## INSERT

```sql
INSERT INTO Movie (title, year, length_min) VALUES ('My Movie', 2024, 120);
```

## UPDATE

```sql
UPDATE Movie SET length_min = 148 WHERE title = 'Inception';
```

## DELETE

```sql
DELETE FROM Movie WHERE title = 'My Movie';
```

## Useful patterns

```sql
-- count rows
SELECT COUNT(*) FROM Movie;

-- find by partial name
SELECT * FROM Actor WHERE name LIKE '%Tom%';

-- check what's in a table fast
SELECT * FROM Genre;
```
