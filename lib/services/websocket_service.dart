import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/constants.dart';

/// WebSocket service for real-time market data updates
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _shouldReconnect = true;

  /// Stream of market updates
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  /// Connection status
  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  void connect() {
    if (_isConnected) return;

    try {
      debugPrint('WebSocket: Connecting to ${AppConstants.wsUrl}...');
      _channel = WebSocketChannel.connect(Uri.parse(AppConstants.wsUrl));
      _isConnected = true;
      _shouldReconnect = true;

      _channel!.stream.listen(
        (message) {
          try {
            final data = json.decode(message) as Map<String, dynamic>;
            debugPrint('WebSocket: Received ${data['type']}');
            _controller.add(data);
          } catch (e) {
            debugPrint('WebSocket: Error parsing message: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket: Error: $error');
          _handleDisconnection();
        },
        onDone: () {
          debugPrint('WebSocket: Connection closed');
          _handleDisconnection();
        },
        cancelOnError: false,
      );

      debugPrint('WebSocket: Connected successfully');
    } catch (e) {
      debugPrint('WebSocket: Connection failed: $e');
      _handleDisconnection();
    }
  }

  /// Handle disconnection and attempt reconnect
  void _handleDisconnection() {
    _isConnected = false;
    _channel = null;

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Schedule a reconnection attempt
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_shouldReconnect && !_isConnected) {
        debugPrint('WebSocket: Attempting to reconnect...');
        connect();
      }
    });
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    debugPrint('WebSocket: Disconnected');
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _controller.close();
  }
}
