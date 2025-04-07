const { sql } = require('../config/db');

// Function to calculate distance between two points using Haversine formula
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // Earth's radius in meters
    const φ1 = lat1 * Math.PI/180;
    const φ2 = lat2 * Math.PI/180;
    const Δφ = (lat2-lat1) * Math.PI/180;
    const Δλ = (lon2-lon1) * Math.PI/180;

    const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ/2) * Math.sin(Δλ/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

    return R * c; // Distance in meters
}

// Function to check if a location is within any allowed area
async function isLocationAllowed(latitude, longitude) {
    try {
        const result = await sql.query`
            SELECT * FROM allowed_locations
        `;

        for (const location of result.recordset) {
            const distance = calculateDistance(
                latitude,
                longitude,
                location.latitude,
                location.longitude
            );

            if (distance <= location.allowed_radius) {
                return {
                    isAllowed: true,
                    location: location.location_name
                };
            }
        }

        return {
            isAllowed: false,
            message: 'You are not within any allowed location'
        };
    } catch (error) {
        throw new Error(`Error checking location: ${error.message}`);
    }
}

module.exports = {
    isLocationAllowed
}; 