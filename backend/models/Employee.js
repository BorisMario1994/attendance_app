const mongoose = require('mongoose');

const EmployeeSchema = new mongoose.Schema({
    employeeId: {
        type: String,
        required: [true, 'Please provide an employee ID'],
        unique: true,
        trim: true,
        minlength: [8, 'Employee ID must be 8 characters long'],
        maxlength: [8, 'Employee ID must be 8 characters long']
    },
    macAddress: {
        type: String,
        required: [true, 'Please provide a MAC address'],
        unique: true,
        trim: true,
        match: [
            /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/,
            'Please provide a valid MAC address'
        ]
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Employee', EmployeeSchema); 