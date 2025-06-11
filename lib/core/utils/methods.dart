Map<String, dynamic> convertStringToMap(String mapString) {
  var result = <String, dynamic>{};

  mapString = mapString.substring(1, mapString.length - 1);

  var pairs = mapString.split(', ');

  for (var pair in pairs) {
    try {
      var keyValue = pair.split(': ');

      var key = keyValue[0].trim();
      var value = keyValue[1].trim();

      dynamic parsedValue = int.tryParse(value) ?? value;
      result[key] = parsedValue;
    }
    catch (_) {
      continue;
    }
  }

  return result;
}

String getHttpFromWs(String wsUrl) {
  try {
    Uri uri = Uri.parse(wsUrl);
    String newScheme;

    if (uri.scheme == 'ws') {
      newScheme = 'http';
    } else if (uri.scheme == 'wss') {
      newScheme = 'https';
    } else {
      return 'Invalid WebSocket URL: unsupported scheme "${uri.scheme}"';
    }

    List<String> pathSegments = List.from(uri.pathSegments);

    if (pathSegments.isNotEmpty && pathSegments.last.isEmpty) {
      pathSegments.removeLast();
    }

    if (pathSegments.isNotEmpty) {
      pathSegments.removeLast();
    }

    String newPath;
    if (pathSegments.isEmpty) {
      newPath = '';
    } else {
      newPath = '/${pathSegments.join('/')}';
    }

    Uri newUri = Uri(
      scheme: newScheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.port,
      path: newPath,
    );

    return newUri.toString();

  } on FormatException catch (e) {
    return 'Invalid WebSocket URL: parsing failed - ${e.message}';
  } catch (e) {
    return 'An unexpected error occurred: ${e.toString()}';
  }
}

Future<String> parseCookie(cookie) async {
  var jsessionId = '';

  if (cookie != null && cookie.contains('JSESSIONID=')) {
    var startIndex = cookie.indexOf('JSESSIONID=') + 'JSESSIONID='.length;
    var endIndex = cookie.indexOf(';', startIndex);
    jsessionId = cookie.substring(startIndex, endIndex);
    return jsessionId;
  }
  return "";
}