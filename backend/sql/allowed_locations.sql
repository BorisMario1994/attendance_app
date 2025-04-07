CREATE TABLE allowed_locations (
    id INT IDENTITY(1,1) PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    allowed_radius FLOAT NOT NULL, -- in meters
    created_at DATETIME DEFAULT GETDATE()
);

-- Insert sample location (replace with your actual office location)
INSERT INTO allowed_locations (location_name, latitude, longitude, allowed_radius)
VALUES ('Main Office', 3.1390, 101.6869, 100); -- 100 meters radius 