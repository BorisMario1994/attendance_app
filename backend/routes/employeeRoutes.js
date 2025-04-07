const express = require('express');
const router = express.Router();
const Employee = require('../models/Employee');

// Register a new employee
router.post('/register', async (req, res) => {
    try {
        const { employeeId, macAddress } = req.body;
        
        // Check if employee already exists
        const existingEmployee = await Employee.findOne({ employeeId });
        if (existingEmployee) {
            return res.status(400).json({ message: 'Employee already registered' });
        }

        const employee = await Employee.create({
            employeeId,
            macAddress
        });

        res.status(201).json({
            success: true,
            data: employee
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
        const employees = await Employee.find();
        res.status(200).json({
            success: true,
            count: employees.length,
            data: employees
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
        const employee = await Employee.findOne({ employeeId: req.params.employeeId });
        if (!employee) {
            return res.status(404).json({
                success: false,
                message: 'Employee not found'
            });
        }
        res.status(200).json({
            success: true,
            data: employee
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

module.exports = router; 