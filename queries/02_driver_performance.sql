-- 1) Driver lifetime metrics
WITH driver_stats AS (
    SELECT
        d.driver_id,
        d.signup_date,
        d.vehicle_type,
        d.status,
        COUNT(*) FILTER (WHERE t.status = 'completed') AS completed_trips,
        COUNT(*) FILTER (WHERE t.status != 'completed') AS non_completed_trips,
        COALESCE(SUM(t.price_eur) FILTER (WHERE t.status = 'completed'), 0) AS total_revenue_eur
    FROM drivers d
    LEFT JOIN trips t ON d.driver_id = t.driver_id
    GROUP BY d.driver_id, d.signup_date, d.vehicle_type, d.status
)
SELECT *
FROM driver_stats
ORDER BY total_revenue_eur DESC
LIMIT 50;


-- 2) Top 10% drivers by revenue (percentile using NTILE)

WITH driver_revenue AS (
    SELECT
        d.driver_id,
        COALESCE(SUM(t.price_eur) FILTER (WHERE t.status = 'completed'), 0) AS total_revenue_eur
    FROM drivers d
    LEFT JOIN trips t ON d.driver_id = t.driver_id
    GROUP BY d.driver_id
),
deciled AS (
    SELECT
        driver_id,
        total_revenue_eur,
        NTILE(10) OVER (ORDER BY total_revenue_eur DESC) AS revenue_decile
    FROM driver_revenue
)
SELECT *
FROM deciled
WHERE revenue_decile = 1
ORDER BY total_revenue_eur DESC
LIMIT 50;


-- 3) Crude driver utilization: trips per day as active

WITH driver_days AS (
    SELECT
        driver_id,
        DATE_TRUNC('day', requested_at) AS day,
        COUNT(*) FILTER (WHERE status = 'completed') AS completed_trips
    FROM trips
    GROUP BY driver_id, DATE_TRUNC('day', requested_at)
),
driver_util AS (
    SELECT
        driver_id,
        COUNT(DISTINCT day) AS active_days,
        SUM(completed_trips) AS total_completed_trips,
        (SUM(completed_trips)::DECIMAL / NULLIF(COUNT(DISTINCT day), 0)) AS trips_per_active_day
    FROM driver_days
    GROUP BY driver_id
)
SELECT *
FROM driver_util
ORDER BY trips_per_active_day DESC
LIMIT 50;
