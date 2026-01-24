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

# -----------------------------------------------------------------------------------------------------------------------------------------------------------
### 🟢 Phase 7: Flutter API Infrastructure & Backend Integration
## ✅ 1️⃣ Centralized API Configuration (Global Base URL)

To avoid hardcoding backend URLs across the app, a global configuration file was introduced.
```
📁 File: lib/config/app_config.dart

class AppConfig {
  static const String apiBaseUrl = "http://10.0.2.2:8000/api";
}
```

🎯 Purpose

Single source of truth for backend base URL

Switch between emulator, physical device, and production by changing one value

Prevents scattered hardcoded URLs

## ✅ 2️⃣ Centralized API Service Layer

All backend API calls are routed through a single service class.
```
📁 File: lib/services/api_service.dart

import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;
}
```

🎯 Purpose

Centralized Firebase token handling

Consistent API request pattern

Easier debugging and maintenance

Scalable for future APIs (posts, comments, ratings)

## ✅ 3️⃣ Backend /users/me/ API Integration (Flutter)

The first authenticated backend API call fetches the current user profile.
```
📁 File: lib/services/api_service.dart

static Future<AppUser> fetchCurrentUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("User not authenticated");
  }

  final token = await user.getIdToken(true);

  final response = await http.get(
    Uri.parse("$baseUrl/users/me/"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    return AppUser.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to load user profile");
  }
}
```

🎯 Purpose

Verifies Firebase token usage in Flutter

Confirms Django authentication pipeline

Retrieves user profile data (email, trust score, etc.)

## ✅ 4️⃣ Home Screen Backend Data Consumption

The Home screen now consumes authenticated backend data.
```
📁 File: lib/home/home_screen.dart
```
🧩 Logic

Calls ApiService.fetchCurrentUser() in initState

Displays backend-provided user data

Confirms Flutter ↔ Django integration

🎯 Purpose

Ensures user data comes from backend, not just Firebase

Establishes reusable API consumption pattern

✅ 5️⃣ Architecture Status After Integration

🔒 Firebase authentication fully integrated

🔗 Flutter securely communicates with Django

🧠 User data synced and reusable across app

🏗️ API infrastructure ready for scaling

🚀 Ready for Next Features

With API infrastructure finalized, the project is now ready for:

📝 Help / Post creation system

📍 Location-based filtering

💬 Comments & ratings

🔔 Notifications
# -------------------------------------------------------------------------------------------------------------------------------------------------------

### 🟢 Phase 8: Help / Post Creation System (With Images & Scheduling)
## ✅ 1️⃣ Post Creation Feature (Backend + Flutter)

Implemented a complete Help / Food / Event post creation flow with secure authentication and backend integration.

# 🎯 Features

Authenticated users can create posts

Supports multiple post types (food, help, event)

Location-aware post design

Radius-based visibility

## ✅ 2️⃣ Optional Image Upload (Max 3 Images)

Post creation now supports optional image uploads.

# 🧱 Backend Design

Separate PostImage model linked to Post

Images stored using Django ImageField

Maximum of 3 images enforced at API level

# 📱 Flutter Integration

Image selection via gallery

Preview images before upload

Multipart upload with Firebase authentication

## ✅ 3️⃣ Scheduled Posts Logic (is_active + event_time)

Implemented conditional scheduling logic for posts.

# 🧠 Business Rule

If is_active = true → post is live immediately

If is_active = false → event_time is required

#📱 Flutter Enforcement

Toggle switch for active/scheduled post

Date & time picker shown only when scheduled

Frontend validation prevents invalid submissions

# 📡 API Payload

is_active always sent

event_time sent only for scheduled posts

ISO-8601 datetime format used for backend compatibility

## ✅ 4️⃣ Centralized API Handling (Flutter)

Post creation API integrated into the existing centralized ApiService.
```
📁 File

lib/services/api_service.dart
```
🧩 Responsibilities

Firebase token retrieval

Multipart form submission

Image handling

Scheduling field mapping

## ✅ 5️⃣ Add Post Screen (Flutter UI)

A dedicated screen for creating posts was implemented.
```
📁 File

lib/screens/post/add_post_screen.dart
```
# 🧱 UI Components

Post type selector

Title & description inputs

Image picker with preview

Active/scheduled toggle

Event time picker (conditional)

Submit with loading state

## ✅ 6️⃣ Home Screen Integration

Post creation screen linked to Home screen.

🧩 Navigation

Floating Action Button (FAB) on HomeScreen

Navigates to AddPostScreen

Returns to Home after successful post creation

## ✅ 7️⃣ Validation & Stability Improvements

Additional safeguards added for production readiness.

# 🔒 Improvements

Frontend validation for scheduled posts

Controller disposal to prevent memory leaks

Disabled submit button during API calls

Error feedback via SnackBar

# 🚀 Current System Capabilities

🔐 Secure authenticated post creation

🖼️ Image-rich posts (up to 3 images)

⏰ Scheduled & live posts supported

🧠 Clean backend & frontend separation

🏗️ Scalable architecture for feeds & maps
