# Superstars Table
-- Create Empty Tables on SQL 
CREATE TABLE superstars (
    MatchIndex INTEGER,
    superstar_name VARCHAR
);

-- Insert CSV into empty table
COPY superstars FROM '/Users/marietolteca/Documents/MEDS/WWE-database/output/superstars.csv'
( FORMAT CSV, HEADER true );

-- Verify the schema
DESCRIBE superstars;

# Events Table
-- Create Table by reading in CSV
CREATE TABLE events AS
SELECT * FROM read_csv_auto('/Users/marietolteca/Documents/MEDS/WWE-database/output/events.csv');

-- Verify the schema
DESCRIBE events;

# Match Rating Table
-- Create empty table
DROP TABLE match_rating;

CREATE TABLE match_rating (
    Index INTEGER,
    Date DATE,
    Promotion VARCHAR,
    Match VARCHAR,
    CageMatchRating FLOAT,
    CageMatchRatingVotes INTEGER,
    WONStarRating VARCHAR,
    "Opponent.1" VARCHAR,
    "Opponent.2" VARCHAR
);

-- Read in CSV
COPY match_rating FROM '/Users/marietolteca/Documents/MEDS/WWE-database/output/match_rating.csv'
( FORMAT CSV, HEADER true, NULLSTR 'NA' );

# Teams Table
-- Create empty table
CREATE TABLE teams (
    MatchIndex INTEGER,
    Team VARCHAR
);

-- Read in CSV
COPY teams FROM '/Users/marietolteca/Documents/MEDS/WWE-database/output/teams.csv'
( FORMAT CSV, HEADER true );


----------
# Lets try some simple queries to get more information

SELECT * FROM events;

SELECT COUNT(DISTINCT EventType) FROM events;

SELECT DISTINCT Promotion FROM events;
SELECT DISTINCT Promotion FROM match_rating;

SELECT DISTINCT WONStarRating FROM match_rating;

SELECT DISTINCT EventType FROM events;
SELECT DISTINCT CageMatchRatingVotes FROM match_rating;

--- What is the Most viewed Event and How is it seen
SELECT EventType, Event, TotalVotes
FROM (
    SELECT 
        e.EventType,
        e.Event,
        SUM(m.CageMatchRatingVotes) AS TotalVotes,
        -- Rank events within each EventType by total votes
        ROW_NUMBER() OVER (PARTITION BY e.EventType ORDER BY SUM(m.CageMatchRatingVotes) DESC) AS rn
    FROM events e
    JOIN match_rating m ON e.Date = m.Date AND e.Promotion = m.Promotion
    GROUP BY e.EventType, e.Event
)
-- Keep one row
WHERE rn = 1
ORDER BY TotalVotes DESC;



-- For all the years, how are people watching this and what is the average views
SELECT 
    YEAR(m.Date) AS Year,
    e.EventType,
    SUM(m.CageMatchRatingVotes) AS TotalVotes
FROM match_rating m
JOIN events e ON e.Date = m.Date AND e.Promotion = m.Promotion
GROUP BY Year, e.EventType
ORDER BY Year ASC, TotalVotes DESC;

-- By year, most viewed event
SELECT Year, Event, TotalVotes
FROM (
    SELECT 
        YEAR(m.Date) AS Year,
        e.Event,
        SUM(m.CageMatchRatingVotes) AS TotalVotes,
        ROW_NUMBER() OVER (PARTITION BY YEAR(m.Date) ORDER BY SUM(m.CageMatchRatingVotes) DESC) AS rn
    FROM match_rating m
    JOIN events e ON e.Date = m.Date AND e.Promotion = m.Promotion
    GROUP BY Year, e.Event
)
WHERE rn <= 3
ORDER BY Year ASC, TotalVotes DESC;

-- Which superstar is the most viewed and how are they being viewed
SELECT 
    s.superstar_name,
    e.EventType,
    SUM(m.CageMatchRatingVotes) AS TotalVotes
FROM superstars s
JOIN match_rating m ON s.MatchIndex = m.Index
JOIN events e ON e.Date = m.Date AND e.Promotion = m.Promotion
GROUP BY s.superstar_name, e.EventType
ORDER BY TotalVotes DESC
LIMIT 20;

-- Top 5 Most viewed superstar
SELECT 
    s.superstar_name,
    SUM(m.CageMatchRatingVotes) AS TotalVotes
FROM superstars s
JOIN match_rating m ON s.MatchIndex = m.Index
JOIN events e ON e.Date = m.Date AND e.Promotion = m.Promotion
GROUP BY s.superstar_name
ORDER BY TotalVotes DESC
LIMIT 5;

-- Most viewed superstars at WrestleMania by year
SELECT 
    s.superstar_name,
    e.EventType,
    YEAR(m.Date) AS Year,
    SUM(m.CageMatchRatingVotes) AS TotalVotes
FROM superstars s
JOIN match_rating m ON s.MatchIndex = m.Index
JOIN events e ON e.Date = m.Date AND e.Promotion = m.Promotion
GROUP BY s.superstar_name, e.EventType, Year
ORDER BY TotalVotes DESC
LIMIT 5;

-- Tag Team Most Viewed
SELECT 
    t.Team,
    SUM(m.CageMatchRatingVotes) AS TotalVotes
FROM teams t
JOIN match_rating m ON t.MatchIndex = m.Index
GROUP BY t.Team
ORDER BY TotalVotes DESC
LIMIT 5;

--Most viewed superstar and top average views by years
SELECT 
    s.superstar_name,
    YEAR(m.Date) AS Year,
    SUM(m.CageMatchRatingVotes) AS TotalVotes
FROM superstars s
JOIN match_rating m ON s.MatchIndex = m.Index
JOIN events e ON e.Date = m.Date AND e.Promotion = m.Promotion
WHERE e.Event = 'WWE WrestleMania'
GROUP BY s.superstar_name, Year
ORDER BY TotalVotes DESC
LIMIT 20;

-- Superstar appearance in WrestleMania average viewers
SELECT 
    s.superstar_name,
    COUNT(DISTINCT YEAR(m.Date)) AS WrestleMania_Appearances,
    SUM(m.CageMatchRatingVotes) AS TotalVotes
FROM superstars s
JOIN match_rating m ON s.MatchIndex = m.Index
JOIN events e ON e.Date = m.Date AND e.Promotion = m.Promotion
WHERE e.Event = 'WWE WrestleMania'
GROUP BY s.superstar_name
ORDER BY WrestleMania_Appearances DESC, TotalVotes DESC
LIMIT 20;

-- Check if John Cena exists in the dataset
SELECT DISTINCT superstar_name FROM superstars WHERE superstar_name ILIKE '%cena%';

-- Let's look into John Cena's Most Viewed Fights in WrestleMania
SELECT s.superstar_name, YEAR(m.Date) AS Year, SUM(m.CageMatchRatingVotes) AS TotalVotes
    FROM superstars s
    JOIN match_rating m ON s.MatchIndex = m.Index
    JOIN events e ON e.Date = m.Date AND e.Promotion = m.Promotion
    WHERE e.Event = 'WWE WrestleMania'
    AND s.superstar_name ILIKE '%cena%'
    GROUP BY s.superstar_name, Year
    ORDER BY Year DESC;
