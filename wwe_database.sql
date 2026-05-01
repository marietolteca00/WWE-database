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
# Lets try some queries
SELECT * FROM events;

SELECT EventType(*) FROM events;