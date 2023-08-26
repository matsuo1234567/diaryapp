from django.db import models

# Create your models here.
class Data(models.Model):
    img = models.ImageField(upload_to="img/", null=True)