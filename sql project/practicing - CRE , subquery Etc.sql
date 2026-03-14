 
 
 --------alter table---------------------------
 ALTER TABLE job_applied 
ADD amitutu varchar(50);
ALTER TABLE job_applied drop column amitutu  ;
-------------update - setting value---------------------------------------------
update job_applied 
set amitutu = 'sexy'
where contact_name = 'David';



 --ראיה של טבלה אחרי CASTING 
----------------------------::DATE-----------------------
SELECT job_title_short AS title ,job_location as location ,
job_posted_date::DATE AS date 
FROM job_postings_fact
LIMIT 10
------------------AT TIME ZONE------------------------------------

 SELECT job_title_short AS title ,job_location as location ,
job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date 
FROM job_postings_fact
LIMIT 10
--------------------------EXTRACT--------------------------
SELECT job_id,job_posted_date, EXTRACT(MONTH FROM job_posted_date) AS MONTH
FROM job_postings_fact
LIMIT 5;

SELECT count(job_id) AS POSTED_COUNT, EXTRACT(MONTH FROM job_posted_date) AS MONTH
FROM job_postings_fact

GROUP BY MONTH
ORDER BY POSTED_COUNT DESC 

LIMIT 5;

-- select * from job_applied



---------------order by-----------------------
SELECT job_schedule_type,job_posted_date as date, salary_hour_avg,salary_year_avg
FROM job_postings_fact
ORDER BY salary_year_avg ASC
LIMIT 100


-------------------------------------------
SELECT 
    job_schedule_type,
    AVG(salary_year_avg) AS avg_yearly_salary,
    AVG(salary_hour_avg) AS avg_hourly_salary
FROM 
    job_postings_fact -- שם הטבלה כפי שמופיע בדרך כלל בתרגול זה
WHERE 
    job_posted_date > '2023-06-01'
GROUP BY 
    job_schedule_type;
    -----------------------------------------------------
    select 
            EXTRACT(MONTH from job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'Israel') as mounth,count(job_id)
from job_postings_fact
group by mounth
order by mounth
 --------------------JOIN------------------------------------
 SELECT
    company_dim.name AS company_name
FROM
    job_postings_fact
INNER JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_health_insurance = TRUE
    AND EXTRACT(QUARTER FROM job_posted_date) = 2
    AND EXTRACT(YEAR FROM job_posted_date) = 2023
GROUP BY
    company_name;   
    ----------------------------------------------------------------------
    -- February
CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

-- March
CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT job_posted_date
FROM march_jobs
-------------------------case-when-else-end----------------------------------
SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;
 ----------------case-when-else-end------------------------------------
    SELECT case 
                WHEN salary_year_avg < 200000 THEN 'low'
                when salary_year_avg > 600000 THEN 'High'
                ELSE 'medium'
                end as salary_ranks, job_id
    from job_postings_fact
    where job_title like '%data analyst%'
 order by salary_ranks DESC
   -- where job_title_short like '%data analyst%'

-----------------------SubQuery--------------------------------
SELECT *
FROM ( -- SubQuery starts here
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;
-- SubQuery ends here
------------------HAVING------------------------
SELECT 
    job_schedule_type,
    AVG(salary_year_avg) AS avg_salary
FROM 
    job_postings_fact
GROUP BY 
    job_schedule_type
HAVING 
    AVG(salary_year_avg) > 100000;-- מסנן את הקבוצות שנוצרו
------------Subquery(inside WHERE)--------------------------------------------------

SELECT
    company_id,
    name AS company_name
FROM
    company_dim
WHERE company_id IN (
    SELECT
        company_id
    FROM
        job_postings_fact
    WHERE
        job_no_degree_mention = true
    ORDER BY
        company_id
)

-----------------------------------------Subquery(inside FROM)----------------------
SELECT 
    skills_dim.skills AS skill_name,
    top_skills.skill_count
FROM (
    -- שאילתת משנה למציאת 5 ה-IDs הנפוצים ביותר
    SELECT 
        skill_id, 
        COUNT(*) AS skill_count
    FROM 
        skills_job_dim
    GROUP BY 
        skill_id
    ORDER BY 
        skill_count DESC
    LIMIT 5
) AS top_skills
INNER JOIN skills_dim ON top_skills.skill_id = skills_dim.skill_id;
----------------------------------Subquery(inside FROM--------------------------------
select 
    company_dim.name as name_of_company,
    case 
        when table_order.company_count < 10 THEN 'small'
        when table_order.company_count >= 10 and table_order.company_count < 50 then 'medium'
        when table_order.company_count >= 50 then 'large'
    end as company_size
from (
    select company_id, count(*) as company_count
    from job_postings_fact 
    group by company_id
    -- removed order by from subquery; it's not allowed here
) as table_order
INNER JOIN company_dim ON table_order.company_id = company_dim.company_id
order by table_order.company_count DESC;





-------------CTE----------------------------------------------------------
WITH jobs_no_degree AS (
    -- כאן אנחנו מגדירים את ה"טבלה הזמנית" שלנו
    SELECT
        company_id
    FROM
        job_postings_fact
    WHERE
        job_no_degree_mention = true
)

SELECT
    company_id,
    name AS company_name
FROM
    company_dim
WHERE company_id IN (SELECT company_id FROM jobs_no_degree);
-------------------------UNION----------------------------------------
-- Get jobs and companies from January

-- 1. איחוד כל המשרות מהרבעון הראשון לטבלה אחת זמנית
WITH
    january_jobs AS (
        SELECT *
        FROM job_postings_fact
        WHERE EXTRACT(MONTH FROM job_posted_date) = 1
    ),
    february_jobs AS (
        SELECT *
        FROM job_postings_fact
        WHERE EXTRACT(MONTH FROM job_posted_date) = 2
    ),
    march_jobs AS (
        SELECT *
        FROM job_postings_fact
        WHERE EXTRACT(MONTH FROM job_posted_date) = 3
    ),
    q1_job_postings AS (
        SELECT * FROM january_jobs
        UNION ALL
        SELECT * FROM february_jobs
        UNION ALL
        SELECT * FROM march_jobs
    )

-- 2. שליפת הנתונים וחיבור לכישורים
SELECT 
    q1.job_id,
    q1.job_title_short,
    q1.salary_year_avg,
    sd.skills AS skill_name,
    sd.type AS skill_type
FROM 
    q1_job_postings AS q1
LEFT JOIN skills_job_dim AS sjd ON q1.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id
WHERE 
    q1.salary_year_avg > 70000
ORDER BY 
    q1.job_id;
    -----------------------------------------------------
 SELECT *
        