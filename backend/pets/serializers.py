from rest_framework import serializers
from .models import Pet, CareLog

class CareLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = CareLog
        fields = '__all__'

class PetSerializer(serializers.ModelSerializer):
    care_logs = CareLogSerializer(many=True, read_only=True)

    class Meta:
        model = Pet
        fields = '__all__'
        read_only_fields = ('owner',)