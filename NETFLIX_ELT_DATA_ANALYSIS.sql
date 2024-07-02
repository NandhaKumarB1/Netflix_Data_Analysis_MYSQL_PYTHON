CREATE TABLE NETFLIX (
    SHOW_ID VARCHAR(10) PRIMARY KEY,
    TYPE VARCHAR(10),
    TITLE NVARCHAR(200),
    DIRECTOR VARCHAR(250),
    CAST VARCHAR(1000),
    COUNTRY VARCHAR(150),
    DATE_ADDED VARCHAR(20),
    RELEASE_YEAR INT,
    RATING VARCHAR(10),
    DURATION VARCHAR(10),
    LISTED_IN VARCHAR(100),
    DESCRIPTION VARCHAR(500)
);

-- DISPLAYING TOTAL RECORDS

SELECT COUNT(*) FROM NETFLIX;

-- CHECKING IF ANY DUPLICATES AVAILABLE WITH SHOW_ID

SELECT 
    SHOW_ID, COUNT(*) AS DUPLICATE_COUNT
FROM
    NETFLIX
GROUP BY SHOW_ID
HAVING COUNT(*) > 1;

-- VERIFYING DUPLICATE'S USING TITLE AND TYPE

SELECT * FROM NETFLIX WHERE UPPER(TITLE) IN
(SELECT 
    UPPER(TITLE)
FROM
    NETFLIX
GROUP BY UPPER(TITLE), TYPE
HAVING COUNT(*) > 1
)
ORDER BY TITLE;

-- REMOVING 7 DUPLICATES WHICH WE FOUND

DELETE FROM NETFLIX
WHERE SHOW_ID IN (
  SELECT SHOW_ID
  FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY TITLE, TYPE ORDER BY SHOW_ID) AS S_NO
    FROM NETFLIX
  ) AS CTE
  WHERE S_NO > 1
);

-- RESULT DATASET AFTER DELETING 7 DUPLICATES

SELECT COUNT(*) FROM NETFLIX;

-- CREATE SEPARATE TABLE FOR SHOWS TO DO DATA ANALYSIS EFFECTIVELY

DROP TABLE IF EXISTS NETFLIX_SHOW;

CREATE TABLE NETFLIX_SHOW AS 
SELECT 
    SHOW_ID, TYPE, TITLE, DATE_ADDED, RELEASE_YEAR, RATING,
    (CASE
        WHEN DURATION IS NULL THEN RATING
        ELSE DURATION
    END) AS DURATION,
    DESCRIPTION
FROM NETFLIX;

SELECT * FROM NETFLIX_SHOW;

-- CHECKING DATA TRANSFORM FROM LISTED_IN INTO GENRE AS SEPARATE COLUMNS'S

SELECT 
    SHOW_ID,
    LISTED_IN,
    TRIM(SUBSTRING_INDEX(LISTED_IN, ',', 1)) AS GENRE,
    TRIM(SUBSTRING(LISTED_IN, LOCATE(',', LISTED_IN) + 1)) AS REMAINING_GENRES
FROM 
    NETFLIX
LIMIT 10;

-- CREATING FUNCTION TO SPLIT STRING

DROP FUNCTION IF EXISTS SPLIT_STRING;

DELIMITER $$

CREATE FUNCTION SPLIT_STRING(str TEXT, delim VARCHAR(12), pos INT) RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE output TEXT;
  SET output = REPLACE(SUBSTRING(SUBSTRING_INDEX(str, delim, pos),
                    LENGTH(SUBSTRING_INDEX(str, delim, pos -1)) + 1),
                    delim, '');
  RETURN output;
END$$

DELIMITER ;

-- create Netflix country table from main Netflix table

DROP TABLE IF EXISTS NETFLIX_COUNTRY;

CREATE TABLE NETFLIX_COUNTRY (
    SHOW_ID VARCHAR(10),
    COUNTRY TEXT
);

