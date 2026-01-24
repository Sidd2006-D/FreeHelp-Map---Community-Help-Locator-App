from django.db import models
from apps.accounts.models import User


class Post(models.Model):
    POST_TYPE_CHOICES = (
        ("food", "Food"),
        ("medical", "Medical"),
        ("help", "Help"),
        ("event", "Event"),
    )

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="posts")
    post_type = models.CharField(max_length=10, choices=POST_TYPE_CHOICES)
    title = models.CharField(max_length=150)
    description = models.TextField()

    latitude = models.FloatField()
    longitude = models.FloatField()
    visibility_radius_km = models.PositiveIntegerField(default=2)

    event_time = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.post_type} - {self.title}"


class PostImage(models.Model):
    post = models.ForeignKey(
        Post, on_delete=models.CASCADE, related_name="images"
    )
    image = models.ImageField(upload_to="post_images/")
    created_at = models.DateTimeField(auto_now_add=True)
