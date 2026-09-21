from django.db import models
from django.contrib.auth.models import User

# โมเดลเก็บข้อมูลสัตว์เลี้ยง
class Pet(models.Model):
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='pets')
    name = models.CharField(max_length=100)
    species = models.CharField(max_length=50) # หมา, แมว, นก ฯลฯ
    breed = models.CharField(max_length=100, blank=True, null=True)
    birth_date = models.DateField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} ({self.species})"

# โมเดลเก็บประวัติการดูแล
class CareLog(models.Model):
    pet = models.ForeignKey(Pet, on_delete=models.CASCADE, related_name='care_logs')
    activity_type = models.CharField(max_length=50) # Vaccine, Grooming, Vet, Medicine
    title = models.CharField(max_length=200)
    notes = models.TextField(blank=True, null=True)
    log_date = models.DateField()
    is_completed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.pet.name} - {self.title}"