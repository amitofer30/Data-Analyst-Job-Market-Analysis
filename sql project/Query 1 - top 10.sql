/*

 Questions to Answer for the whole project(Query 1 -> 5)

    Query 1. What are the top-paying jobs for Data analysts?

    Query 2. What are the skills required for these top-paying roles?

    Query 3. What are the most in-demand skills for this role?(regradless top-paying jobs)

    Query 4. What are the top skills based on salary for my role?

    Query 5. What are the most optimal skills to learn?
        a. Optimal: High Demand AND High Paying

*/




---Query 0: just want to get a taste from our main table in order to get some sense about the solution 
SELECT 
    column_name, 
    data_type 
FROM 
    information_schema.columns
WHERE 
    table_name = 'job_postings_fact' ;


    
--Question: What are the top-paying data analyst jobs? 
---------Query 1-----------------
SELECT
    job_id,job_title,job_posted_date,job_schedule_type,salary_year_avg,
    job_location, name AS name_of_company   
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
/* I used a LEFT JOIN to ensure all top-paying jobs are included even if some company information is missing from the dimension table.  */
WHERE
    job_title_short = 'Data Analyst' AND job_location = 'Anywhere'
    and salary_year_avg is NOT NULL
ORDER BY  
   salary_year_avg DESC
LIMIT 10;



 