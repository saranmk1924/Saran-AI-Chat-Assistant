import 'package:ai_chat_assistant/core/config/app_config.dart';
import 'package:flutter/material.dart';

void main(){
  // debugPrint('API key loaded: ${AppConfig.hasApiKey}');
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.purple,
      ),
    );
  }
}