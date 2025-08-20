import 'dart:async';
import 'dart:convert';
import 'dart:io';

class DartLogServer {
  int retries = 0;
  static const int maxRetries = 3;

  Future<void> start({required int port, required bool isVerbose}) async {
    try {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      print('Log server listening on http://${server.address.host}:${server.port}');

      await for (HttpRequest req in server) {
        if (req.method == 'POST' && req.uri.path == '/log') {
          final body = await utf8.decoder.bind(req).join();
          print(body); // Print to console or save to file
          unawaited(req.response.close());
        } else {
          req.response;
          unawaited(req.response.close());
        }
      }
    } catch (e) {
      if (retries < maxRetries) {
        retries++;
        if (isVerbose) {
          print('Retrying to start server... Attempt $retries of $maxRetries');
        }
        await _killProcessOnPort(port);
        await start(port: port, isVerbose: isVerbose);
      } else {
        print('Failed to start server after $maxRetries attempts, $e. Exiting.');
      }
    }
  }

  Future<void> _killProcessOnPort(int port, {bool isVerbose = false}) async {
    try {
      // Find the process IDs using the port
      final result = await Process.run('lsof', ['-ti', 'tcp:$port']);
      if (isVerbose) {
        if (result.exitCode != 0 || (result.stdout as String).trim().isEmpty) {
          print('No process found running on port $port.');
          return;
        }
      }

      final pids = (result.stdout as String).trim().split('\n');

      for (final pid in pids) {
        if (isVerbose) {
          print('Killing process with PID: $pid');
        }
        await Process.run('kill', ['-9', pid]);
        if (isVerbose) {
          print('Process $pid on port $port has been killed.');
        }
      }

      // Small delay to let the OS release the port
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      if (isVerbose) {
        print('Error killing process on port $port: $e');
      }
    }
  }
}
