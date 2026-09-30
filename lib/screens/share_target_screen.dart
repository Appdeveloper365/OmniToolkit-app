import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Screen for displaying received Web Share Target data (/share route).
class ShareTargetScreen extends StatelessWidget {
  const ShareTargetScreen({
    super.key,
    this.title,
    this.text,
    this.url,
  });

  final String? title;
  final String? text;
  final String? url;

  @override
  Widget build(BuildContext context) {
    // Sanitize all inputs before display
    final titleVal = _sanitizeDisplayString(title);
    final textVal = _sanitizeDisplayString(text);
    final urlVal = _sanitizeUrl(url);

    // Log received share target payload to browser console / developer log
    if (kIsWeb) {
      developer.log(
        'PWA Share Target Received -> title: ${titleVal ?? "(none)"}, text: ${textVal ?? "(none)"}, url: ${urlVal ?? "(none)"}',
        name: 'OmniToolkit.ShareTarget',
      );
      _debugPrint('PWA Share Target Received -> title: $titleVal, text: $textVal, url: $urlVal');
    }

    final hasContent = titleVal != null || textVal != null || urlVal != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Content'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.share,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Web Share Target Received',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _ShareField(
                      icon: Icons.title,
                      label: 'Title',
                      value: titleVal,
                    ),
                    const SizedBox(height: 12),
                    _ShareField(
                      icon: Icons.notes,
                      label: 'Text',
                      value: textVal,
                    ),
                    const SizedBox(height: 12),
                    _ShareField(
                      icon: Icons.link,
                      label: 'URL',
                      value: urlVal,
                      isUrl: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!hasContent)
              Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No query parameters received. Open URL format:\n/share?title=Example&text=Hello&url=https://example.com',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Sanitize string for safe display - remove control chars, limit length
  String? _sanitizeDisplayString(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    // Remove control characters except newlines/tabs
    final sanitized = trimmed.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
    // Limit length to prevent UI issues
    return sanitized.length > 500 ? '${sanitized.substring(0, 500)}…' : sanitized;
  }

  /// Sanitize and validate URL - only allow http/https, block javascript: and data: URIs
  String? _sanitizeUrl(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Block dangerous protocols
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('javascript:') ||
        lower.startsWith('data:') ||
        lower.startsWith('vbscript:') ||
        lower.startsWith('file:') ||
        lower.startsWith('ftp:')) {
      _debugPrint('ShareTarget: Blocked dangerous URL protocol: $lower');
      return 'Blocked: unsafe URL protocol';
    }

    // Validate URL format
    try {
      final uri = Uri.parse(trimmed);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Blocked: invalid URL scheme';
      }
      // Limit URL length
      return trimmed.length > 2048 ? '${trimmed.substring(0, 2048)}…' : trimmed;
    } catch (_) {
      return 'Blocked: malformed URL';
    }
  }

  void _debugPrint(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}

class _ShareField extends StatelessWidget {
  const _ShareField({
    required this.icon,
    required this.label,
    required this.value,
    this.isUrl = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool isUrl;

  @override
  Widget build(BuildContext context) {
    final displayValue = value ?? 'Not provided';
    final isMissing = value == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMissing
                ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            displayValue,
            style: TextStyle(
              fontStyle: isMissing ? FontStyle.italic : FontStyle.normal,
              color: isMissing
                  ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                  : (isUrl ? Theme.of(context).colorScheme.primary : null),
              decoration: isUrl && !isMissing ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }
}