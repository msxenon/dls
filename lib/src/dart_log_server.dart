import 'dart:async';
import 'dart:convert';
import 'dart:io';

class DartLogServer {
  Future<void> start({required int port}) async {
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
  }
}
