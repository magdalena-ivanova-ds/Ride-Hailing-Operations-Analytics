-- 1) Define rider cohorts by signup month
WITH rider_cohorts AS (
    SELECT
        rider_id,
        DATE_TRUNC('month', signup_date)::date AS cohort_month
    FROM riders
),

-- 2) Rider activity by month (first 6 months after signup)
rider_activity AS (
    SELECT
        t.rider_id,
        DATE_TRUNC('month', t.requested_at)::date AS activity_month
    FROM trips t
    WHERE t.status = 'completed'
),

-- 3) Join cohorts with activity and compute month_offset from cohort
activity_with_offset AS (
    SELECT
        rc.cohort_month,
        ra.rider_id,
        ra.activity_month,
        (EXTRACT(YEAR FROM ra.activity_month) - EXTRACT(YEAR FROM rc.cohort_month)) * 12
        + (EXTRACT(MONTH FROM ra.activity_month) - EXTRACT(MONTH FROM rc.cohort_month)) AS month_offset
    FROM rider_cohorts rc
    JOIN rider_activity ra ON rc.rider_id = ra.rider_id
    WHERE ra.activity_month >= rc.cohort_month
      AND ra.activity_month < rc.cohort_month + INTERVAL '6 months'
),

cohort_sizes AS (
    SELECT cohort_month, COUNT(DISTINCT rider_id) AS cohort_size
    FROM rider_cohorts
    GROUP BY cohort_month
),

retention AS (
    SELECT
        a.cohort_month,
        a.month_offset,
        COUNT(DISTINCT a.rider_id) AS active_riders
    FROM activity_with_offset a
    GROUP BY a.cohort_month, a.month_offset
)

SELECT
    r.cohort_month,
    r.month_offset,
    c.cohort_size,
    r.active_riders,
    ROUND(r.active_riders::DECIMAL / NULLIF(c.cohort_size, 0) * 100, 2) AS retention_rate_pct
FROM retention r
JOIN cohort_sizes c USING (cohort_month)
WHERE r.month_offset BETWEEN 0 AND 5
ORDER BY r.cohort_month, r.month_offset;
