# oidc_cli
dart cli tool

## ES256の鍵作成

```
# 秘密鍵
openssl ecparam -name prime256v1 -genkey -noout > files/ES256_private.pem

# 公開鍵
openssl ec -in files/ES256_private.pem -pubout > files/ES256_public.pem
```

## コマンド実行

```
dart run
dart run :dcr
dart run :authorization
```
