import firebase_admin
from firebase_admin import auth, credentials

from config.settings import FIREBASE_SERVICE_ACCOUNT

# Initialize Firebase once
if not firebase_admin._apps:
    cred = credentials.Certificate(FIREBASE_SERVICE_ACCOUNT) 
    firebase_admin.initialize_app(cred)


def verify_token(id_token):
    """
    Verify Firebase ID token and return decoded info
    """
    try:
        decoded_token = auth.verify_id_token(id_token)
        uid = decoded_token['uid']
        email = decoded_token.get('email', None)
        return {
            'uid': uid,
            'email': email
        }
    except Exception as e:
        print(f"Token verification failed: {e}")
        return None