/// Meta Pixel facade.
///
/// The web implementation talks to the `fbq` global installed by the base
/// pixel snippet in `web/index.html`. Every other platform gets a no-op so
/// the app still compiles if this ever ships beyond web.
export 'meta_pixel_stub.dart'
    if (dart.library.js_interop) 'meta_pixel_web.dart';
