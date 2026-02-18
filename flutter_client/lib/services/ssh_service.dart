import 'dart:async';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';

/// Possible states for the SSH connection.
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// Service for handling SSH communication with the Liquid Galaxy rig.
///
/// This is the transport layer — it should not import KML or model classes.
class SSHService {
  SSHClient? _client;
  
  /// Current connection status
  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectionStatus get status => _status;
  
  /// Whether a connection is active.
  bool get isConnected => _client != null && _status == ConnectionStatus.connected;

  /// Connect to the LG master machine via SSH.
  Future<void> connect({
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    _status = ConnectionStatus.connecting;
    try {
      final socket = await SSHSocket.connect(host, port,
          timeout: const Duration(seconds: 10));
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );
      _status = ConnectionStatus.connected;
    } catch (e) {
      _status = ConnectionStatus.error;
      _client = null;
      rethrow;
    }
  }

  /// Disconnect from the LG rig.
  void disconnect() {
    _client?.close();
    _client = null;
    _status = ConnectionStatus.disconnected;
  }

  /// Dispose of SSH resources. Call when the service is no longer needed.
  void dispose() {
    disconnect();
  }

  /// Execute a shell command on the LG master.
  ///
  /// Throws an [Exception] if the client is not connected or the command fails.
  Future<String> execute(String command) async {
    if (_client == null) {
      throw StateError('SSH client is not connected');
    }
    final result = await _client!.run(command);
    return String.fromCharCodes(result);
  }

  /// Upload a file to the LG master via SFTP.
  Future<void> uploadKML(String content, String filename) async {
    if (_client == null) {
      throw StateError('SSH client is not connected');
    }

    try {
      final sftp = await _client!.sftp();
      final file = await sftp.open('/var/www/html/$filename', mode: SftpFileOpenMode.write | SftpFileOpenMode.create | SftpFileOpenMode.truncate);
      await file.write(Stream.value(Uint8List.fromList(content.codeUnits)));
      await file.close();
    } catch (e) {
      // Fallback: use printf if SFTP fails (handles special characters safely)
      await execute("printf '%s' '${content.replaceAll("'", "'\\''")}' > /var/www/html/$filename");
    }
  }

  /// Download a file from the LG master via SFTP.
  Future<String> downloadFile(String remotePath) async {
    if (_client == null) {
      throw StateError('SSH client is not connected');
    }
    final sftp = await _client!.sftp();
    final file = await sftp.open(remotePath, mode: SftpFileOpenMode.read);
    final data = await file.readBytes();
    await file.close();
    return String.fromCharCodes(data);
  }
}
