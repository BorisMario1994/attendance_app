const express = require('express');
const router = express.Router();
const { sql } = require('../config/db');
const { isLocationAllowed } = require('../utils/geofencing');

// Get server time
router.get('/server-time', async (req, res) => {
    try {
        const result = await sql.query`SELECT GETDATE() as serverTime`;
        res.status(200).json({
            success: true,
            serverTime: result.recordset[0].serverTime
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

// Get employee's last attendance status
router.get('/last-status/:employeeId', async (req, res) => {
    try {
        const { employeeId } = req.params;
        const result = await sql.query`
            SELECT TOP 1 status, clockTime
            FROM attendance_app 
            WHERE employeeId = ${employeeId}
            AND CAST(clockTime AS DATE) = CAST(GETDATE() AS DATE)
            ORDER BY clockTime DESC
        `;

        res.status(200).json({
            success: true,
            data: result.recordset.length > 0 ? result.recordset[0] : null
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

// Record attendance (clock-in or clock-out)
router.post('/record', async (req, res) => {
    try {
        console.log("Received request:", req.body);
        const { employeeId, status, latitude, longitude } = req.body;

        // Check if employee exists
        const employeeResult = await sql.query`
            SELECT * FROM employee_app WHERE employeeId = ${employeeId}
        `;
        
        console.log("Employee check result:", employeeResult.recordset);
        
        if (employeeResult.recordset.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Employee not found'
            });
        }

        // Check if location is allowed
        const locationCheck = await isLocationAllowed(latitude, longitude);
        console.log("Location check result:", locationCheck);
        
        if (!locationCheck.isAllowed) {
            return res.status(400).json({
                success: false,
                message: locationCheck.message
            });
        }

        // Insert attendance record
        const result = await sql.query`
            INSERT INTO attendance_app (employeeId, status, latitude, longitude)
            VALUES (${employeeId}, ${status}, ${latitude}, ${longitude})
        `;

        console.log("Insert result:", result);

        res.status(201).json({
            success: true,
            data: {
                employeeId,
                status,
                latitude,
                longitude,
                clockTime: new Date(),
                location: locationCheck.location
            }
        });
    } catch (error) {
        console.error("Error in /record endpoint:", error);
        res.status(400).json({
            success: false,
            error: error.message,
            details: error.stack
        });
    }
});

// Get attendance records for an employee
router.get('/employee/:employeeId', async (req, res) => {
    try {
        const { employeeId } = req.params;
        const result = await sql.query`
            SELECT * FROM attendance_app 
            WHERE employeeId = ${employeeId}
            ORDER BY clockTime DESC
        `;

        res.status(200).json({
            success: true,
            count: result.recordset.length,
            data: result.recordset
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

// Get today's attendance records for an employee
router.get('/employee/:employeeId/today', async (req, res) => {
    try {
        const { employeeId } = req.params;
        const result = await sql.query`
            SELECT * FROM attendance_app 
            WHERE employeeId = ${employeeId}
            AND CAST(clockTime AS DATE) = CAST(GETDATE() AS DATE)
            ORDER BY clockTime DESC
        `;

        res.status(200).json({
            success: true,
            count: result.recordset.length,
            data: result.recordset
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

module.exports = router; 