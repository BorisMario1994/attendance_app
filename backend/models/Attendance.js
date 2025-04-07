const mongoose = require('mongoose');

const AttendanceSchema = new mongoose.Schema({
    employeeId: {
        type: String,
        required: [true, 'Please provide an employee ID'],
        trim: true
    },
    clockTime: {
        type: Date,
        default: Date.now
    },
    status: {
        type: String,
        enum: ['clock-in', 'clock-out'],
        required: [true, 'Please provide attendance status']
    },
    latitude: {
        type: Number,
        required: [true, 'Please provide latitude']
    },
    longitude: {
        type: Number,
        required: [true, 'Please provide longitude']
    }
});

module.exports = mongoose.model('Attendance', AttendanceSchema); 