import 'dart:convert';

import 'package:crypto/crypto.dart';

class Encrypt {
  static String convertStr2Sha512(String text) {
    var bytes = utf8.encode(text);
    var digest = sha512.convert(bytes);

    return digest.toString();
  }
}
