import 'dart:io';

void main() async {
  final port = 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('Biosphere Codex running at http://localhost:$port');

  final webDir = Directory('build/web');

  await for (final HttpRequest request in server) {
    try {
      var path = request.uri.path;
      if (path == '/' || path.isEmpty) path = '/index.html';
      var file = File('${webDir.path}$path');

      if (!await file.exists()) {
        file = File('${webDir.path}/index.html');
      }

      final ext = file.path.split('.').last.toLowerCase();
      switch (ext) {
        case 'html':
          request.response.headers.contentType = ContentType.html;
          break;
        case 'js':
          request.response.headers.contentType =
              ContentType('application', 'javascript', charset: 'utf-8');
          break;
        case 'json':
          request.response.headers.contentType = ContentType.json;
          break;
        case 'wasm':
          request.response.headers.contentType =
              ContentType('application', 'wasm');
          break;
        case 'png':
          request.response.headers.contentType =
              ContentType('image', 'png');
          break;
        case 'ttf':
          request.response.headers.contentType =
              ContentType('font', 'ttf');
          break;
        case 'otf':
          request.response.headers.contentType =
              ContentType('font', 'otf');
          break;
      }

      await file.openRead().pipe(request.response);
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.close();
    }
  }
}

