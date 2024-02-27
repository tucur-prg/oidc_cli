import 'base_request.dart';

class ConfigurationRequest extends Request {
  ConfigurationRequest(super.uri, [super.method = ApiMethod.GET]);

  ConfigurationRequest.issuer(String issuer, [ApiMethod method = ApiMethod.GET])
      : super("$issuer/.well-known/openid-configuration", method);
}
