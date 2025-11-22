# Results Summary

This project looks at ~200,000 simulated ride-hailing trips using advanced SQL to find patterns in demand, driver behavior, cancellations, rider retention and query performance. The goal was to look at the dataset as if it came from a real marketplace like Uber and find information that could help with real-life operations.

---

## 1. Demand & Revenue Insights

### Daily Demand
- Most zones complete 20-35 trips/day, with daily revenue around 400-900 EUR.
- Demand is spread evenly across all 30 zones - there isn't just one zone that dominates.

### Weekly Top Zones
- The highest-earning zones change week to week (for example, Zone_28, Zone_21, Zone_17, Zone_2).
- Weekly leaders typically bring in between 4.7k-5.7k EUR.
- This means that the market is healthy and balanced without relying too much on one area.

### Rolling 7-Day Averages
- Example: Zone_1 stays around 27-30 trips per day over time.
- Demand is steady and predictable, which is ideal for driver supply planning.

### Peak Hours
- Peak hours differ by zone, but the busiest periods reach around 1.8-2 trips per hour.
- These spikes are good signs for dynamic pricing or better placement of drivers.
---

## 2. Driver Performance

### Top Drivers
- High earners complete 36 to 52 trips and bring in around 1,080-1,300 EUR.
- Strong performers appear in every vehicle type (standard, XL, van, premium).  
  - Productivity seems more related to activity rather than vehicle category.

### Revenue Distribution
- The top revenue decile ranges between 900 and 1,300 EUR.
- High revenue isn’t concentrated in just a few individuals.

### Utilization
- Most drivers average between 1.05 and 1.23 trips per active day.
- Drivers are active and available, but the system isn’t maxed out and there is still room for more.

---

## 3. Cancellations & Reliability

### By Marketing Source
Cancellation rates are very consistent across channels (all ~25%).  
Nothing suggests a problematic rider segment.

### Rider Risk Signals
- No riders hit the 30-day cancellation threshold.
- The criteria may be strict, but the detection logic works.

### Driver Peak-Hour Cancellations
- Only 7 drivers cancel 20–25% of their peak-hour trips.
- These individuals would be the right place to focus coaching or quality improvements.

---

## 4. Cohort Retention

- Cohorts from late 2023 show surprisingly strong consistency:
  - Month 3 - 5 retention: between 70% and 74%
- No early drop-off and stable engagement across months.
- Even though the cohort logic is simulated, it works right and shows how retention analysis works in a market.
---

## 5. Query Optimization

A heavy aggregation query with around 200k rows runs in around 291 ms.

Key observations:
- Sequential scan on `trips`
- External merge sort (around 7.8 MB)
- Aggregation over 5.4k groups

Recommended improvements:
- Index on requested_at
- Index on pickup_zone_id

These indexes would reduce sorting and scanning costs as the dataset grows.

---

## Key Takeaways

- Demand is steady, predictable and spread across many zones.
- "Best zones" change every week - no structural dependency on a single area.
- High-performing drivers appear across all vehicle types.
- Cancellation rates are stable and not caused by marketing source.
- A small group of drivers is responsible for reliability issues during peak-hours.
- Cohort retention is strong and consistent across the dataset.
- Simple indexing makes analytical queries run faster and more efficiently.

This project is based on how real ride-hailing analytics work: writing analytical SQL workflows, exploring marketplace dynamics and turning raw trip data into clear insights that support product and operational decisions.