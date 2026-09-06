/// No-op Meta Pixel implementation for non-web builds.
class MetaPixel {
  const MetaPixel._();

  static void track(String event, [Map<String, Object?>? params]) {}

  static void lead({String? eventId}) {}
}
