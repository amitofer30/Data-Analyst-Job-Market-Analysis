# Data Analyst Job Market Analysis: Salary & Skills 📊

## Introduction
Dive into the data job market! Focusing on **Remote Data Analyst** roles, this project explores 💰 top-paying jobs, 🔥 in-demand skills, and 📈 where high demand meets high salary in the world of analytics.

🔍 **SQL queries?** Check them out here: [/sql project/](<./sql%20project/>)

## Source Of Data
Driven by a quest to navigate the data analyst job market more effectively, this project pinpointed the most lucrative and sought-after skills, streamlining the search for optimal career paths.

The data is sourced from [Luke Barousse's SQL Course]

### The questions I answered through my analysis:
1. What are the top-paying data analyst jobs (Remote)?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data analysts?
4. Which skills are associated with higher salaries?
5. What are the most **optimal** skills to learn (High Demand + High Salary)?

## Tools I Used
- **SQL:** The backbone of my analysis, allowing me to query the database and unearth critical insights.
- **PostgreSQL:** The database management system used for handling the extensive job posting data.
- **Python (Pandas & Matplotlib):** Used for deep-dive analysis and creating scatter plots to visualize the "Optimal Skills."
- **Cursor(VS Code):** My primary environment for writing SQL and Python scripts.
- **Git & GitHub:** Essential for version control and sharing my analysis.

## The Analysis

### 1. Top Paying Data Analyst Jobs
To identify the highest-paying roles, I filtered data analyst positions by average yearly salary, focusing exclusively on **Remote** jobs.
```sql
SELECT	
    job_id,
    job_title,
    salary_year_avg,
    name AS company_name
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' 
    AND job_location = 'Anywhere' 
    AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
```
*Insights:*

Wide Salary Range: Remote roles span from $184,000 to over $600,000.

Diverse Titles: Roles range from Senior Data Analyst to Director of Analytics, showing that "Data Analysis" scales into executive leadership.

| job_id  | job_title                              | job_posted_date      | job_schedule_type | salary_year_avg |
|---------|----------------------------------------|----------------------|-------------------|-----------------|
| 226942  | Data Analyst                           | 2023-02-20 15:13:33  | Full-time         | 650000.0        |
| 547382  | Director of Analytics                  | 2023-08-23 12:04:42  | Full-time         | 336500.0        |
| 552322  | Associate Director- Data Insights      | 2023-06-18 16:03:12  | Full-time         | 255829.5        |
| 99305   | Data Analyst, Marketing                | 2023-12-05 20:00:40  | Full-time         | 232423.0        |
| 1021647 | Data Analyst (Hybrid/Remote)           | 2023-01-17 00:17:23  | Full-time         | 217000.0        |
| 168310  | Principal Data Analyst (Remote)        | 2023-08-09 11:00:01  | Full-time         | 205000.0        |
| 731368  | Director, Data Analyst - HYBRID        | 2023-12-07 15:00:13  | Full-time         | 189309.0        |
| 310660  | Principal Data Analyst, AV Performance | 2023-01-05 00:00:25  | Full-time         | 189000.0        |
| 1749593 | Principal Data Analyst                 | 2023-07-11 16:00:05  | Full-time         | 186000.0        |
| 387860  | ERM Data Analyst                       | 2023-06-09 08:01:04  | Full-time         | 184000.0        |



### 2. Skills for Top Paying Jobs
Which skills do these top-earners actually use?
Query:
```sql
WITH top_paying_jobs AS (
    SELECT job_id, salary_year_avg
    FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst' AND job_location = 'Anywhere' AND salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC LIMIT 10
)
SELECT top_paying_jobs.*, skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id;
```
*Top Skills Mentioned:* SQL (8/10 postings),Python (7/10 postings),Tableau (6/10 postings)

![Query 2 Graph](sql%20load/sql_load/Query%202%20-%20graph.png)


### 3. In-Demand Skills for Data Analysts
I identified the skills most frequently requested, ensuring a focus on market volume.
| Skills   | Demand Count |
|----------|--------------|
| SQL      | 7,291        |
| Excel    | 4,611        |
| Python   | 4,330        |
| Tableau  | 3,745        |
| Power BI | 2,609        |


![Query 3 Graph](sql%20load/sql_load/Query%203%20-%20graph.png)

### 4. Skills Based on Salary
Which specialized tools command the highest paychecks?
| Skills        | Average Salary ($) |
|---------------|-------------------:|
| PySpark | 208,172            |
| Bitbucket | 189,155            |
| Couchbase | 160,515            |
| DataRobot | 155,486            |
| Pandas | 151,821            |

![Query 4 Graph](sql%20load/sql_load/Query%204%20-%20graph.png)

Query:
```sql
WITH skills_demand AS (
    SELECT
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS demand_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst' 
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True 
    GROUP BY
        skills_dim.skill_id
), 
-- Skills with high average salaries for Data Analyst roles
-- Use Query #4
average_salary AS (
    SELECT 
        skills_job_dim.skill_id,
        ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True 
    GROUP BY
        skills_job_dim.skill_id
)
-- Return high demand and high salaries for 10 skills 
SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    avg_salary
FROM
    skills_demand
INNER JOIN  average_salary ON skills_demand.skill_id = average_salary.skill_id
WHERE  
    demand_count > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;

-- rewriting this same query more concisely
SELECT 
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True 
GROUP BY
    skills_dim.skill_id
HAVING
    COUNT(skills_job_dim.job_id) > 10
    --- i want only skills that repeat more than 10 times
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;
```
*Insights:*

Big Data & ML: Tools like PySpark and DataRobot dominate the top salary brackets.

DevOps/Engineering: GitLab and Bitbucket skills show a lucrative crossover between analysis and engineering.

### 5. Most Optimal Skills to Learn (The Sweet Spot)
Using Python and SQL, I mapped skills that are both high in demand and high in salary.
![Query 5 Graph](sql%20load/sql_load/Query%205%20-%20graph.png)

Query:
```sql
SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL AND job_work_from_home = True
GROUP BY skills
HAVING COUNT(skills_job_dim.job_id) > 10
ORDER BY avg_salary DESC, demand_count DESC;
```
*Optimal Skill Breakdown:*

High-Demand Powerhouses: Python and R are the foundations, with the highest volume of postings.

The Golden Quadrant: Snowflake, Azure, and AWS offer the best combination of high demand and high salary.

Specialized Tools: Go and Hadoop lead in salary but require a more targeted job search.

### What I Learned
🧩 Complex Querying: Mastered advanced joins and Common Table Expressions (CTEs).

📊 Python Integration: Learned to bridge the gap between SQL data extraction and Python visualization.

💡 Strategic Analysis: Realized that high salary often correlates with "Cloud" and "Big Data" technologies rather than just basic reporting tools.

Conclusions
SQL is Non-Negotiable: It is both the most in-demand skill and a requirement for the highest-paying roles.

Cloud is King: Specializing in Snowflake or Azure significantly boosts salary potential.

Remote is Lucrative: The remote market for Data Analysts is highly competitive but offers top-tier compensation (up to $650k).





