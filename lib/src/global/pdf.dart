// ignore_for_file: avoid_print

import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meyaoo_new/src/global/global.dart';
import 'package:pdf_render/pdf_render.dart' as pdf_render;
import 'package:pdf/pdf.dart' as pdf_lib;

Future<Map<String, dynamic>> getPdfInfo(String url) async {
  try {
    // Fetch the PDF from the URL
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Uint8List pdfData = response.bodyBytes;

      // Calculate the file size in bytes
      final int fileSize = pdfData.lengthInBytes;

      // Convert file size to human-readable format (KB, MB, etc.)
      final String readableFileSize = _formatFileSize(fileSize);

      // Use pdf_render.PdfDocument to read the PDF and count pages
      final document = await pdf_render.PdfDocument.openData(pdfData);
      final int pageCount = document.pageCount;

      return {
        'pageCount': pageCount,
        'fileSize': readableFileSize,
      };
    } else {
      throw Exception('Failed to load PDF');
    }
  } catch (e) {
    print('Error getting PDF info: $e');
    return {
      'pageCount': 0,
      'fileSize': 'Unknown',
    };
  }
}

String _formatFileSize(int bytes) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  var i = (bytes == 0) ? 0 : (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
}
