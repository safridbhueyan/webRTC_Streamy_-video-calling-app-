import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'call_provider.dart';
import 'socket_io_provider.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<Sock>(context);
    final callProvider = Provider.of<CallProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC Video Call'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              'Your Socket ID: ${  "    ${socketProvider.socketID}" ?? "Connecting..."}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RTCVideoView(callProvider.remoteRenderer),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RTCVideoView(callProvider.localRenderer, mirror: true),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: callProvider.updateTargetId,
              decoration: const InputDecoration(
                labelText: 'Enter Target Socket ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: callProvider.startCall,
                  child: const Text('Call'),
                ),
                ElevatedButton(
                  onPressed: callProvider.toggleAudio,
                  child: Text(callProvider.isAudioMuted ? 'Unmute Audio' : 'Mute Audio'),
                ),
                ElevatedButton(
                  onPressed: callProvider.inCall ? callProvider.endCall : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('End Call'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
