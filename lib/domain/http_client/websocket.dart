// lib/domain/http_client/websocket_client.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  String? url = dotenv.env['WS_URL'];
  WebSocketChannel? _channel;

  WebSocketClient({this.url = 'wss://echo.websocket.org'});

  // ฟังก์ชันเริ่มต้นการเชื่อมต่อ WebSocket
  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(url!));
    print('Connected to WebSocket at: $url');
  }

  // ฟังก์ชันส่งข้อความไปยัง WebSocket
  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
      print('Sent: $message');
    } else {
      print('WebSocket not connected!');
    }
  }

  // ฟังก์ชันรับข้อความจาก WebSocket
  Stream<String> get messages {
    if (_channel != null) {
      return _channel!.stream.map((message) => message.toString());
    } else {
      throw Exception('WebSocket not connected!');
    }
  }

  // ฟังก์ชันปิดการเชื่อมต่อ WebSocket
  void close() {
    _channel?.sink.close();
    print('WebSocket connection closed');
  }
}
