from django.urls import path
from . import views

urlpatterns = [
    path('img/', views.get_img, name='img'),
]