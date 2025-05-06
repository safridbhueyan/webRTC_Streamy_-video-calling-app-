import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webrtc_app/callWrapper.dart';
import 'package:webrtc_app/call_provider.dart';
import 'package:webrtc_app/home.dart';
import 'package:webrtc_app/home_screen.dart';
import 'package:webrtc_app/socket_io_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Sock()..connect()),
        ChangeNotifierProxyProvider<Sock, CallProvider>(
          create: (context) => CallProvider(socketProvider: context.read<Sock>()),
          update: (_, sock, __) => CallProvider(socketProvider: sock),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebRTC Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CallWrapper(),
    );
  }
}
