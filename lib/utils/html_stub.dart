// HTML için stub (sahte) sınıflar
// Bu dosya, dart:html'e ihtiyaç duyan kodu web olmayan platformlarda çalıştırmak için kullanılır
// Web platformunda bu dosya kullanılmaz, doğrudan dart:html kullanılır

class Blob {
  final dynamic data;
  final String type;

  Blob(this.data, this.type);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}

class AnchorElement {
  String? href;

  AnchorElement({this.href});

  void setAttribute(String name, String value) {}
  void click() {}
}
