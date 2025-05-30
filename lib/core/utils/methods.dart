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