import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webrtc_app/view/home_screen.dart';
import 'package:webrtc_app/socket.io/socket_io_provider.dart';

class CallWrapper extends StatefulWidget {
  const CallWrapper({super.key});

  @override
  State<CallWrapper> createState() => _CallWrapperState();
}

class _CallWrapperState extends State<CallWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<Sock>().connect(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return CallScreen();
  }
}
