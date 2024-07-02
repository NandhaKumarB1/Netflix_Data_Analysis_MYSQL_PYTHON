****🚀 Netflix Data Analysis Project****

Excited to share my recent project on Netflix data analysis using Python and MySQL! 📊

**Project Overview:**

I worked with a dataset containing 8,808 records of movies and TV shows, covering dates from 1925 to 2021. Here's a breakdown of the steps I followed:

**Data Cleaning & Transformation**

**Loaded Data:** Imported data in Python using pandas and connected to my local MySQL server using SQLAlchemy.

**Removed Duplicates: ** Checked for and removed duplicates, reducing the dataset to 8,800 records.

**Handled Multiple Values:** Created a split_string function to handle multiple values in fields such as genre, country, director, and cast, creating separate rows for each value.

**Addressed Null Values:** Filled missing values in the country field by referencing previous entries of the director.

**Data Modeling**

**Created Tables:** Normalized the data into tables: netflix_show, netflix_genre, netflix_cast, netflix_country, and netflix_director.

**Ensured Data Integrity:** Optimized the schema for efficient querying and analysis.

**Key Insights Extracted**

Counted the number of movies and TV shows for each director.

Identified the country with the highest number of comedy movies.

Determined which director had the most movie releases each year.

Calculated the average duration of movies by genre.

Listed directors who have created both horror and comedy movies.

Identified the top 5 most popular actors based on TV shows.

Analyzed the most frequent director-country collaborations.

Found the top 3 genres with the highest number of releases each year.

Counted actor collaborations with director Rajiv Chilaka.

Determined the dominant genre in each country.

**Conclusion**

This project was an incredible learning experience, enhancing my skills in data cleaning, ELT processes, and SQL query solving.

**Technologies Used**

Python

MySQL

Pandas

SQLAlchemy

EXcel


**Hashtags**
#DataAnalysis #Python #MySQL #ETL #DataScience #NetflixAnalysis #DataCleaning #DataTransformation #DataModeling #DataVisualization #SQL #BigData
