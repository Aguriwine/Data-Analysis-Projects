CREATE DATABASE PROJECT 
USE PROJECT;

SELECT * FROM Forest_Area;
SELECT * FROM Land_Area;
SELECT * FROM Region;

-- Bahamas , Korea, Dem. People�s Rep.

-- to find out the range for the years in the dataset--

SELECT DISTINCT YEAR
FROM Forest_Area
ORDER BY YEAR 

-- year range is from 1990 - 2016 --


-- DATA CLEANING -- 

-- FOREST AREA TABLE --

-- Possible problems from this table: 
--1. duplicates in country code ( country code should be distinct) ** the years are all in one table hence there are going to be duplicates, --
-- but there should only be a max of 27 duplicates in the country code column per code, each code should appear once in every year --

--2.there should also be a max of 27 duplicates per country name in the country_name column same reason as the country code --


SELECT * FROM Forest_Area;

-- CLEANING SOME COUNTRY NAMES FROM THE TABLE --

UPDATE Forest_Area SET country_name =
                                            CASE 
                                                WHEN country_name = 'Bahamas, The' THEN 'The Bahamas'
                                                WHEN country_name = 'Korea, Dem. People�s Rep.' THEN 'Korea, Dem. Peoples Rep.'
                                                ELSE country_name
                                            END;

SELECT * FROM Forest_Area



-- checking for duplicates --

SELECT country_code, COUNT(*)
FROM Forest_Area
GROUP BY country_code
HAVING COUNT(*) > 1;

-- Every country code appears 27 times in the table hence there are no duplicates in the country_code column --

SELECT country_name, COUNT(*)
FROM Forest_Area
GROUP BY country_name
HAVING COUNT(*) > 1;

SELECT DISTINCT year, COUNT(country_name) OVER (PARTITION BY year) AS country_count
FROM Forest_Area
WHERE year = 2016;

SELECT year, COUNT(*)
FROM Forest_Area
GROUP BY year

-- Every country name appears 27 times in the table hence there are no duplicates in the country_name column --

-- THERE ARE 218 COUNTRIES LISTED IN THE TABLE WITH EACH APPEARING 27 TIMES--

-- the 27 years ranging from 1990 - 2016 appear a total for 218 times--


-- CHANGING THE forest_area_sqkm to whole numbers with no decimal plaves --

UPDATE Forest_Area
SET forest_area_sqkm = ROUND(forest_area_sqkm, 0);

-- Chaning all the NULLS IN THG DATASET TO 0--

UPDATE Forest_Area SET forest_area_sqkm =
                                            CASE 
                                                WHEN forest_area_sqkm is NULL THEN '0'
                                                ELSE forest_area_sqkm
                                            END;

SELECT * FROM Forest_Area


-- *** FOREST AREA TABLE IS CLEANED --

-- LAND AREA TABLE  --

SELECT * FROM Land_Area;

-- Possible problems from this table: 
--1. duplicates in country code ( country code should be distinct) ** the years are all in one table hence there are going to be duplicates, --
-- but there should only be a max of 27 duplicates in the country code column per code, each code should appear once in every year --

--2.there should also be a max of 27 duplicates per country name in the country_name column same reason as the country code --

SELECT * FROM Land_Area;

-- checking for duplicates --

SELECT country_code, COUNT(*)
FROM Land_Area
GROUP BY country_code
HAVING COUNT(*) > 1;

-- Every country code appears 27 times in the table hence there are no duplicates in the country_code column --


SELECT country_name, COUNT(*)
FROM Land_Area
GROUP BY country_name
HAVING COUNT(*) > 1;

SELECT DISTINCT year, COUNT(country_name) OVER (PARTITION BY year) AS country_count
FROM Land_Area
WHERE year = year
ORDER BY year;

SELECT year, COUNT(*)
FROM Land_Area
GROUP BY year
ORDER BY year

-- Every country name appears 27 times in the table hence there are no duplicates in the country_name column --

-- THERE ARE 218 COUNTRIES LISTED IN THE TABLE WITH EACH APPEARING 27 TIMES--

-- the 27 years ranging from 1990 - 2016 appear a total for 218 times--

-- CHANGING THE forest_area_sqkm to whole numbers with no decimal plaves --

UPDATE Land_Area
SET total_area_sq_mi = ROUND(total_area_sq_mi, 0);

