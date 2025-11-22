-- 1) Daily demand & revenue per pickup zone
SELECT
    z.zone_name,
    DATE(t.requested_at) AS trip_date,
    COUNT(*) FILTER (WHERE t.status = 'completed') AS completed_trips,
    SUM(t.price_eur) FILTER (WHERE t.status = 'completed') AS gross_revenue_eur
FROM trips t
JOIN zones z ON t.pickup_zone_id = z.zone_id
GROUP BY z.zone_name, DATE(t.requested_at)
ORDER BY trip_date, zone_name;


-- 2) Top 5 zones by weekly revenue (window functions)

WITH weekly_zone_revenue AS (
    SELECT
        DATE_TRUNC('week', t.requested_at) AS week_start,
        z.zone_name,
        SUM(t.price_eur) FILTER (WHERE t.status = 'completed') AS revenue_eur
    FROM trips t
    JOIN zones z ON t.pickup_zone_id = z.zone_id
    GROUP BY DATE_TRUNC('week', t.requested_at), z.zone_name
)
SELECT *
FROM (
    SELECT
        week_start,
        zone_name,
        revenue_eur,
        RANK() OVER (
            PARTITION BY week_start
            ORDER BY revenue_eur DESC
        ) AS revenue_rank
    FROM weekly_zone_revenue
) ranked
WHERE revenue_rank <= 5
ORDER BY week_start, revenue_rank;


-- 3) 7-day rolling average trips per zone

WITH daily_counts AS (
    SELECT
        z.zone_name,
        DATE(t.requested_at) AS trip_date,
        COUNT(*) FILTER (WHERE t.status = 'completed') AS completed_trips
    FROM trips t
    JOIN zones z ON t.pickup_zone_id = z.zone_id
    GROUP BY z.zone_name, DATE(t.requested_at)
)
SELECT
    zone_name,
    trip_date,
    completed_trips,
    AVG(completed_trips) OVER (
        PARTITION BY zone_name
        ORDER BY trip_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7d_avg_trips
FROM daily_counts
ORDER BY zone_name, trip_date;


-- 4) Peak hour (by average trips) per zone

WITH hourly_counts AS (
    SELECT
        z.zone_name,
        DATE(t.requested_at) AS trip_date,
        EXTRACT(HOUR FROM t.requested_at) AS hour_of_day,
        COUNT(*) AS trips
    FROM trips t
    JOIN zones z ON t.pickup_zone_id = z.zone_id
    WHERE t.status = 'completed'
    GROUP BY z.zone_name, DATE(t.requested_at), EXTRACT(HOUR FROM t.requested_at)
),
avg_by_hour AS (
    SELECT
        zone_name,
        hour_of_day,
        AVG(trips) AS avg_trips
    FROM hourly_counts
    GROUP BY zone_name, hour_of_day
)
SELECT zone_name, hour_of_day, avg_trips
FROM (
    SELECT
        zone_name,
        hour_of_day,
        avg_trips,
        ROW_NUMBER() OVER (
            PARTITION BY zone_name
            ORDER BY avg_trips DESC
        ) AS rn
    FROM avg_by_hour
) ranked
WHERE rn = 1
ORDER BY avg_trips DESC;
