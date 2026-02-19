import 'dart:async';
import 'dart:io'; 
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';

/// Service for handling SSH communication with the Liquid Galaxy rig.
class SSHService {
  SSHClient? _client;
  String? _host;

  bool get isConnected => _client != null && !(_client?.isClosed ?? true);
  String? get host => _host;

  /// Connect to the LG master machine via SSH.
  Future<bool> connect(
    String host,
    int port,
    String username,
    String passwordOrKey,
  ) async {
    _host = host;
    try {
      if (kDebugMode) {
        print('SSHService: Connecting to $host:$port as $username...');
      }
      final socket = await SSHSocket.connect(host, port, timeout: const Duration(seconds: 10));
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => passwordOrKey,
      );
      if (kDebugMode) {
        print('SSHService: Connection object created (optimistic)');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('SSH Connect Error: $e');
      }
      return false;
    }
  }

  /// Disconnect from the LG rig.
  Future<void> disconnect() async {
    _client?.close();
    _client = null;
  }

  /// Execute a shell command on the LG master.
  Future<String> execute(String command) async {
    if (_client == null) {
      if (kDebugMode) print('SSH: Not connected');
       // Starter Kit throws StateError, but we handle it gracefully or throw
       throw Exception('SSH not connected');
    }
    try {
      if (kDebugMode) print('SSH Execute: $command');
      final result = await _client!.run(command);
      return String.fromCharCodes(result);
    } catch (e) {
      if (kDebugMode) {
        print('SSH Execute Error: $e');
      }
      rethrow;
    }
  }

  /// Upload a file to the LG master via SFTP.
  Future<void> uploadKML(String content, String filename) async {
    if (_client == null) {
      throw Exception('SSH not connected');
    }

    try {
      final sftp = await _client!.sftp();
      final file = await sftp.open('/var/www/html/$filename', mode: SftpFileOpenMode.write | SftpFileOpenMode.create | SftpFileOpenMode.truncate);
      await file.write(Stream.value(Uint8List.fromList(content.codeUnits)));
      await file.close();
    } catch (e) {
      // Fallback: use printf if SFTP fails
      if (kDebugMode) print('SFTP failed, trying printf fallback: $e');
      await execute("printf '%s' '${content.replaceAll("'", "'\\''")}' > /var/www/html/$filename");
    }
  }

  Future<void> uploadBytes(Uint8List bytes, String path) async {
    if (_client == null) return;
    try {
      final sftp = await _client!.sftp();
      final remoteFile = await sftp.open(
        path,
        mode: SftpFileOpenMode.write |
            SftpFileOpenMode.create |
            SftpFileOpenMode.truncate,
      );
      await remoteFile.write(Stream.fromIterable([bytes]));
      await remoteFile.close();
    } catch (e) {
      if (kDebugMode) {
        print('SSH Upload Error: $e');
      }
      rethrow;
    }
  }
}
