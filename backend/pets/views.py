from rest_framework import viewsets, permissions
from .models import Pet, CareLog
from .serializers import PetSerializer, CareLogSerializer

class PetViewSet(viewsets.ModelViewSet):
    serializer_class = PetSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # ดึงเฉพาะสัตว์เลี้ยงของผู้ใช้ที่กำลังล็อกอินอยู่เท่านั้น
        return Pet.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

class CareLogViewSet(viewsets.ModelViewSet):
    serializer_class = CareLogSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # ดึงรายการดูแลเฉพาะสัตว์เลี้ยงของตนเอง
        return CareLog.objects.filter(pet__owner=self.request.user)