import 'dart:async';
import 'dart:convert';
import 'dart:io';

class DartLogServer {
  int retries = 0;
  static const int maxRetries = 3;
  Future<void> start({required int port}) async {
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
      print('Error starting log server: $e');
      if (retries < maxRetries) {
        retries++;
        print('Retrying to start server... Attempt $retries of $maxRetries');
        await killProcessOnPort(port);
        await start(port: port);
      } else {
        print('Failed to start server after $maxRetries attempts.');
      }
    }
  }

  Future<void> killProcessOnPort(int port) async {
    try {
      // Find the process using the port
      var result = await Process.run('lsof', ['-i', ':$port']);

      if (result.exitCode != 0) {
        print('No process found running on port $port.');
        return;
      }

      // Extract the process ID (PID)
      var lines = result.stdout.toString().split('\n');
      if (lines.length > 1) {
        var columns = lines[1].split(RegExp(r'\s+'));
        if (columns.isNotEmpty) {
          var pid = columns[1];
          print('Killing process with PID: $pid');

          // Kill the process
          await Process.run('kill', ['-9', pid]);
          print('Process $pid on port $port has been killed.');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
