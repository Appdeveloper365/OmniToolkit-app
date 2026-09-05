/// FILE: lib/modules/radio/services/stream_resolver_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class StreamValidationResult {
  const StreamValidationResult({
    required this.isValid,
    required this.resolvedUrl,
    this.detectedFormat,
    this.errorMessage,
    this.isInsecureHttpOnWeb = false,
  });

  final bool isValid;
  final String resolvedUrl;
  final String? detectedFormat;
  final String? errorMessage;
  final bool isInsecureHttpOnWeb;
}

class StreamResolverService {
  /// Checks whether a stream is HTTP while running under HTTPS on Web.
  static bool isInsecureWebStream(String url) {
    if (!kIsWeb) return false;
    try {
      final baseScheme = Uri.base.scheme.toLowerCase();
      final streamScheme = Uri.parse(url).scheme.toLowerCase();
      return baseScheme == 'https' && streamScheme == 'http';
    } catch (_) {
      return false;
    }
  }

  /// Resolve playlists, redirects, mixed content, and codec format.
  Future<StreamValidationResult> resolveAndValidate(String initialUrl) async {
    debugPrint('[RadioResolver] Validating stream URL: $initialUrl');

    if (initialUrl.trim().isEmpty) {
      return const StreamValidationResult(
        isValid: false,
        resolvedUrl: '',
        errorMessage: 'Stream URL is empty.',
      );
    }

    String currentUrl = initialUrl.trim();

    // 1. Web HTTPS Mixed Content Check
    if (isInsecureWebStream(currentUrl)) {
      // Try upgrading to HTTPS
      final upgraded = currentUrl.replaceFirst('http://', 'https://');
      debugPrint('[RadioResolver] Attempting HTTPS upgrade: $upgraded');
      final isUpgradedOk = await _probeUrl(upgraded);
      if (isUpgradedOk) {
        currentUrl = upgraded;
        debugPrint('[RadioResolver] Stream upgraded to HTTPS successfully.');
      } else {
        debugPrint('[RadioResolver] HTTPS upgrade failed. Insecure HTTP blocked on Web HTTPS.');
        return StreamValidationResult(
          isValid: false,
          resolvedUrl: currentUrl,
          isInsecureHttpOnWeb: true,
          errorMessage: 'This station uses an insecure stream and cannot be played over HTTPS.',
        );
      }
    }

    // 2. Resolve Playlist or Redirect
    try {
      final resolved = await _resolvePlaylistsAndRedirects(currentUrl);
      currentUrl = resolved;
    } catch (e) {
      debugPrint('[RadioResolver] Warning during redirect resolution: $e');
    }

    // 3. Detect Format / Codec
    final format = _detectFormat(currentUrl);
    if (format == 'UNSUPPORTED') {
      debugPrint('[RadioResolver] Unsupported audio format detected for: $currentUrl');
      return StreamValidationResult(
        isValid: false,
        resolvedUrl: currentUrl,
        detectedFormat: format,
        errorMessage: 'This station uses an unsupported audio format.',
      );
    }

    debugPrint('[RadioResolver] Validated stream URL: $currentUrl (Format: $format)');
    return StreamValidationResult(
      isValid: true,
      resolvedUrl: currentUrl,
      detectedFormat: format,
    );
  }

  Future<bool> _probeUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.head(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode >= 200 && response.statusCode < 400) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<String> _resolvePlaylistsAndRedirects(String url, {int depth = 0}) async {
    if (depth > 5) return url;

    final lower = url.toLowerCase();
    final isPlaylistExt = lower.endsWith('.m3u') || lower.endsWith('.pls') || lower.endsWith('.m3u8');

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url))
        ..followRedirects = true
        ..maxRedirects = 5
        ..headers.addAll({
          'User-Agent': 'OmniToolkitRadio/1.0',
          'Accept': '*/*',
        });

      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 4));
      final finalUrl = streamedResponse.headers['location'] ?? streamedResponse.request?.url.toString() ?? url;
      final contentType = streamedResponse.headers['content-type']?.toLowerCase() ?? '';

      final isPlaylistHeader = contentType.contains('mpegurl') ||
          contentType.contains('scpls') ||
          contentType.contains('playlist');

      if (isPlaylistExt || isPlaylistHeader) {
        final bodyBytes = await streamedResponse.stream.toBytes();
        final bodyText = utf8.decode(bodyBytes, allowMalformed: true);
        final extracted = _extractUrlFromPlaylist(bodyText);
        if (extracted != null && extracted.isNotEmpty && extracted != url) {
          debugPrint('[RadioResolver] Extracted playlist target: $extracted');
          return _resolvePlaylistsAndRedirects(extracted, depth: depth + 1);
        }
      }

      return finalUrl;
    } catch (e) {
      debugPrint('[RadioResolver] Error resolving URL $url: $e');
    }

    return url;
  }

  String? _extractUrlFromPlaylist(String content) {
    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      if (line.startsWith('File1=') || line.startsWith('File2=')) {
        return line.split('=').last.trim();
      }

      if (line.startsWith('http://') || line.startsWith('https://')) {
        return line;
      }
    }
    return null;
  }

  String _detectFormat(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.m3u8')) return 'HLS';
    if (lower.contains('.mp3') || lower.contains('mp3')) return 'MP3';
    if (lower.contains('.aac') || lower.contains('aac')) return 'AAC';
    if (lower.contains('.ogg') || lower.contains('ogg')) return 'OGG';

    if (lower.endsWith('.wma') || lower.endsWith('.wav') || lower.contains('rtsp://')) {
      return 'UNSUPPORTED';
    }

    return 'MP3'; // Default stream format
  }
}
