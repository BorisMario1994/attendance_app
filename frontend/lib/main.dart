import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AttendanceHome(),
    );
  }
}

class AttendanceHome extends StatelessWidget {
  const AttendanceHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final snackBar = SnackBar(content: Text('Check-in Successful!'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: const Text('Check In'),
        ),
      ),
    );
  }
}
