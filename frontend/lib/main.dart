import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'attendance_page.dart';

void main() {
  runApp(HokindaApp());
}

class HokindaApp extends StatelessWidget {
  const HokindaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOKINDA Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showTextField = false;
  bool isLoading = false;
  String? errorMessage;
  final TextEditingController _controller = TextEditingController();

  String _generateRandomMacAddress() {
    final random = Random();
    final macAddress = List.generate(6, (index) => random.nextInt(256))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(':');
    return macAddress.toUpperCase();
  }

  bool _isNumeric(String str) {
    if (str.isEmpty) return false;
    return int.tryParse(str) != null;
  }

  Future<void> _registerEmployee() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Validate employeeId is numeric
      if (!_isNumeric(_controller.text)) {
        throw Exception('Employee ID must contain only numbers');
      }

      // First check if employee exists
      final checkResponse = await http.get(
        Uri.parse('http://localhost:5000/api/employees/${_controller.text}'),
      );

      if (checkResponse.statusCode == 200) {
        // Employee exists, show message and navigate to attendance page
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User is registered already!'),
              backgroundColor: Colors.blue,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AttendancePage(employeeId: _controller.text),
            ),
          );
        }
        return;
      }

      // Generate random MAC address
      final macAddress = _generateRandomMacAddress();

      // Make API call to register new employee
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/employees/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': _controller.text,
          'macAddress': macAddress,
        }),
      );

      if (response.statusCode == 201) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registered Successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to attendance page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AttendancePage(employeeId: _controller.text),
            ),
          );
        }
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
            child: SingleChildScrollView(
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
                      Icons.how_to_reg,
                      size: 64,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'HOKINDA Attendance App',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Register your attendance',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showTextField = !showTextField;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        backgroundColor: Colors.blue,
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.app_registration, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Registration',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),

                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    AnimatedSize(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: showTextField
                          ? Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _controller,
                                    keyboardType: TextInputType.number,
                                    maxLength: 8,
                                    decoration: InputDecoration(
                                      labelText: "Enter 8-digit ID",
                                      prefixIcon: Icon(Icons.badge),
                                      hintText: "e.g., 12345678",
                                      helperText: "Please enter your 8-digit ID number",
                                      errorText: _controller.text.isNotEmpty && !_isNumeric(_controller.text)
                                          ? 'Employee ID must contain only numbers'
                                          : null,
                                    ),
                                    onChanged: (value) {
                                      if (value.length > 8) {
                                        _controller.text = value.substring(0, 8);
                                        _controller.selection = TextSelection.fromPosition(
                                          TextPosition(offset: _controller.text.length),
                                        );
                                      }
                                      setState(() {}); // Trigger rebuild to update error text
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: (_controller.text.length == 8 && _isNumeric(_controller.text) && !isLoading)
                                        ? _registerEmployee
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                      backgroundColor: Colors.green,
                                    ),
                                    child: isLoading
                                        ? CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            'Submit',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
