from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin

class UserManager(BaseUserManager):
    def create_user(self, uid, email=None, password=None):
        if not uid:
            raise ValueError('Users must have a Firebase UID')
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
    uid = models.CharField(max_length=128, unique=True)  # Firebase UID
    email = models.EmailField(blank=True, null=True)
    name = models.CharField(max_length=100, blank=True)
    trust_score = models.FloatField(default=0.0)
    profile_image = models.URLField(blank=True, null=True) 
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'uid'
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.name or self.uid
