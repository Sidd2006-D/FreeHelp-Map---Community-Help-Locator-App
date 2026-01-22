from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status



class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        return Response({
            'uid': user.uid,
            'email': user.email,
            'name': user.name,
            'profile_image': user.profile_image,
            'trust_score': user.trust_score,
        })

class UpdateProfileImageView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        image_url = request.data.get('profile_image')

        if not image_url:
            return Response(
                {'error': 'profile_image is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        request.user.profile_image = image_url
        request.user.save()

        return Response({
            'message': 'Profile image updated successfully',
            'profile_image': image_url
        })
