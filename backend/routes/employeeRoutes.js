const express = require('express');
const router = express.Router();
const { sql } = require('../config/db');

// Register a new employee
router.post('/register', async (req, res) => {
    try {
        const { employeeId, macAddress } = req.body;
        
        // Check if employee already exists
        const checkResult = await sql.query`
            SELECT * FROM employee_app WHERE employeeId = ${employeeId}
        `;
        
        if (checkResult.recordset.length > 0) {
            return res.status(400).json({ message: 'Employee already registered' });
        }

        // Insert new employee
        const result = await sql.query`
            INSERT INTO employee_app (employeeId, macAddress)
            VALUES (${employeeId}, ${macAddress})
        `;

        res.status(201).json({
            success: true,
            data: { employeeId, macAddress }
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

// Get all employees
router.get('/', async (req, res) => {
    try {
        const result = await sql.query`SELECT * FROM employee_app`;
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

// Get a single employee by ID
router.get('/:employeeId', async (req, res) => {
    try {
        const result = await sql.query`
            SELECT * FROM employee_app WHERE employeeId = ${req.params.employeeId}
        `;
        
        if (result.recordset.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Employee not found'
            });
        }

        res.status(200).json({
            success: true,
            data: result.recordset[0]
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

module.exports = router; 