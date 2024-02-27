import "dart:convert";

import "package:http/http.dart" as http;

import "package:oidc_cli/oidc_cli.dart";

main(List<String> args) async {
  ApiClient cli = ApiClient();

  // OpenID Configuration
  String realms = "sample";
  String issuer = "http://localhost:8080/auth/realms/$realms";

  ConfigurationRequest configurationReq = ConfigurationRequest.issuer(issuer);

  http.Response configurationRes = await cli.execute(configurationReq);
  if (configurationRes.hasErrorResponse()) {
    print(configurationRes.statusCode);
    print(configurationRes.body);
    return;
  }

  var configration = jsonDecode(configurationRes.body);

  // Dynamic Client Registration
  String initialAccessToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJhNjg0YzkyYS0zN2E3LTRlYzAtYTgxOC0zODllZDNiZjRmNjUifQ.eyJleHAiOjE3MDkxMDYyNTAsImlhdCI6MTcwNjUxNDI1MCwianRpIjoiZTQyMzhhNDUtOWI0OS00NDA5LWIyOGMtMDI5OTI4ODdjMmJjIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgwL2F1dGgvcmVhbG1zL3NhbXBsZSIsImF1ZCI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODA4MC9hdXRoL3JlYWxtcy9zYW1wbGUiLCJ0eXAiOiJJbml0aWFsQWNjZXNzVG9rZW4ifQ.2jv4DhqbeSH2GYyD7tskbu-4Z4XYLdTQxVqwsEu2Ato";

  DcrRequest dcrReq = DcrRequest(configration['registration_endpoint']);
  dcrReq.setAuthorization(initialAccessToken);
  dcrReq
      .setBody(clientName: "client001", redirectUri: ["http://localhost:8082"]);

  http.Response response2 = await cli.execute(dcrReq);
  if (response2.hasErrorResponse()) {
    print(response2.statusCode);
    print(response2.body);
    return;
  }

  var client = jsonDecode(response2.body);

  print("ClientID: ${client["client_id"]}");
  print("Secret: ${client["client_secret"]}");
}
