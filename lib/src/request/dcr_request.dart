import 'base_request.dart';

enum CryptoAlgorithm {
  RS256,
  ES256,
}

enum TokenEndpointAuth {
  None("none"),
  ClientSecretPost("client_secret_post"),
  ClientSecretBasic("client_secret_basic"),
  ClientSecretJwt("client_secret_jwt"),
  PrivateKeyJWT("private_key_jwt"),
  ;

  final String value;

  const TokenEndpointAuth(this.value);
}

class DcrRequest extends Request {
  DcrRequest(super.uri, [super.method = ApiMethod.POST]);

  setBody({
    required String clientName,
    required List<String> redirectUri,
    bool dpopBoundAccessToken = false,
    CryptoAlgorithm tokenEndpointAuthSigningAlg = CryptoAlgorithm.ES256,
    CryptoAlgorithm idTokenSignedResponseAlg = CryptoAlgorithm.ES256,
    TokenEndpointAuth tokenEndpointAuthMethod = TokenEndpointAuth.None,
  }) {
    body = {
      "client_name": clientName,
      "redirect_uris": redirectUri,
      "token_endpoint_auth_signing_alg": tokenEndpointAuthSigningAlg.name,
      "id_token_signed_response_alg": idTokenSignedResponseAlg.name,
      // TODO: tokenENdpointAuthSigningAlg に PrivateKeyJWT を使えるように
    };
  }
}
