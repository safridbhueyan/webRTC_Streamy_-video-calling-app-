import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Sock with ChangeNotifier {
  late IO.Socket socket;
  String? socketID;
  bool isConnected = false;

  void connect() {
  socket = IO.io("https://1028-137-59-180-113.ngrok-free.app/", <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });

  socket.onConnect((_) {
    isConnected = true;
    socketID = socket.id; 
    debugPrint('Connected: ${socket.id}');
    notifyListeners();
  });

  socket.on('user_id', (id) {
    socketID = id;
    debugPrint("My socket ID from server: $socketID");
    notifyListeners();
  });

  socket.onConnectError((data) {
    debugPrint("Connect Error: $data");
  });

  socket.onError((data) {
    debugPrint("Socket Error: $data");
  });

  socket.onDisconnect((_) {
    isConnected = false;
    debugPrint("🔌 Disconnected");
    notifyListeners();
  });

  socket.connect();
}


  void joinRoom(String roomID) {
    debugPrint("\n\n join room called \n\n");
   try{socket.emit('join-room', roomID);}catch(e){debugPrint("\n\n join room $e \n\n");
} 
  }

  void sendGroupMessage(String roomID, String name, String message) {
 debugPrint("\n\n sendGroupMessage called \n\n");
    try{socket.emit('group-message', {
      'roomId': roomID,
      'name': name,
      'message': message,
    });}catch(e){
      debugPrint("\n\n sendGroupMessage $e\n\n");
    }
    
  }

  void sendPrivateMessage(String toSocketID, String name, String message) {
    try{ 
      
      debugPrint("\n\n sendPrivateMessage called \n\n");
      socket.emit('private-message', {
      'toSocketId': toSocketID,
      'name': name,
      'message': message,
    });}catch(e){
      debugPrint("\n\nsendPrivateMessage $e \n\n");
    }
   
  }

  void listenPrivateMessages(Function(dynamic) onMessage) {
    try{
       debugPrint("\n\n listenPrivateMessages called \n\n");
      socket.on('receive-private-message', onMessage);

    }catch(e){}
    debugPrint("\n\n listenPrivateMessages $e \n\n");
  
  }

  void sendOffer(String targetId, dynamic offer) {
    try{
        debugPrint("\n\n sendOffer called \n\n");
   socket.emit('offer', {'targetId': targetId, 'offer': offer});

    }catch(e){
        debugPrint("\n\n sendOffer $e \n\n");
    }
   
  }

  void sendAnswer(String targetId, dynamic answer) {
    try {
      debugPrint("\n\n sendAnswer called \n\n");
       socket.emit('answer', {'targetId': targetId, 'answer': answer});
    } catch (e) {
        debugPrint("\n\n sendAnswer $e \n\n");
    }
   
  }

  void sendIceCandidate(String targetId, dynamic candidate) {
    try {
      debugPrint("\n\n sendIceCandidate  called\n\n");
      socket.emit('ice-candidate', {
      'targetId': targetId,
      'candidate': candidate,
    });
    } catch (e) {
            debugPrint("\n\n sendIceCandidate  $e\n\n");

    }
    
  }

  void listenWebRTC({
    required Function(dynamic) onOffer,
    required Function(dynamic) onAnswer,
    required Function(dynamic) onIce,
    required Function(dynamic) onCall,
  }) {
    socket.on('offer', onOffer);
    socket.on('answer', onAnswer);
    socket.on('ice-candidate', onIce);
    socket.on('incoming-call', onCall);
  }

  void disconnect() {
    socket.disconnect();
  }
}
