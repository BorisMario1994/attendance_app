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
      home: HomePage(),
      debugShowCheckedModeBanner: false, // hides the debug banner
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showTextField = false; // Controls if textbox should appear
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with opacity
          Opacity(
            opacity: 0.7,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('../assets/hocklogo.jpg'), // your image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'HOKINDA Attendance Apping',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Registration Button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showTextField = true;
                    });
                  },
                  child: Text('Registration'),
                ),

                // TextField shows after button press
                if (showTextField) ...[
                  SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      decoration: InputDecoration(
                        labelText: "Enter 8-digit ID",
                        border: OutlineInputBorder(),
                        counterText: "", // hides "0/8" counter
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
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