-- Insert split countries into the NETFLIX_COUNTRY table

INSERT INTO NETFLIX_COUNTRY (SHOW_ID, COUNTRY)
SELECT 
    TRIM(SHOW_ID), 
    TRIM(SPLIT_STRING(COUNTRY, ',', numbers.n)) AS COUNTRY
FROM 
    NETFLIX,
    (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
     SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL 
     SELECT 9 UNION ALL SELECT 10) numbers
WHERE 
    TRIM(SPLIT_STRING(COUNTRY, ',', numbers.n) IS NOT NULL AND SPLIT_STRING(COUNTRY, ',', numbers.n) != '');
    
SELECT * FROM NETFLIX_COUNTRY;
    
-- create Netflix Director table from main Netflix table   
 
DROP TABLE IF EXISTS NETFLIX_DIRECTOR;

CREATE TABLE NETFLIX_DIRECTOR (
    SHOW_ID VARCHAR(10),
    DIRECTOR TEXT
);

-- Insert split Director into the NETFLIX_Director table

INSERT INTO NETFLIX_DIRECTOR (SHOW_ID, DIRECTOR)
SELECT 
    SHOW_ID, 
    SPLIT_STRING(DIRECTOR, ',', numbers.n) AS DIRECTOR
FROM 
    NETFLIX,
    (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
     SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL 
     SELECT 9 UNION ALL SELECT 10) numbers
WHERE 
    SPLIT_STRING(DIRECTOR, ',', numbers.n) IS NOT NULL AND SPLIT_STRING(DIRECTOR, ',', numbers.n) != '';

-- View Netflix Director table   

SELECT * FROM NETFLIX_DIRECTOR;

-- create Netflix CAST table from main Netflix table 
    
DROP TABLE IF EXISTS NETFLIX_CAST;

CREATE TABLE NETFLIX_CAST (
    SHOW_ID VARCHAR(10),
    CAST TEXT
);

-- Insert split cast into the NETFLIX_CAST table

INSERT INTO NETFLIX_CAST (SHOW_ID, CAST)
SELECT 
    SHOW_ID, 
    SPLIT_STRING(CAST, ',', numbers.n) AS CAST
FROM 
    NETFLIX,
    (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
     SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL 
     SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL
     SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
     SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20) numbers
WHERE 
    SPLIT_STRING(CAST, ',', numbers.n) IS NOT NULL AND SPLIT_STRING(CAST, ',', numbers.n) != '';
    
-- View Netflix CAST table   

SELECT * FROM NETFLIX_CAST;

-- create Netflix GENRE table from main Netflix table 

DROP TABLE IF EXISTS NETFLIX_GENRE;

CREATE TABLE NETFLIX_GENRE (
    SHOW_ID VARCHAR(10),
    GENRE TEXT
);

-- Insert split GENRE into the NETFLIX_GENRE table

INSERT INTO NETFLIX_GENRE (SHOW_ID, GENRE)
SELECT 
    TRIM(SHOW_ID), 
    TRIM(SPLIT_STRING(LISTED_IN, ',', numbers.n)) AS GENRE
FROM 
    NETFLIX,
    (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
     SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL 
     SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL
     SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
     SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20) numbers
WHERE 
    TRIM(SPLIT_STRING(LISTED_IN, ',', numbers.n) IS NOT NULL AND SPLIT_STRING(LISTED_IN, ',', numbers.n) != '');
    
-- View Netflix GENRE table  

SELECT * FROM NETFLIX_GENRE;

SELECT COUNT(*) FROM NETFLIX_COUNTRY;

-- FILLING COUNTRY TABLE NULL VALUE WITH PREVIOUS DIRECTOR COUNTRY

