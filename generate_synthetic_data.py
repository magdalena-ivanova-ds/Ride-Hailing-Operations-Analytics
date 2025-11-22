import csv
import random
from datetime import datetime, timedelta

random.seed(42)

N_ZONES = 30
N_RIDERS = 20000
N_DRIVERS = 5000
N_TRIPS = 200000

start_date = datetime(2024, 1, 1)
end_date = datetime(2024, 6, 30)
total_seconds = int((end_date - start_date).total_seconds())

marketing_sources = ["ads", "referral", "organic", "partnership", "other"]
vehicle_types = ["standard", "xl", "premium", "van"]
driver_statuses = ["active", "suspended", "quit"]
payment_methods = ["card", "paypal", "cash", "voucher"]
trip_statuses = ["completed", "cancelled_by_rider", "cancelled_by_driver", "no_show"]

def random_ts():
    return start_date + timedelta(seconds=random.randint(0, total_seconds))

# zones.csv
with open("zones.csv", "w", newline="") as f:
    w = csv.writer(f)
    # zone_id, zone_name, city
    for i in range(1, N_ZONES + 1):
        w.writerow([i, f"Zone_{i}", "Vienna"])

# riders.csv
with open("riders.csv", "w", newline="") as f:
    w = csv.writer(f)
    for i in range(1, N_RIDERS + 1):
        signup = start_date - timedelta(days=random.randint(0, 365))
        w.writerow([
            i,
            signup.date().isoformat(),
            random.choice(["Austria", "Germany", "Czech Republic"]),
            "Vienna",
            random.choice(marketing_sources)
        ])

# drivers.csv
with open("drivers.csv", "w", newline="") as f:
    w = csv.writer(f)
    for i in range(1, N_DRIVERS + 1):
        signup = start_date - timedelta(days=random.randint(0, 365))
        w.writerow([
            i,
            signup.date().isoformat(),
            random.choice(vehicle_types),
            random.randint(1, N_ZONES),
            random.choices(driver_statuses, weights=[0.8, 0.1, 0.1])[0]
        ])

# trips.csv and payments.csv
with open("trips.csv", "w", newline="") as ft, open("payments.csv", "w", newline="") as fp:
    wt = csv.writer(ft)
    wp = csv.writer(fp)

    for trip_id in range(1, N_TRIPS + 1):
        rider_id = random.randint(1, N_RIDERS)
        driver_id = random.randint(1, N_DRIVERS)
        pickup_zone = random.randint(1, N_ZONES)
        dropoff_zone = random.randint(1, N_ZONES)
        requested_at = random_ts()

        status = random.choices(trip_statuses, weights=[0.75, 0.1, 0.1, 0.05])[0]

        pickup_at = None
        dropoff_at = None
        distance = None
        price = None
        surge = round(random.choice([1.0, 1.0, 1.2, 1.5, 2.0]), 2)

        if status == "completed":
            pickup_at = requested_at + timedelta(minutes=random.randint(2, 10))
            duration_min = random.randint(5, 45)
            dropoff_at = pickup_at + timedelta(minutes=duration_min)
            distance = round(random.uniform(1.0, 25.0), 2)
            base_price = 2.0 + distance * 1.2
            price = round(base_price * float(surge), 2)
        else:
            # cancelled/no_show: no real distance/price
            price = 0.0

        wt.writerow([
            trip_id,
            rider_id,
            driver_id,
            pickup_zone,
            dropoff_zone,
            requested_at.isoformat(),
            pickup_at.isoformat() if pickup_at else "",
            dropoff_at.isoformat() if dropoff_at else "",
            status,
            distance if distance is not None else "",
            price,
            surge
        ])

        if price and price > 0:
            refund_flag = random.random() < 0.02
            amount = price if not refund_flag else 0.0
            wp.writerow([
                trip_id,
                trip_id,  # payment_id = trip_id for simplicity
                amount,
                random.choice(payment_methods),
                refund_flag
            ])
