-- 1) Cancellation rate by rider marketing_source

SELECT
    r.marketing_source,
    COUNT(*) AS total_trips,
    COUNT(*) FILTER (WHERE t.status != 'completed') AS cancelled_or_no_show,
    ROUND(
        COUNT(*) FILTER (WHERE t.status != 'completed')::DECIMAL
        / NULLIF(COUNT(*), 0) * 100, 2
    ) AS cancellation_rate_pct
FROM trips t
JOIN riders r ON t.rider_id = r.rider_id
GROUP BY r.marketing_source
ORDER BY cancellation_rate_pct DESC;


-- 2) Riders with suspicious behaviour (high cancellations in last 30 days)

WITH recent_trips AS (
    SELECT
        t.rider_id,
        t.status,
        t.requested_at::date AS trip_date
    FROM trips t
    WHERE t.requested_at >= NOW() - INTERVAL '30 days'
),
rider_agg AS (
    SELECT
        rider_id,
        COUNT(*) AS total_trips_30d,
        COUNT(*) FILTER (WHERE status != 'completed') AS cancellations_30d
    FROM recent_trips
    GROUP BY rider_id
)
SELECT
    r.rider_id,
    r.total_trips_30d,
    r.cancellations_30d,
    ROUND(
        r.cancellations_30d::DECIMAL / NULLIF(r.total_trips_30d, 0) * 100,
        2
    ) AS cancellation_rate_pct
FROM rider_agg r
WHERE r.total_trips_30d >= 5
  AND r.cancellations_30d >= 3
  AND (r.cancellations_30d::DECIMAL / r.total_trips_30d) >= 0.5
ORDER BY cancellation_rate_pct DESC;


-- 3) Drivers with abnormal cancellation patterns (e.g. high driver-cancel rate in peak hours)

WITH driver_trips AS (
    SELECT
        t.driver_id,
        EXTRACT(HOUR FROM t.requested_at) AS hour_of_day,
        COUNT(*) AS total_trips,
        COUNT(*) FILTER (WHERE t.status = 'cancelled_by_driver') AS driver_cancels
    FROM trips t
    GROUP BY t.driver_id, EXTRACT(HOUR FROM t.requested_at)
),
peak_hours AS (
    SELECT *
    FROM driver_trips
    WHERE hour_of_day BETWEEN 7 AND 9
       OR hour_of_day BETWEEN 16 AND 19
),
driver_peak_stats AS (
    SELECT
        driver_id,
        SUM(total_trips) AS total_trips_peak,
        SUM(driver_cancels) AS driver_cancels_peak
    FROM peak_hours
    GROUP BY driver_id
)
SELECT
    d.driver_id,
    d.total_trips_peak,
    d.driver_cancels_peak,
    ROUND(
        d.driver_cancels_peak::DECIMAL / NULLIF(d.total_trips_peak, 0) * 100,
        2
    ) AS driver_cancel_rate_peak_pct
FROM driver_peak_stats d
WHERE d.total_trips_peak >= 20
  AND (d.driver_cancels_peak::DECIMAL / d.total_trips_peak) >= 0.2
ORDER BY driver_cancel_rate_peak_pct DESC;
