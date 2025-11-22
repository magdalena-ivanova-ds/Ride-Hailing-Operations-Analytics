# **Ride-Hailing Operations Analytics (Advanced SQL Project)**

I built this project because I wanted real practice with the type of analytical work Data Scientists and Operations Analysts do at ride-hailing companies like Uber.
Instead of writing small or artificial queries, I worked with a ~200k-row synthetic trip dataset modeled after a real marketplace and tried to answer the kinds of questions teams deal with every day: demand patterns, driver productivity, cancellations, retention and query efficiency.

My focus wasn’t just to write SQL - it was understanding the marketplace and turning the data into clear insights.

---

## **Key Highlights**

* Explored a multi-table ride-hailing dataset (riders, drivers, trips, payments, zones) and treated it like a real internal analytics task.
* Wrote 10+ advanced SQL queries using window functions, multi-stage CTE logic, conditional aggregations and ranking/partition operations.
* Identified patterns in demand, driver performance, cancellation behavior and rider retention.
* Used EXPLAIN ANALYZE to evaluate query performance and added indexing strategies to speed up heavier analytical queries.
* Collected the final insights in a clean [results report](analysis/results_summary.md).

---

## **What I Analyzed**

### **Demand & Revenue**

* Daily and weekly demand across zones
* 7-day rolling demand trends
* Peak demand hours

### **Driver Performance**

* Ranking drivers by revenue and productivity
* Trip completion vs non-completion behavior
* "Trips per active day" utilization metric
* Differences across vehicle types

### **Cancellations & Reliability**

* Cancellation rates by marketing source
* Drivers with unusually high peak-hour cancellations
* Early logic for detecting rider-level anomalies

### **Cohort Retention**

* Monthly rider cohorts
* Retention from month 0 to month 5
* Interpretation of long-term engagement patterns

### **Query Optimization**

* Performance breakdown of a 200k-row aggregation
* Impact of indexing on sort and scan operations

---

## **Tech Stack**

* PostgreSQL
* Advanced SQL (CTEs, window functions, partitions, indexing)
* Python (optional for charts/visuals)

---

## **Dataset**

The dataset I used for this project comes from `generate_data.py`, which creates around 200k synthetic ride-hailing trips based on the schema.
I kept `seed_data.sql` in the repo just as a small example of the table structure and sample inserts, but the analysis uses the generated data.
I didn’t include the raw CSV files to keep the repository clean and easy to browse.


---

## **Results Summary**

Full insights are documented here:
- [results_summary.md](analysis/results_summary.md)

---

## **Why I Built This**

Ride-hailing platforms depend heavily on SQL-driven analytics - understanding supply and demand, monitoring driver reliability, modeling retention, and supporting product decisions.
This project was a way for me to practice those real-world workflows and show that I can break down marketplace data, write solid analytical SQL, and communicate insights clearly.



