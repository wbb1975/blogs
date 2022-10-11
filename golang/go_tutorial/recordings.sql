-- Database: recordings

-- DROP DATABASE recordings;

CREATE DATABASE recordings
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'en_US.UTF-8'
       LC_CTYPE = 'en_US.UTF-8'
       CONNECTION LIMIT = -1;

-- https://badcodernocookie.com/psql-run-sql-file-from-command-line/#:~:text=To%20execute%20a%20.,%2DU%20postgres%20%2Df%20stuff.
DROP TABLE IF EXISTS album;


CREATE TABLE album (
  id         serial PRIMARY KEY,
  title      VARCHAR(128) NOT NULL,
  artist     VARCHAR(255) NOT NULL,
  price      DECIMAL(5,2) NOT NULL
);

INSERT INTO album
  (title, artist, price)
VALUES
  ('Blue Train', 'John Coltrane', 56.99),
  ('Giant Steps', 'John Coltrane', 63.99),
  ('Jeru', 'Gerry Mulligan', 17.99),
  ('Sarah Vaughan', 'Sarah Vaughan', 34.98);

select * from album;