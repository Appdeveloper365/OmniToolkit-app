import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Listens for the browser tab regaining focus (e.g. the user switching back
/// from their email app) so Firebase Auth state can be re-checked without
/// waiting for a full page reload. Returns a callback that removes the
/// listener.
void Function() onBrowserFocus(void Function() callback) {
  void listener(web.Event event) => callback();
  final jsListener = listener.toJS;
  web.window.addEventListener('focus', jsListener);
  return () => web.window.removeEventListener('focus', jsListener);
}
