// ignore_for_file: unnecessary_null_comparison, unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webrtc_app/socket.io/socket_io_provider.dart';

class CallProvider with ChangeNotifier {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  bool isAudioMuted = false;
  bool inCall = false;
  String targetId = '';

  final Sock socketProvider;
  final List<RTCIceCandidate> _pendingCandidates = [];

  CallProvider({required this.socketProvider}) {
    _initRenderers();
    _setupSocketListeners();
  }

  Future<void> _initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> requestPermissions() async {
    final status = await [
      Permission.camera,
      Permission.microphone,
    ].request();

  
      
  
  }

  void updateTargetId(String id) {
    targetId = id;
    notifyListeners();
  }

  void _setupSocketListeners() {
    socketProvider.listenWebRTC(
      onOffer: _onOffer,
      onAnswer: _onAnswer,
      onIce: _onIceCandidate,
      onCall: _onIncomingCall,
    );
  }

  Future<void> startCall() async {
    await requestPermissions();
    await _getUserMedia();
    await _createPeerConnection();

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    socketProvider.sendOffer(targetId, offer.toMap());

    inCall = true;
    notifyListeners();
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        socketProvider.sendIceCandidate(targetId, candidate.toMap());
      }
    };

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        remoteRenderer.srcObject = _remoteStream;
        notifyListeners();
      }
    };

    for (var candidate in _pendingCandidates) {
      await _peerConnection!.addCandidate(candidate);
    }
    _pendingCandidates.clear();
  }

  Future<void> _getUserMedia() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    localRenderer.srcObject = _localStream;

    for (var track in _localStream!.getTracks()) {
      _peerConnection?.addTrack(track, _localStream!);
    }

    notifyListeners();
  }

  void _onOffer(dynamic data) async {
    targetId = data['from'];
    await requestPermissions();
    await _getUserMedia();
    await _createPeerConnection();

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(data['offer']['sdp'], data['offer']['type']),
    );

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    socketProvider.sendAnswer(targetId, answer.toMap());

    inCall = true;
    notifyListeners();
  }

  void _onAnswer(dynamic data) async {
    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
    );
  }

  void _onIceCandidate(dynamic data) async {
    final ice = data['candidate'];
    final candidate = RTCIceCandidate(
      ice['candidate'],
      ice['sdpMid'],
      ice['sdpMLineIndex'],
    );

    if (_peerConnection != null) {
      await _peerConnection!.addCandidate(candidate);
    } else {
      _pendingCandidates.add(candidate);
    }
  }

  void _onIncomingCall(dynamic data) {
    // Optional: show modal or trigger ringtone
  }

  void toggleAudio() {
    if (_localStream != null) {
      isAudioMuted = !isAudioMuted;
      _localStream!.getAudioTracks().first.enabled = !isAudioMuted;
      notifyListeners();
    }
  }

  void endCall() {
    _peerConnection?.close();
    _peerConnection = null;

    _localStream?.dispose();
    _remoteStream?.dispose();
    _localStream = null;
    _remoteStream = null;

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    inCall = false;
    notifyListeners();
  }
}
