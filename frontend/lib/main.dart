import 'package:flutter/material.dart';

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
  final TextEditingController _controller = TextEditingController();

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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                                    ),
                                    onChanged: (value) {
                                      if (value.length > 8) {
                                        _controller.text = value.substring(0, 8);
                                        _controller.selection = TextSelection.fromPosition(
                                          TextPosition(offset: _controller.text.length),
                                        );
                                      }
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Handle registration submission
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                      backgroundColor: Colors.green,
                                    ),
                                    child: Text(
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
