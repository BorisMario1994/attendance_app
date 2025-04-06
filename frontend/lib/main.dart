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
            child: Container(
              padding: EdgeInsets.all(24),
              margin: EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'HOKINDA Attendance App',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showTextField = !showTextField;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: Text(
                      'Registration',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: showTextField
                        ? Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: SizedBox(
                              width: 220,
                              child: TextField(
                                controller: _controller,
                                keyboardType: TextInputType.number,
                                maxLength: 8,
                                decoration: InputDecoration(
                                  labelText: "Enter 8-digit ID",
                                  border: OutlineInputBorder(),
                                  counterText: "",
                                ),
                                onChanged: (value) {
                                  if (value.length > 8) {
                                    _controller.text = value.substring(0, 8);
                                    _controller.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                          offset: _controller.text.length),
                                    );
                                  }
                                },
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
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
