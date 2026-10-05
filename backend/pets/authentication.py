from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from oidc_provider.models import Token

class OIDCBearerAuthentication(BaseAuthentication):
    """
    ดักจับ Header 'Authorization: Bearer <token>'
    แล้วนำไปค้นหา User ในฐานข้อมูลของ django-oidc-provider
    """
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return None

        parts = auth_header.split()
        if len(parts) != 2:
            return None

        raw_token = parts[1]

        try:
            token = Token.objects.get(access_token=raw_token)
            if token.has_expired():
                raise AuthenticationFailed('Token หมดอายุแล้ว')
            return (token.user, token)
        except Token.DoesNotExist:
            raise AuthenticationFailed('Token ไม่ถูกต้อง')