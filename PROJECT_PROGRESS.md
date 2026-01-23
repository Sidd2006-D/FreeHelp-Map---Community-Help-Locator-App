##### 📌 FreeHelp Map — Backend + Authentication Progress Summary

# This document records all completed steps, files, and logic implemented so far in the FreeHelp Map – Community Help Locator App project.

### 🔹 Phase 1: Project Setup
## 1️⃣ Backend Folder Structure
backend/
├── apps/
│   └── accounts/
├── common/
├── config/
├── manage.py


Purpose

apps/ → Django domain apps

common/ → shared utilities (Firebase auth)

config/ → project settings

### 🔹 Phase 2: Firebase Integration (Backend)
## 2️⃣ Firebase Service Account Configuration

Firebase Admin SDK JSON downloaded from Firebase Console

Path stored in Django settings
```
File: config/settings.py

FIREBASE_SERVICE_ACCOUNT = BASE_DIR / "firebase_service_account.json"
```

Purpose

Used by Django backend to verify Firebase ID tokens

## 3️⃣ Firebase Admin Initialization & Token Verification
```
File: common/firebase_auth.py

import firebase_admin
from firebase_admin import auth, credentials
from django.conf import settings

if not firebase_admin._apps:
    cred = credentials.Certificate(settings.FIREBASE_SERVICE_ACCOUNT)
    firebase_admin.initialize_app(cred)


def verify_token(id_token):
    try:
        decoded = auth.verify_id_token(id_token)
        return {
            "uid": decoded["uid"],
            "email": decoded.get("email"),
        }
    except Exception as e:
        print("Token verification failed:", e)
        return None
```

Logic

Initializes Firebase Admin only once

Verifies Firebase ID token

Extracts uid and email

### 🔹 Phase 3: Custom User Model (Firebase-based)
## 4️⃣ Custom User Model Definition

```File: apps/accounts/models.py

from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin


class UserManager(BaseUserManager):
    def create_user(self, uid, email=None, password=None):
        if not uid:
            raise ValueError("Users must have a Firebase UID")
        user = self.model(uid=uid, email=email)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, uid, email=None, password=None):
        user = self.create_user(uid, email, password)
        user.is_staff = True
        user.is_superuser = True
        user.save(using=self._db)
        return user


class User(AbstractBaseUser, PermissionsMixin):
    uid = models.CharField(max_length=128, unique=True)
    email = models.EmailField(blank=True, null=True)
    name = models.CharField(max_length=100, blank=True)
    trust_score = models.FloatField(default=0.0)
    profile_image = models.URLField(blank=True, null=True)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = "uid"
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.name or self.uid
```

Logic

Firebase UID is the primary identifier

No username-based login

Ready for trust score & profile image features

## 5️⃣ Register Custom User Model
```
File: config/settings.py

AUTH_USER_MODEL = "accounts.User"
```
###🔹 Phase 4: Firebase Authentication (DRF)
## 6️⃣ Firebase Authentication Class
```
File: common/firebase_authentication.py

from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

from common.firebase_auth import verify_token
from apps.accounts.models import User


class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get("Authorization")

        if not auth_header:
            return None

        if not auth_header.startswith("Bearer "):
            raise AuthenticationFailed("Invalid authorization header")

        id_token = auth_header.split(" ")[1]
        decoded_token = verify_token(id_token)

        if not decoded_token:
            raise AuthenticationFailed("Invalid Firebase token")

        uid = decoded_token["uid"]
        email = decoded_token.get("email")

        user, _ = User.objects.get_or_create(
            uid=uid,
            defaults={"email": email},
        )

        return (user, None)
```

Logic

Reads Authorization: Bearer <token>

Verifies Firebase token

Auto-creates user on first login

Attaches authenticated user to request

## 7️⃣ Register Firebase Authentication Globally
```
File: config/settings.py

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "common.firebase_authentication.FirebaseAuthentication",
    ),
}
```

Effect

All protected APIs now use Firebase authentication

### 🔹 Phase 5: API Testing
## 8️⃣ Test API Endpoint

Example request:
```
GET /api/users/me/
```

Headers:
```
Authorization: Bearer <FIREBASE_ID_TOKEN>
```

Result

Token verified

User authenticated

User auto-created in database

## 9️⃣ Database Verification

Sample row:
```
id | uid | email | trust_score
1  | WP1GvqNrAveTdUqlYVgAp959NDR2 | anujmars@gmail.com | 0

```
Confirms:

Firebase UID stored

Email saved

Trust score initialized

### 🔹 Phase 6: Flutter Authentication
## 🔟 Firebase Setup (Flutter)

Firebase project created

Android app registered

google-services.json added

Firebase initialized successfully

## 1️⃣1️⃣ Login Logic (Flutter)
```
File: login_screen.dart

await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: emailController.text.trim(),
  password: passwordController.text.trim(),
);

final user = FirebaseAuth.instance.currentUser;
final token = await user!.getIdToken(true);

print("FIREBASE TOKEN: $token");

```
Logic

Firebase handles authentication

ID token generated

Token sent to Django backend

## 1️⃣2️⃣ Logout Logic
```
File: home_screen.dart

await FirebaseAuth.instance.signOut();
```
## ✅ Current Project Status
✔ Completed

Firebase authentication (Flutter)

Firebase token verification (Django)

Custom User model

Auto user creation

Backend secured

API testing successful

## ❌ Pending

Auto-login flow

User profile API

Help/Post system

Comments & ratings

Distance-based filtering

Notifications

🎯 Current Position

Authentication foundation is complete, stable, and production-ready.
All future features will build on top of this.
