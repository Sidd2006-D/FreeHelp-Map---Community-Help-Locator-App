from rest_framework import serializers
from .models import Post, PostImage


class PostImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = PostImage
        fields = ("image",)
    def get_image(self, obj):
        request = self.context.get('request')
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)
        return obj.image.url if obj.image else None


class PostSerializer(serializers.ModelSerializer):

    images = PostImageSerializer(many=True, read_only=True)

    class Meta:
        model = Post
        fields = "__all__"
        read_only_fields = ("user", "created_at")

    def create(self, validated_data):
        # 1. Get the list of images from the request context
        # request.FILES contains the actual file objects
        request = self.context.get('request')
        files = request.FILES.getlist('images')

        if len(files) > 3:
            raise serializers.ValidationError({"images": "Maximum 3 images allowed"})

        post = Post.objects.create(**validated_data)

        for f in files:
            PostImage.objects.create(post=post, image=f)

        return post
