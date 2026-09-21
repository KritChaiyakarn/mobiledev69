from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PetViewSet, CareLogViewSet

router = DefaultRouter()
router.register(r'pets', PetViewSet, basename='pet')
router.register(r'care-logs', CareLogViewSet, basename='carelog')

urlpatterns = [
    path('', include(router.urls)),
]