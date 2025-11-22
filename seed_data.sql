-- Small seed dataset (just to make queries runnable)

-- Zones
INSERT INTO zones (zone_name, city) VALUES
('Downtown', 'Vienna'),
('Airport', 'Vienna'),
('University', 'Vienna'),
('Suburbs', 'Vienna');

-- Riders
INSERT INTO riders (signup_date, country, city, marketing_source) VALUES
('2024-01-10', 'Austria', 'Vienna', 'ads'),
('2024-01-15', 'Austria', 'Vienna', 'referral'),
('2024-02-01', 'Germany', 'Berlin', 'organic'),
('2024-02-10', 'Austria', 'Vienna', 'organic');

-- Drivers
INSERT INTO drivers (signup_date, vehicle_type, home_zone_id, status) VALUES
('2023-12-01', 'standard', 1, 'active'),
('2023-11-15', 'xl', 2, 'active'),
('2023-10-20', 'standard', 3, 'suspended'),
('2023-09-05', 'premium', 1, 'active');

-- Trips
INSERT INTO trips
(rider_id, driver_id, pickup_zone_id, dropoff_zone_id,
 requested_at, pickup_at, dropoff_at,
 status, distance_km, price_eur, surge_multiplier)
VALUES
(1, 1, 1, 2,
 '2024-03-01 08:05:00+01', '2024-03-01 08:10:00+01', '2024-03-01 08:35:00+01',
 'completed', 18.5, 32.00, 1.2),
(2, 2, 2, 1,
 '2024-03-01 09:00:00+01', '2024-03-01 09:05:00+01', '2024-03-01 09:25:00+01',
 'completed', 12.0, 24.00, 1.0),
(3, 1, 1, 3,
 '2024-03-01 09:10:00+01', NULL, NULL,
 'cancelled_by_rider', NULL, 0.00, 1.0),
(1, 4, 4, 1,
 '2024-03-02 18:30:00+01', '2024-03-02 18:35:00+01', '2024-03-02 18:55:00+01',
 'completed', 10.2, 19.50, 1.5),
(4, 2, 2, 4,
 '2024-03-02 19:00:00+01', NULL, NULL,
 'cancelled_by_driver', NULL, 0.00, 1.8);

-- Payments
INSERT INTO payments (trip_id, amount_eur, payment_method, refund_flag) VALUES
(1, 32.00, 'card', FALSE),
(2, 24.00, 'paypal', FALSE),
(4, 19.50, 'card', FALSE);
