/*
Question: What are the most in-demand skills for data analysts?
*/
WITH top_5_skills AS (
    SELECT
        skills,
        COUNT(*) as demand
    FROM
        job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst'
    GROUP BY
        skills
    ORDER BY
        demand DESC
    LIMIT 5
)
SELECT *
FROM top_5_skills;

/*
please have a look at ("Query 3 - top skills.ipynb")

