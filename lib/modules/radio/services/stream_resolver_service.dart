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

  /// Validates URL format and scheme - only allows http/https
  static bool isValidStreamUrl(String url) {
    if (url.trim().isEmpty) return false;
    try {
      final uri = Uri.parse(url.trim());
      if (!uri.hasScheme) return false;
      final scheme = uri.scheme.toLowerCase();
      if (scheme != 'http' && scheme != 'https') return false;
      if (uri.host.isEmpty) return false;
      // Block localhost/private IPs in production
      if (kReleaseMode) {
        final host = uri.host.toLowerCase();
        if (host == 'localhost' || host == '127.0.0.1' || host == '::1') return false;
        // Block private IP ranges
        if (RegExp(r'^10\.').hasMatch(host) ||
            RegExp(r'^192\.168\.').hasMatch(host) ||
            RegExp(r'^172\.(1[6-9]|2[0-9]|3[0-1])\.').hasMatch(host)) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Resolve playlists, redirects, mixed content, and codec format.
  Future<StreamValidationResult> resolveAndValidate(String initialUrl) async {
    _debugLog('[RadioResolver] Validating stream URL: $initialUrl');

    if (initialUrl.trim().isEmpty) {
      return const StreamValidationResult(
        isValid: false,
        resolvedUrl: '',
        errorMessage: 'Stream URL is empty.',
      );
    }

    // Validate URL before processing
    if (!isValidStreamUrl(initialUrl)) {
      _debugLog('[RadioResolver] Invalid stream URL format: $initialUrl');
      return const StreamValidationResult(
        isValid: false,
        resolvedUrl: '',
        errorMessage: 'Invalid stream URL format.',
      );
    }

    String currentUrl = initialUrl.trim();

    // 1. Web HTTPS Mixed Content Check
    if (isInsecureWebStream(currentUrl)) {
      final upgraded = currentUrl.replaceFirst('http://', 'https://');
      _debugLog('[RadioResolver] Attempting HTTPS upgrade: $upgraded');
      final isUpgradedOk = await _probeUrl(upgraded);
      if (isUpgradedOk) {
        currentUrl = upgraded;
        _debugLog('[RadioResolver] Stream upgraded to HTTPS successfully.');
      } else {
        _debugLog('[RadioResolver] HTTPS upgrade failed. Insecure HTTP blocked by browser.');
        return StreamValidationResult(
          isValid: false,
          resolvedUrl: currentUrl,
          isInsecureHttpOnWeb: true,
          errorMessage: 'Insecure radio stream blocked by browser.',
        );
      }
    }

    // 2. Resolve Playlist or Redirect (with depth limit)
    try {
      final resolved = await _resolvePlaylistsAndRedirects(currentUrl);
      // Validate resolved URL too
      if (!isValidStreamUrl(resolved)) {
        _debugLog('[RadioResolver] Resolved URL failed validation: $resolved');
        return StreamValidationResult(
          isValid: false,
          resolvedUrl: resolved,
          errorMessage: 'Resolved stream URL is invalid.',
        );
      }
      currentUrl = resolved;
    } catch (e) {
      _debugLog('[RadioResolver] Warning during redirect resolution: $e');
    }

    // 3. Detect Format / Codec
    final format = _detectFormat(currentUrl);
    if (format == 'UNSUPPORTED') {
      _debugLog('[RadioResolver] Unsupported audio format detected for: $currentUrl');
      return StreamValidationResult(
        isValid: false,
        resolvedUrl: currentUrl,
        detectedFormat: format,
        errorMessage: 'This station uses an unsupported audio format.',
      );
    }

    _debugLog('[RadioResolver] Validated stream URL: $currentUrl (Format: $format)');
    return StreamValidationResult(
      isValid: true,
      resolvedUrl: currentUrl,
      detectedFormat: format,
    );
  }

  Future<bool> _probeUrl(String url) async {
    if (!isValidStreamUrl(url)) return false;
    try {
      final uri = Uri.parse(url);
      final response = await http.head(uri).timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {}
    return false;
  }

  Future<String> _resolvePlaylistsAndRedirects(String url, {int depth = 0}) async {
    // Security: Limit redirect depth to prevent infinite loops
    if (depth > 5) {
      _debugLog('[RadioResolver] Max redirect depth reached for: $url');
      return url;
    }

    if (!isValidStreamUrl(url)) return url;

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
        // Security: Limit playlist size to prevent memory exhaustion
        if (bodyBytes.length > 64 * 1024) { // 64KB limit
          _debugLog('[RadioResolver] Playlist too large, skipping extraction');
          return finalUrl;
        }
        final bodyText = utf8.decode(bodyBytes, allowMalformed: true);
        final extracted = _extractUrlFromPlaylist(bodyText);
        if (extracted != null && extracted.isNotEmpty && extracted != url && isValidStreamUrl(extracted)) {
          _debugLog('[RadioResolver] Extracted playlist target: $extracted');
          return await _resolvePlaylistsAndRedirects(extracted, depth: depth + 1);
        }
      }

      // Validate final URL before returning
      return isValidStreamUrl(finalUrl) ? finalUrl : url;
    } catch (e) {
      _debugLog('[RadioResolver] Error resolving URL $url: $e');
    }

    return url;
  }

  String? _extractUrlFromPlaylist(String content) {
    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      if (line.startsWith('File1=') || line.startsWith('File2=')) {
        final extracted = line.split('=').last.trim();
        if (isValidStreamUrl(extracted)) return extracted;
      }

      if ((line.startsWith('http://') || line.startsWith('https://')) && isValidStreamUrl(line)) {
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

    return 'MP3';
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}