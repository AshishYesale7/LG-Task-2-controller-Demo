import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';

class SSHService {
  SSHClient? _client;

  Future<bool> connect(
    String host,
    int port,
    String username,
    String passwordOrKey,
  ) async {
    try {
      final socket = await SSHSocket.connect(host, port);

      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => passwordOrKey,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('SSH Connect Error: $e');
      }
      return false;
    }
  }

  Future<void> execute(String command) async {
    if (_client == null) return;
    try {
      await _client!.run(command);
    } catch (e) {
      if (kDebugMode) {
        print('SSH Execute Error: $e');
      }
    }
  }

  Future<void> upload(File file, String path) async {
    if (_client == null) return;
    try {
      final sftp = await _client!.sftp();
      final fileData = await file.readAsBytes();
      final remoteFile = await sftp.open(
        path,
        mode: SftpFileOpenMode.write |
            SftpFileOpenMode.create |
            SftpFileOpenMode.truncate,
      );
      await remoteFile.write(fileData.asStream());
      await remoteFile.close();
    } catch (e) {
      if (kDebugMode) {
        print('SSH Upload Error: $e');
      }
    }
  }

  Future<void> disconnect() async {
    _client?.close();
    _client = null;
  }
}
