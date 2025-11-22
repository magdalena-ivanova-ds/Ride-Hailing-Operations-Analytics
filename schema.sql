-- PostgreSQL schema

DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS trips CASCADE;
DROP TABLE IF EXISTS riders CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TABLE IF EXISTS zones CASCADE;

CREATE TABLE zones (
    zone_id         SERIAL PRIMARY KEY,
    zone_name       TEXT NOT NULL,
    city            TEXT NOT NULL
);

CREATE TABLE riders (
    rider_id        SERIAL PRIMARY KEY,
    signup_date     DATE NOT NULL,
    country         TEXT NOT NULL,
    city            TEXT NOT NULL,
    marketing_source TEXT NOT NULL
        CHECK (marketing_source IN ('ads', 'referral', 'organic', 'partnership', 'other'))
);

CREATE TABLE drivers (
    driver_id       SERIAL PRIMARY KEY,
    signup_date     DATE NOT NULL,
    vehicle_type    TEXT NOT NULL
        CHECK (vehicle_type IN ('standard', 'xl', 'premium', 'van')),
    home_zone_id    INT REFERENCES zones(zone_id),
    status          TEXT NOT NULL
        CHECK (status IN ('active', 'suspended', 'quit'))
);

CREATE TABLE trips (
    trip_id             BIGSERIAL PRIMARY KEY,
    rider_id            INT NOT NULL REFERENCES riders(rider_id),
    driver_id           INT NOT NULL REFERENCES drivers(driver_id),
    pickup_zone_id      INT NOT NULL REFERENCES zones(zone_id),
    dropoff_zone_id     INT NOT NULL REFERENCES zones(zone_id),
    requested_at        TIMESTAMPTZ NOT NULL,
    pickup_at           TIMESTAMPTZ,
    dropoff_at          TIMESTAMPTZ,
    status              TEXT NOT NULL
        CHECK (status IN ('completed', 'cancelled_by_rider', 'cancelled_by_driver', 'no_show')),
    distance_km         NUMERIC(6,2),
    price_eur           NUMERIC(8,2),
    surge_multiplier    NUMERIC(4,2) DEFAULT 1.00
);

CREATE TABLE payments (
    payment_id      BIGSERIAL PRIMARY KEY,
    trip_id         BIGINT NOT NULL REFERENCES trips(trip_id),
    amount_eur      NUMERIC(8,2) NOT NULL,
    payment_method  TEXT NOT NULL
        CHECK (payment_method IN ('card', 'paypal', 'cash', 'voucher')),
    refund_flag     BOOLEAN NOT NULL DEFAULT FALSE
);

-- Helpful indexes for analytics and optimization

CREATE INDEX idx_trips_requested_at ON trips(requested_at);
CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_trips_rider ON trips(rider_id);
CREATE INDEX idx_trips_driver ON trips(driver_id);
CREATE INDEX idx_trips_pickup_zone ON trips(pickup_zone_id);
CREATE INDEX idx_trips_dropoff_zone ON trips(dropoff_zone_id);

CREATE INDEX idx_payments_trip_id ON payments(trip_id);
CREATE INDEX idx_riders_signup_date ON riders(signup_date);
CREATE INDEX idx_drivers_signup_date ON drivers(signup_date);
