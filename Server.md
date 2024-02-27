
### OIDC Server を立ち上げる

```
docker network create oidc-network
```

```
docker run -d -p 8080:8080 --network oidc-network -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=password --name keycloak jboss/keycloak
```

### セットアップ

[keycloak server](http://127.0.0.1:8080/)

admin console で realms に sample を追加

### 動的クライアント登録

[DCRのやり方](https://wjw465150.gitbooks.io/keycloak-documentation/content/securing_apps/topics/client-registration.html)

Realms Settings の Client Registration で Initial Access Token を発行する

OpenID Configuration からエンドポイント情報を見つける<br>
curl -sS http://127.0.0.1:8080/auth/realms/sample/.well-known/openid-configuration | jq .

``````
INITIAL_ACCESS_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJhNjg0YzkyYS0zN2E3LTRlYzAtYTgxOC0zODllZDNiZjRmNjUifQ.eyJleHAiOjE3MDg3Mzg0NTMsImlhdCI6MTcwNjE0NjQ1MywianRpIjoiMTM0OGUzYzYtZTcwOC00YzNjLTgwMDgtNTViODdjM2NiNGM1IiwiaXNzIjoiaHR0cDovLzEyNy4wLjAuMTo4MDgwL2F1dGgvcmVhbG1zL3NhbXBsZSIsImF1ZCI6Imh0dHA6Ly8xMjcuMC4wLjE6ODA4MC9hdXRoL3JlYWxtcy9zYW1wbGUiLCJ0eXAiOiJJbml0aWFsQWNjZXNzVG9rZW4ifQ.YGVnlR1q3uhB5iZl_WuFoqpm34zENwiqlgVy_1OPq28

curl -XPOST  http://127.0.0.1:8080/auth/realms/sample/clients-registrations/openid-connect \
-H "Content-Type:application/json" \
-H "Authorization: bearer $INITIAL_ACCESS_TOKEN" \
-d '{"client_name":"cli001", "redirect_uris":["http://127.0.0.1:8082/"]}'
``````
