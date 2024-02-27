import 'base_request.dart';

enum GrantType {
  AuthorizationCode("authorization_code"),
  ;

  final String value;

  const GrantType(this.value);
}

class TokenRequest extends Request {
  ApiContentType contentType = ApiContentType.Form;

  TokenRequest(super.uri, [super.method = ApiMethod.POST]);

  setBody({
    required String clientId,
    required String secret,
    GrantType grantType = GrantType.AuthorizationCode,
    required String redirectUri,
    String? code,
    String? codeVerifier,
  }) {
    body = {
      "client_id": clientId,
      "client_secret": secret,
      "grant_type": grantType.value,
      "redirect_uri": redirectUri,
      if (code != null) "code": code,
      if (codeVerifier != null) "code_verifier": codeVerifier,
    };
  }
}
