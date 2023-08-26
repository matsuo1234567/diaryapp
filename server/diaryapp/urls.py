from django.urls import path
from . import views

urlpatterns = [
    path('img/', views.get_img, name='img'),
    path('save_text/', views.save_text, name='save_text'),
]