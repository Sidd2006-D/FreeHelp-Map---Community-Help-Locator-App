from django.urls import path
from .views import MeView, UpdateProfileImageView

urlpatterns = [
    path('me/', MeView.as_view(), name='me'),
    path('profile-image/', UpdateProfileImageView.as_view(), name='profile-image'),
]
