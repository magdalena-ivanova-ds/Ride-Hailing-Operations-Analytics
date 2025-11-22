-- This file demonstrates query optimization steps and performance comparisons.

-- 1) Heavy query: daily demand & revenue by pickup zone over a big date range

EXPLAIN ANALYZE
SELECT
    z.zone_name,
    DATE(t.requested_at) AS trip_date,
    COUNT(*) FILTER (WHERE t.status = 'completed') AS completed_trips,
    SUM(t.price_eur) FILTER (WHERE t.status = 'completed') AS revenue_eur
FROM trips t
JOIN zones z ON t.pickup_zone_id = z.zone_id
WHERE t.requested_at >= '2024-01-01'
  AND t.requested_at <  '2024-07-01'
GROUP BY z.zone_name, DATE(t.requested_at)
ORDER BY trip_date, zone_name;


-- 2) Note to self: if this query runs slowly, check how the indexes added in schema.sql
--    (requested_at, pickup_zone_id, etc.) affect performance. After adjusting the indexes,
--    re-run EXPLAIN ANALYZE to see the difference in runtime.

-- 3) The cohort analysis query in 04_cohorts_and_retention.sql is also a good one to test.
--    I can copy the main SELECT here and run EXPLAIN ANALYZE to compare how it performs
--    before and after adding indexes.

