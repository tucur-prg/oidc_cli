import 'base_request.dart';
import '../generate.dart';

enum ResponseType {
  code,
}

class AuthorizationRequest extends Request {
  ApiContentType contentType = ApiContentType.Form;

  AuthorizationRequest(super.uri, [super.method = ApiMethod.GET]);

  setBody({
    required String clientId,
    required String redirectUri,
    ResponseType responseType = ResponseType.code,
    String? codeVerifier,
  }) {
    body = {
      "client_id": clientId,
      "redirect_uri": redirectUri,
      "state": createState(),
      "response_type": responseType.name,
      if (codeVerifier != null)
        "code_challenge": createCodeChallenge(codeVerifier),
      if (codeVerifier != null) "code_challenge_method": "S256",
    };
  }
}
