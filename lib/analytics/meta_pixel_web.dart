import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Web implementation of the Meta Pixel facade.
///
/// The base pixel snippet in `web/index.html` defines `window.fbq` and fires
/// `PageView` on load. This class fires the standard events that happen after
/// load — which, on a Flutter canvas app, is the only way to fire them at all:
/// Meta's point-and-click Event Setup Tool needs DOM elements to bind to and
/// there are none.
class MetaPixel {
  const MetaPixel._();

  /// Fires a Meta Pixel standard event.
  ///
  /// Safe no-op when the pixel is unavailable — blocked by an ad blocker,
  /// stripped by a privacy extension, or the script simply failed to load.
  /// Analytics must never be able to break a form submission.
  static void track(String event, [Map<String, Object?>? params]) {
    try {
      final global = globalContext;
      if (!global.has('fbq')) return;

      final fbq = global['fbq'] as JSFunction;
      if (params == null || params.isEmpty) {
        fbq.callAsFunction(global, 'track'.toJS, event.toJS);
      } else {
        fbq.callAsFunction(global, 'track'.toJS, event.toJS, params.jsify());
      }
    } catch (_) {
      // Deliberately swallowed.
    }
  }

  /// Fires the `Lead` event.
  ///
  /// Call this ONLY after the lead has actually been stored — never on button
  /// press. Firing on press counts validation errors and failed network calls
  /// as conversions, and Meta then optimises delivery toward people who tap
  /// but never convert.
  ///
  /// [eventId] is unused today. Pass a stable id here and the same id from the
  /// server if the Conversions API is ever added, and Meta will deduplicate the
  /// browser and server copies of the event.
  static void lead({String? eventId}) {
    track('Lead', {
      'content_name': 'SnapSalon Early Access',
      'content_category': 'salon_software_waitlist',
      if (eventId != null) 'eventID': eventId,
    });
  }
}
