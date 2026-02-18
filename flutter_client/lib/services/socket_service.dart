import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service for WebSocket communication with the Node.js server.
///
/// Provides real-time bidirectional communication for live updates
/// (e.g., streaming KML updates, sensor data, or chat).
class SocketService {
  WebSocketChannel? _channel;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  /// Stream of incoming messages.
  Stream<String> get messages => _messageController.stream;

  /// Whether the WebSocket is connected.
  bool get isConnected => _channel != null;

  /// Connect to the WebSocket server.
  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen(
        (message) => _messageController.add(message.toString()),
        onError: (error) => _messageController.addError(error),
        onDone: () {
          _channel = null;
        },
      );
    } catch (e) {
      _channel = null;
      rethrow;
    }
  }

  /// Send a message through the WebSocket.
  void send(String message) {
    _channel?.sink.add(message);
  }

  /// Disconnect the WebSocket.
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  /// Dispose of resources.
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
