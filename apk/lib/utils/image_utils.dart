import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

bool isDataImage(String? value) {
  return value != null && value.startsWith('data:image');
}

Uint8List? decodeDataImage(String data) {
  if (!isDataImage(data)) {
    return null;
  }

  final base64Part = data.split(',').last;
  return base64Decode(base64Part);
}

Widget buildEventImage(
  String? imageData, {
  double height = 180,
  BoxFit fit = BoxFit.cover,
}) {
  if (imageData == null || imageData.isEmpty) {
    return Container(
      height: height,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.image, size: 60)),
    );
  }

  if (isDataImage(imageData)) {
    final bytes = decodeDataImage(imageData);
    if (bytes != null) {
      return Image.memory(
        bytes,
        height: height,
        width: double.infinity,
        fit: fit,
      );
    }
  }

  return Image.file(
    File(imageData),
    height: height,
    width: double.infinity,
    fit: fit,
  );
}
