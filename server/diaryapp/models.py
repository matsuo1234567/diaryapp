from django.db import models
# Create your models here.
class Data(models.Model):
    url = models.CharField(max_length=255, null=True)

class Diary(models.Model):
    diary = models.TextField(null=True)
    created_at = models.DateTimeField(auto_now_add=True)

class User(models.Model):
    data = models.JSONField()