-- Chaning all the NULLS IN THG DATASET TO 0--

UPDATE land_Area SET total_area_sq_mi =
                                            CASE 
                                                WHEN total_area_sq_mi is NULL THEN '0'
                                                ELSE total_area_sq_mi
                                            END;

SELECT * FROM Land_Area

-- LAND AREA TABLE CLEANED --

-- CLEANING THE REGION TABLE --



SELECT * FROM Region;
SELECT * FROM Land_Area

-- Spelling mistakes in some country names -- --* the spelling mistakes could also be corrected from the edit data tab*--

UPDATE Region SET country_name =
                                            CASE 
                                                WHEN country_name = 'C�te d''Ivoire' THEN 'Cote d''Ivoire'
                                                WHEN country_name = 'Cura�ao' THEN 'Curaoao'
                                                WHEN country_name = 'S�o Tom� and Principe' THEN 'Sao Tomo and Principe'
                                                ELSE country_name
                                            END;



-- Question 1:  What are the total number of countries involved in deforestation? 



WITH deforesstationperiod AS (
    SELECT DISTINCT  country_name,
           forest_area_sqkm,
           YEAR,
           LAG(forest_area_sqkm) OVER(PARTITION BY country_name ORDER BY year) AS prev_forest_area,
           LEAD(forest_area_sqkm) OVER(PARTITION BY country_name ORDER BY year) AS next_forest_area
    FROM Forest_Area
)

SELECT DISTINCT COUNT(DISTINCT country_name)
       
FROM deforesstationperiod
WHERE forest_area_sqkm < prev_forest_area OR forest_area_sqkm < next_forest_area


-- Question 2: Show the income groups of countries having total area ranging from 75,000 to 150,000 square meter? --

--Joining the Region and Land Area tables but only displaying the country, land area and income group for countries that fit the range --
-- The list shows a country every year its total area met the criteria 

SELECT L.country_name, L.total_area_sq_mi,L.year, R.income_group
FROM Land_Area L FULL JOIN Region R on L.country_name = R.country_name 
WHERE total_area_sq_mi BETWEEN 75000 AND 150000
ORDER BY total_area_sq_mi;

-- COUNTING THE TOTAL NUMBER OF COUNTRIES THAT FIT THE CRITERIA --
 
SELECT COUNT(DISTINCT country_name) 
FROM Land_Area 
WHERE total_area_sq_mi BETWEEN 75000 AND 150000


-- 26 countries practiced deforestattion --


-- QUESTION 3 Calculate average area in square miles for countries in the 'upper middle income region'. Compare the result with the rest of the income categories.--

SELECT * FROM Region;
SELECT * FROM Land_Area;

SELECT R.income_group,ROUND(AVG(total_area_sq_mi), 0) AS 'AVG LAND AREA'
FROM Region R FULL JOIN Land_Area L ON R.country_name = L.country_name
GROUP BY R.income_group
HAVING income_group IN ('upper middle income','high income','low income','lower middle income')
ORDER BY 'AVG LAND AREA';


-- QUESTION 4 Determine the total forest area in square km for countries in the 'high income' group. Compare result with the rest of the income categories. --

SELECT * FROM Region;
SELECT * FROM Forest_Area;

SELECT R.income_group,ROUND(SUM(forest_area_sqkm), 0) AS 'TOTAL FOREST AREA'
FROM Region R FULL JOIN Forest_Area F ON R.country_name = F.country_name
GROUP BY R.income_group
HAVING income_group IN ('upper middle income','high income','low income','lower middle income')
ORDER BY 'TOTAL FOREST AREA';


-- QUESTION 5 Show countries from each region(continent) having the highest total forest areas. 
 
SELECT * FROM Region;
SELECT * FROM Forest_Area;



WITH Rankedcountries AS (
    SELECT R.country_name,
           R.region,
           F.forest_area_sqkm,
           ROW_NUMBER() OVER(PARTITION BY R.region ORDER BY F.forest_area_sqkm DESC) AS RANK 
    FROM Forest_Area F
    FULL JOIN Region R on F.country_name = R.country_name 
    WHERE Region IS NOT NULL 
) 

SELECT country_name,
       region,
       forest_area_sqkm
FROM Rankedcountries
WHERE RANK = 1 
ORDER BY forest_area_sqkm DESC;



