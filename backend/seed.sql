-- Sample data so every required query returns something meaningful.

-- Production companies -------------------------------------------------------
INSERT INTO ProductionCompany (name, address) VALUES
    ('Warner Bros.',        '4000 Warner Blvd, Burbank, CA'),
    ('Miramax',             '9100 Wilshire Blvd, Beverly Hills, CA'),
    ('Paramount Pictures',  '5555 Melrose Ave, Los Angeles, CA'),
    ('Orion Pictures',      '1888 Century Park East, Los Angeles, CA');

-- Genres ---------------------------------------------------------------------
INSERT INTO Genre (name) VALUES
    ('Action'), ('Drama'), ('Crime'), ('Thriller'),
    ('Sci-Fi'), ('Mystery'), ('Adventure'), ('Comedy'), ('Romance');

-- Actors ---------------------------------------------------------------------
INSERT INTO Actor (name, date_of_birth) VALUES
    ('Leonardo DiCaprio',   '1974-11-11'),
    ('Tom Hardy',           '1977-09-15'),
    ('Christian Bale',      '1974-01-30'),
    ('Heath Ledger',        '1979-04-04'),
    ('Aaron Eckhart',       '1968-03-12'),
    ('Matthew McConaughey', '1969-11-04'),
    ('Anne Hathaway',       '1982-11-12'),
    ('Timothée Chalamet',   '1995-12-27'),
    ('John Travolta',       '1954-02-18'),
    ('Samuel L. Jackson',   '1948-12-21'),
    ('Uma Thurman',         '1970-04-29'),
    ('Quentin Tarantino',   '1963-03-27'),
    ('Keanu Reeves',        '1964-09-02'),
    ('Laurence Fishburne',  '1961-07-30'),
    ('Tom Hanks',           '1956-07-09'),
    ('Dustin Hoffman',      '1937-08-08'),
    ('Tom Cruise',          '1962-07-03');

-- Directors ------------------------------------------------------------------
-- (Quentin Tarantino is duplicated on purpose: same person both acts AND directs)
INSERT INTO Director (name, date_of_birth) VALUES
    ('Christopher Nolan',   '1970-07-30'),
    ('Quentin Tarantino',   '1963-03-27'),
    ('Lana Wachowski',      '1965-06-21'),
    ('Lilly Wachowski',     '1967-12-29'),
    ('Tom Tykwer',          '1965-05-23'),
    ('Barry Levinson',      '1942-04-06');

-- Movies ---------------------------------------------------------------------
INSERT INTO Movie (title, year, length_min, company_id, plot_outline) VALUES
    ('Inception',          2010, 148,
        (SELECT company_id FROM ProductionCompany WHERE name='Warner Bros.'),
        'A thief who steals corporate secrets through dream-sharing technology.'),
    ('The Dark Knight',    2008, 152,
        (SELECT company_id FROM ProductionCompany WHERE name='Warner Bros.'),
        'Batman faces the Joker in Gotham City.'),
    ('Interstellar',       2014, 169,
        (SELECT company_id FROM ProductionCompany WHERE name='Paramount Pictures'),
        'A team of astronauts travels through a wormhole to save humanity.'),
    ('Pulp Fiction',       1994, 154,
        (SELECT company_id FROM ProductionCompany WHERE name='Miramax'),
        'Interwoven stories of crime in Los Angeles.'),
    ('Kill Bill: Vol. 1',  2003, 111,
        (SELECT company_id FROM ProductionCompany WHERE name='Miramax'),
        'A former assassin seeks revenge.'),
    ('Kill Bill: Vol. 2',  2004, 137,
        (SELECT company_id FROM ProductionCompany WHERE name='Miramax'),
        'The Bride continues her rampage of revenge.'),
    ('Reservoir Dogs',     1992,  99,
        (SELECT company_id FROM ProductionCompany WHERE name='Miramax'),
        'A diamond heist goes horribly wrong.'),
    ('The Matrix',         1999, 136,
        (SELECT company_id FROM ProductionCompany WHERE name='Warner Bros.'),
        'A hacker discovers reality is a simulation.'),
    ('Cloud Atlas',        2012, 172,
        (SELECT company_id FROM ProductionCompany WHERE name='Warner Bros.'),
        'Six stories across time echo through each other.'),
    ('Rain Man',           1988, 133,
        (SELECT company_id FROM ProductionCompany WHERE name='Orion Pictures'),
        'A selfish yuppie discovers he has an autistic savant brother.');