INSERT INTO NETFLIX_COUNTRY
SELECT SHOW_ID, M.COUNTRY
FROM NETFLIX AS N
INNER JOIN (
    SELECT DIRECTOR, COUNTRY
    FROM NETFLIX_COUNTRY AS NC
    INNER JOIN NETFLIX_DIRECTOR AS ND ON NC.SHOW_ID = ND.SHOW_ID
    GROUP BY DIRECTOR, COUNTRY
) M ON N.DIRECTOR = M.DIRECTOR
WHERE N.COUNTRY IS NULL;


/* 1 FOR EACH DIRECTOR COUNT THE NO OF MOVIES AND TV SHOWS CREATED BY THEM IN SEPARATE COLUMNS 
FOR DIRECTORS WHO HAVE CREATED TV SHOWS AND MOVIES BOTH */

SELECT ND.DIRECTOR, 
COUNT(CASE WHEN NS.TYPE='Movie' THEN NS.SHOW_ID END) AS NO_OF_MOVIES,
COUNT(CASE WHEN NS.TYPE='Tv Show' THEN NS.SHOW_ID END) AS NO_OF_TV_SHOWS
FROM NETFLIX_SHOW AS NS INNER JOIN NETFLIX_DIRECTOR AS ND ON
NS.SHOW_ID = ND.SHOW_ID
GROUP BY DIRECTOR
having COUNT(DISTINCT NS.TYPE)>1 ;

-- 2 WHICH COUNTRY HAS HIGHEST NUMBER OF COMEDY MOVIES 

SELECT NC.COUNTRY, COUNT(*) AS NO_OF_COMEDY_MOVIES FROM NETFLIX_COUNTRY AS NC 
JOIN NETFLIX_GENRE AS NG ON NC.SHOW_ID = NG.SHOW_ID 
JOIN NETFLIX_SHOW AS NS ON NS.SHOW_ID = NG.SHOW_ID
WHERE GENRE = 'Comedies' AND NS.TYPE='Movie'
GROUP BY NC.COUNTRY
ORDER BY NO_OF_COMEDY_MOVIES DESC;

-- 3. FOR EACH YEAR WHICH DIRECTOR HAS MAXIMUM NUMBER OF MOVIES RELEASED

WITH CTE AS
 ( SELECT YEAR(DATE_ADDED) AS DATE_YEAR, DIRECTOR, COUNT(NS.SHOW_ID) AS NO_OF_MOVIES FROM NETFLIX_SHOW AS NS 
   INNER JOIN NETFLIX_DIRECTOR AS ND ON
   ND.SHOW_ID = NS.SHOW_ID
   WHERE NS.TYPE='Movie'
   GROUP BY ND.DIRECTOR, DATE_YEAR
  ),
CTE2 AS 
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY DATE_YEAR ORDER BY NO_OF_MOVIES DESC) AS RN
FROM CTE
ORDER BY DATE_YEAR, NO_OF_MOVIES DESC
)
SELECT * FROM CTE2 WHERE RN =1;

-- 4. WHAT IS AVERAGE DURATION OF MOVIES IN EACH GENRE

SELECT 
    NS.SHOW_ID, GENRE, ROUND(AVG(REPLACE(DURATION, ' MIN', '')), 0) AS AVG_DURATION
FROM
    NETFLIX_SHOW AS NS
        JOIN
    NETFLIX_GENRE AS NG ON NG.SHOW_ID = NS.SHOW_ID
WHERE
    NS.TYPE = 'Movie'
GROUP BY GENRE;

/* 5. FIND THE LIST OF DIRECTORS WHO HAVE CREATED HORROR AND COMEDY MOVIES BOTH. 
DISPLAY DIRECTOR NAMES ALONG WITH NUMBER OF COMEDY AND HORROR MOVIES DIRECTED BY THEM */

SELECT ND.DIRECTOR,
       COUNT(DISTINCT CASE WHEN NG.GENRE = 'Comedies' THEN NS.SHOW_ID END) AS NO_OF_COMEDY_MOVIES,
       COUNT(DISTINCT CASE WHEN NG.GENRE = 'Horror Movies' THEN NS.SHOW_ID END) AS NO_OF_HORROR_MOVIES
