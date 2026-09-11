/// No-op outside the browser; native platforms rely on
/// [WidgetsBindingObserver.didChangeAppLifecycleState] instead.
void Function() onBrowserFocus(void Function() callback) {
  return () {};
}
