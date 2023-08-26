from django.db import models
# Create your models here.
class Data(models.Model):
    img = models.ImageField(upload_to="img/", null=True)

class Diary(models.Model):
    diary = models.TextField(null=True)
    created_at = models.DateTimeField(auto_now_add=True)