FROM NETFLIX_SHOW AS NS
INNER JOIN NETFLIX_GENRE AS NG ON NS.SHOW_ID = NG.SHOW_ID
INNER JOIN NETFLIX_DIRECTOR AS ND ON NS.SHOW_ID = ND.SHOW_ID
WHERE TYPE = 'Movie'
  AND NG.GENRE IN ('Comedies', 'Horror Movies')
GROUP BY ND.DIRECTOR
HAVING COUNT(DISTINCT NG.GENRE) = 2;
 
/* 6. TOP 5 MOST POPULAR ACTORS BASED ON TV SHOWS */

SELECT CAST, COUNT(DISTINCT NS.SHOW_ID) AS NO_OF_SHOWS
FROM NETFLIX_CAST AS NC JOIN  NETFLIX_SHOW AS NS ON NS.SHOW_ID=NC.SHOW_ID
WHERE NS.TYPE='Tv Show'
GROUP BY CAST
ORDER BY NO_OF_SHOWS DESC
LIMIT 5;

/* 7. MOST FREQUENT DIRECTOR - COUNTRY COLLABRATION */

SELECT NC.COUNTRY, ND.DIRECTOR, COUNT(*) AS NO_OF_COLLABORATIONS
FROM NETFLIX_COUNTRY AS NC
JOIN NETFLIX_SHOW AS NS ON NC.SHOW_ID = NS.SHOW_ID
JOIN NETFLIX_DIRECTOR AS ND ON NS.SHOW_ID = ND.SHOW_ID
GROUP BY NC.COUNTRY, ND.DIRECTOR
ORDER BY NO_OF_COLLABORATIONS DESC
LIMIT 10;


/* 8 FOR EACH YEAR, WHICH 3 GENRES HAD THE HIGHEST NUMBER OF SHOWS RELEASED?*/

WITH RankedGenres AS (
  SELECT RELEASE_YEAR, GENRE, COUNT(*) AS NO_OF_SHOWS,
         ROW_NUMBER() OVER(PARTITION BY RELEASE_YEAR ORDER BY COUNT(*) DESC) AS RN
  FROM NETFLIX_SHOW
  LEFT JOIN NETFLIX_GENRE ON NETFLIX_SHOW.SHOW_ID = NETFLIX_GENRE.SHOW_ID
  GROUP BY RELEASE_YEAR, GENRE
  ORDER BY RELEASE_YEAR DESC
)
SELECT * FROM RankedGenres
WHERE RN <= 3;

/* 9. HOW MANY ACTORS HAVE COLLABORATED WITH DIRECTOR Rajiv Chilaka */

SELECT COUNT(DISTINCT CAST) AS NO_OF_COLLABRATION
FROM NETFLIX_SHOW AS NS
JOIN NETFLIX_CAST AS NC ON NS.SHOW_ID = NC.SHOW_ID
JOIN NETFLIX_DIRECTOR AS ND ON NS.SHOW_ID = ND.SHOW_ID
WHERE ND.DIRECTOR = 'Rajiv Chilaka';

/* 10. WHICH GENRE REIGNS SUPREME IN EACH COUNTRY */

WITH RankedGenresPerCountry AS (
  SELECT NC.COUNTRY, GENRE, COUNT(*) AS NO_OF_SHOWS,
         ROW_NUMBER() OVER(PARTITION BY NC.COUNTRY ORDER BY COUNT(*) DESC) AS RN
  FROM NETFLIX_SHOW AS NS
  JOIN NETFLIX_COUNTRY AS NC ON NC.SHOW_ID = NS.SHOW_ID
  JOIN NETFLIX_GENRE AS NG ON NS.SHOW_ID = NG.SHOW_ID
  GROUP BY NC.COUNTRY, GENRE
  ORDER BY NC.COUNTRY ASC,NO_OF_SHOWS DESC
)
SELECT * FROM RankedGenresPerCountry
WHERE RN = 1;