-- Movie <-> Genre ------------------------------------------------------------
INSERT INTO MovieGenre (movie_id, genre_id)
SELECT m.movie_id, g.genre_id FROM Movie m, Genre g WHERE
    (m.title='Inception'          AND g.name IN ('Action','Sci-Fi','Thriller')) OR
    (m.title='The Dark Knight'    AND g.name IN ('Action','Crime','Drama')) OR
    (m.title='Interstellar'       AND g.name IN ('Sci-Fi','Drama','Adventure')) OR
    (m.title='Pulp Fiction'       AND g.name IN ('Crime','Drama')) OR
    (m.title='Kill Bill: Vol. 1'  AND g.name IN ('Action','Crime','Thriller')) OR
    (m.title='Kill Bill: Vol. 2'  AND g.name IN ('Action','Crime','Drama','Thriller')) OR
    (m.title='Reservoir Dogs'     AND g.name IN ('Crime','Thriller')) OR
    (m.title='The Matrix'         AND g.name IN ('Action','Sci-Fi','Thriller','Adventure')) OR
    (m.title='Cloud Atlas'        AND g.name IN ('Sci-Fi','Drama','Mystery','Action')) OR
    (m.title='Rain Man'           AND g.name IN ('Drama'));

-- Movie <-> Director ---------------------------------------------------------
INSERT INTO MovieDirector (movie_id, director_id)
SELECT m.movie_id, d.director_id FROM Movie m, Director d WHERE
    (m.title='Inception'          AND d.name='Christopher Nolan') OR
    (m.title='The Dark Knight'    AND d.name='Christopher Nolan') OR
    (m.title='Interstellar'       AND d.name='Christopher Nolan') OR
    (m.title='Pulp Fiction'       AND d.name='Quentin Tarantino') OR
    (m.title='Kill Bill: Vol. 1'  AND d.name='Quentin Tarantino') OR
    (m.title='Kill Bill: Vol. 2'  AND d.name='Quentin Tarantino') OR
    (m.title='Reservoir Dogs'     AND d.name='Quentin Tarantino') OR
    (m.title='The Matrix'         AND d.name IN ('Lana Wachowski','Lilly Wachowski')) OR
    (m.title='Cloud Atlas'        AND d.name IN ('Lana Wachowski','Lilly Wachowski','Tom Tykwer')) OR
    (m.title='Rain Man'           AND d.name='Barry Levinson');

