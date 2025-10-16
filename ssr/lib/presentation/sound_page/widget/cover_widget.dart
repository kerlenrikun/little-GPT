import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:developer';

class CoverWidget extends StatefulWidget {
  final String coverUrl;
  const CoverWidget({super.key, required this.coverUrl});

  @override
  State<CoverWidget> createState() => _CoverWidgetState();
}

class _CoverWidgetState extends State<CoverWidget> {
  bool _isImageLoaded = false;
  bool _isLoadingFailed = false;

  @override
  void initState() {
    super.initState();
    // Initialize without loading the image
    print('Attempting to load image URL: ${widget.coverUrl}');
    _validateUrl(widget.coverUrl);
  }

  void _validateUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        print('URL protocol error: Must be http or https');
      } else if (uri.host.isEmpty) {
        print('URL format error: Missing hostname');
      } else {
        print('URL format validation passed');
      }
    } catch (e) {
      print('URL parsing failed: $e');
    }
  }

  // Corrected error handler with proper signature
  void _handleImageError(Object error) {
    print('\n=== Image Loading Error Details ===');
    print('Error type: ${error.runtimeType}');
    print('Error message: $error');

    // Analyze different types of errors
    if (error is SocketException) {
      print('Socket Exception Details:');
      print('  - Error code: ${error.osError?.errorCode}');
      print('  - Error message: ${error.osError?.message}');
      print('  - Address: ${error.address}');
      print('  - Port: ${error.port}');
    } else if (error is HttpException) {
      print('HTTP Exception Details:');
      print('  - Message: ${error.message}');
      // Try to extract status code from exception message
      if (error.message.contains('(')) {
        final statusCodeMatch = RegExp(r'\((\d+)\)').firstMatch(error.message);
        if (statusCodeMatch != null) {
          print('  - Status code: ${statusCodeMatch.group(1)}');
        }
      }
    } else if (error is HandshakeException) {
      print('SSL Handshake Exception: ${error.message}');
    }

    print('=====================\n');

    setState(() {
      _isLoadingFailed = true;
      _isImageLoaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.85;
    final screenHeight = screenWidth * 9 / 16;

    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        color: Color(0xffA47508),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: widget.coverUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Color(0xffA47508),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Color(0xffA47508),
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          imageBuilder: (context, imageProvider) {
            _isImageLoaded = true;
            _isLoadingFailed = false;
            return Image(image: imageProvider, fit: BoxFit.cover);
          },
          // Fixed error listener with correct signature
          errorListener: _handleImageError,
        ),
      ),
    );
  }
}
