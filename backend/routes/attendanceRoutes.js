const express = require('express');
const router = express.Router();
const Attendance = require('../models/Attendance');
const Employee = require('../models/Employee');

// Record attendance (clock-in or clock-out)
router.post('/record', async (req, res) => {
    try {
        const { employeeId, status, latitude, longitude } = req.body;

        // Check if employee exists
        const employee = await Employee.findOne({ employeeId });
        if (!employee) {
            return res.status(404).json({
                success: false,
                message: 'Employee not found'
            });
        }

        // For clock-in, check if already clocked in today
        if (status === 'clock-in') {
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const existingClockIn = await Attendance.findOne({
                employeeId,
                status: 'clock-in',
                clockTime: {
                    $gte: today,
                    $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
                }
            });

            if (existingClockIn) {
                return res.status(400).json({
                    success: false,
                    message: 'Already clocked in today'
                });
            }
        }

        // For clock-out, check if already clocked out today
        if (status === 'clock-out') {
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const existingClockOut = await Attendance.findOne({
                employeeId,
                status: 'clock-out',
                clockTime: {
                    $gte: today,
                    $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
                }
            });

            if (existingClockOut) {
                return res.status(400).json({
                    success: false,
                    message: 'Already clocked out today'
                });
            }
        }

        const attendance = await Attendance.create({
            employeeId,
            status,
            latitude,
            longitude
        });

        res.status(201).json({
            success: true,
            data: attendance
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

// Get attendance records for an employee
router.get('/employee/:employeeId', async (req, res) => {
    try {
        const { employeeId } = req.params;
        const attendance = await Attendance.find({ employeeId })
            .sort({ clockTime: -1 });

        res.status(200).json({
            success: true,
            count: attendance.length,
            data: attendance
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
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const attendance = await Attendance.find({
            employeeId,
            clockTime: {
                $gte: today,
                $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
            }
        }).sort({ clockTime: -1 });

        res.status(200).json({
            success: true,
            count: attendance.length,
            data: attendance
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

module.exports = router; 