-- Movie <-> Actor (with role) ------------------------------------------------
INSERT INTO MovieActor (movie_id, actor_id, role)
SELECT m.movie_id, a.actor_id, r.role FROM Movie m, Actor a, (
    SELECT 'Inception'          AS title, 'Leonardo DiCaprio'   AS name, 'Cobb'           AS role UNION ALL
    SELECT 'Inception',              'Tom Hardy',               'Eames'                   UNION ALL
    SELECT 'The Dark Knight',        'Christian Bale',          'Bruce Wayne / Batman'    UNION ALL
    SELECT 'The Dark Knight',        'Heath Ledger',            'The Joker'               UNION ALL
    SELECT 'The Dark Knight',        'Aaron Eckhart',           'Harvey Dent'             UNION ALL
    SELECT 'Interstellar',           'Matthew McConaughey',     'Cooper'                  UNION ALL
    SELECT 'Interstellar',           'Anne Hathaway',           'Dr. Brand'               UNION ALL
    SELECT 'Interstellar',           'Timothée Chalamet',       'Tom (young)'             UNION ALL
    SELECT 'Pulp Fiction',           'John Travolta',           'Vincent Vega'            UNION ALL
    SELECT 'Pulp Fiction',           'Samuel L. Jackson',       'Jules Winnfield'         UNION ALL
    SELECT 'Pulp Fiction',           'Uma Thurman',             'Mia Wallace'             UNION ALL
    SELECT 'Pulp Fiction',           'Quentin Tarantino',       'Jimmie Dimmick'          UNION ALL
    SELECT 'Kill Bill: Vol. 1',      'Uma Thurman',             'The Bride'               UNION ALL
    SELECT 'Kill Bill: Vol. 2',      'Uma Thurman',             'The Bride'               UNION ALL
    SELECT 'Kill Bill: Vol. 2',      'Uma Thurman',             'Beatrix Kiddo'           UNION ALL   -- 2nd role, same movie
    SELECT 'Reservoir Dogs',         'Uma Thurman',             'Narrator'                UNION ALL
    SELECT 'Reservoir Dogs',         'Quentin Tarantino',       'Mr. Brown'               UNION ALL
    SELECT 'The Matrix',             'Keanu Reeves',            'Neo'                     UNION ALL
    SELECT 'The Matrix',             'Laurence Fishburne',      'Morpheus'                UNION ALL
    SELECT 'Cloud Atlas',            'Tom Hanks',               'Dr. Henry Goose'         UNION ALL
    SELECT 'Cloud Atlas',            'Tom Hanks',               'Isaac Sachs'             UNION ALL
    SELECT 'Cloud Atlas',            'Tom Hanks',               'Zachry'                  UNION ALL
    SELECT 'Rain Man',               'Dustin Hoffman',          'Raymond Babbitt'         UNION ALL
    SELECT 'Rain Man',               'Tom Cruise',              'Charlie Babbitt'
) r
WHERE m.title = r.title AND a.name = r.name;

-- Quotes ---------------------------------------------------------------------
INSERT INTO Quote (movie_id, actor_id, text)
SELECT m.movie_id, a.actor_id, q.text FROM Movie m, Actor a, (
    -- Heath Ledger has 5 quotes in The Dark Knight (satisfies query X3).
    SELECT 'The Dark Knight' AS title, 'Heath Ledger' AS name,
           'Why so serious?' AS text UNION ALL
    SELECT 'The Dark Knight', 'Heath Ledger',
           'Why don''t we just cut you into little pieces and feed you to your pooches?' UNION ALL
    SELECT 'The Dark Knight', 'Heath Ledger',
           'Introduce a little anarchy. Upset the established order.' UNION ALL
    SELECT 'The Dark Knight', 'Heath Ledger',
           'If you''re good at something, never do it for free.' UNION ALL
    SELECT 'The Dark Knight', 'Heath Ledger',
           'Whatever doesn''t kill you simply makes you... stranger.' UNION ALL
    SELECT 'The Dark Knight', 'Christian Bale',
           'I''m Batman.' UNION ALL
    SELECT 'The Dark Knight', 'Aaron Eckhart',
           'You either die a hero or you live long enough to see yourself become the villain.' UNION ALL
    SELECT 'Inception', 'Leonardo DiCaprio',
           'What is the most resilient parasite? An idea.' UNION ALL
    SELECT 'Inception', 'Tom Hardy',
           'You mustn''t be afraid to dream a little bigger, darling.' UNION ALL
    SELECT 'Pulp Fiction', 'Samuel L. Jackson',
           'Say ''what'' again. I dare you!' UNION ALL
    SELECT 'Pulp Fiction', 'John Travolta',
           'Royale with cheese.' UNION ALL
    SELECT 'The Matrix', 'Laurence Fishburne',
           'This is your last chance. After this, there is no turning back.' UNION ALL
    SELECT 'The Matrix', 'Keanu Reeves',
           'I know kung fu.' UNION ALL
    -- Pre-1990 quotes (will be removed by data-modification query M3).
    SELECT 'Rain Man', 'Dustin Hoffman',
           'I''m an excellent driver.' UNION ALL
    SELECT 'Rain Man', 'Dustin Hoffman',
           'Ten minutes to Wapner.'
) q
WHERE m.title = q.title AND a.name = q.name;
