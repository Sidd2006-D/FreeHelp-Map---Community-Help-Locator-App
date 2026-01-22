from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from django.conf import settings

from common.firebase_auth import verify_token
from apps.accounts.models import User


class FirebaseAuthentication(BaseAuthentication):
    """
    Authenticate requests using Firebase ID Token
    """

    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')

        if not auth_header:
            return None  # No auth provided

        if not auth_header.startswith('Bearer '):
            raise AuthenticationFailed('Invalid authorization header')

        id_token = auth_header.split(' ')[1]
        decoded_token = verify_token(id_token)

        if not decoded_token:
            raise AuthenticationFailed('Invalid Firebase token')

        uid = decoded_token['uid']
        email = decoded_token.get('email')

        user, created = User.objects.get_or_create(
            uid=uid,
            defaults={'email': email}
        )

        return (user, None)
