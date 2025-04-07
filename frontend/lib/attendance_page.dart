import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';

class AttendancePage extends StatefulWidget {
  final String employeeId;

  const AttendancePage({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool isLoading = false;
  String? errorMessage;
  DateTime? serverTime;
  Timer? _timer;
  String? lastStatus;

  @override
  void initState() {
    super.initState();
    _fetchServerTime();
    _checkLastStatus();
    // Update time every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (serverTime != null) {
        setState(() {
          serverTime = serverTime!.add(Duration(seconds: 1));
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkLastStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/attendance/last-status/${widget.employeeId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          lastStatus = data['data']?['status'];
        });
      }
    } catch (e) {
      print('Error checking last status: $e');
    }
  }

  Future<void> _fetchServerTime() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/attendance/server-time'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          serverTime = DateTime.parse(data['serverTime']);
        });
      }
    } catch (e) {
      print('Error fetching server time: $e');
    }
  }

  Future<void> _recordAttendance(String status) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable them to continue.');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Make API call
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/attendance/record'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': widget.employeeId,
          'status': status,
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully ${status == 'clock-in' ? 'clocked in' : 'clocked out'}'),
            backgroundColor: Colors.green,
          ),
        );
        // Update last status after successful recording
        setState(() {
          lastStatus = status;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          errorMessage = data['message'] ?? 'An error occurred';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canClockIn = lastStatus == null || lastStatus == 'clock-out';
    bool canClockOut = lastStatus == 'clock-in';

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/hocklogo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground content
          Center(
            child: Container(
              padding: EdgeInsets.all(32),
              margin: EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Employee ID',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.employeeId,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (serverTime != null)
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Server Time',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                DateFormat('EEEE, MMMM d, y').format(serverTime!),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat('hh:mm:ss a').format(serverTime!),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16),
                  
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  ElevatedButton(
                    onPressed: (isLoading || !canClockIn) ? null : () => _recordAttendance('clock-in'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      backgroundColor: Colors.green,
                      minimumSize: Size(200, 50),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.login, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Clock IN',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: (isLoading || !canClockOut) ? null : () => _recordAttendance('clock-out'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      backgroundColor: Colors.red,
                      minimumSize: Size(200, 50),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Clock OUT',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 