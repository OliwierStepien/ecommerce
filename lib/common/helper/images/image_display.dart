enum ImgVariant { thumb, full }

class ImageDisplayHelper {
  static const _baseUrl =
      'https://firebasestorage.googleapis.com/v0/b/ecommerce-2456i32ffd.firebasestorage.app/o';

  static const _ext = 'webp';

  static String _stripExt(String name) {
    // usuń końcówki jeśli ktoś poda nazwę z rozszerzeniem
    return name
        .replaceAll(RegExp(r'\.(jpg|jpeg|png|webp)$', caseSensitive: false), '');
  }

  static String meal(String name, {ImgVariant variant = ImgVariant.full}) {
    final n = _stripExt(name);
    final folder =
        (variant == ImgVariant.thumb) ? 'meals%2Fthumb%2F' : 'meals%2Ffull%2F';
    return '$_baseUrl/$folder$n.$_ext?alt=media';
  }

  static String category(String name, {ImgVariant variant = ImgVariant.full}) {
    final n = _stripExt(name);
    final folder = (variant == ImgVariant.thumb)
        ? 'categories%2Fthumb%2F'
        : 'categories%2Ffull%2F';
    return '$_baseUrl/$folder$n.$_ext?alt=media';
  }

  static String generateSplashImagePath(String imageName) {
    return 'assets/images/splash/$imageName.jpg';
  }
}