import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheUtil {


  static Future<Uint8List> getCachedOrHttpImageBytes(String imageUrl) async {
    var imageFile = await getCachedOrHttpImage(imageUrl);
    return imageFile.readAsBytesSync();
  }

  static Future<File> getCachedOrHttpImage(String imageUrl) async {
    final cache = await DefaultCacheManager();
    final file = await cache.getSingleFile(imageUrl);
    if (file == null) {
      var response = await http.get(imageUrl);
      return File.fromRawPath(response.bodyBytes);
    } else {
      return file;
    }
  }
}