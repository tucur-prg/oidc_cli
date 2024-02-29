///
/// JWK kty key
///
enum Kty {
  EC,
  ;

  String toJson() {
    return toString();
  }

  @override
  String toString() {
    return this.name;
  }
}

///
/// JWK crv key
///
enum Crv {
  P256('P-256'),
  ;

  final String value;

  const Crv(this.value);

  String toJson() {
    return toString();
  }

  @override
  String toString() {
    return this.value;
  }
}
