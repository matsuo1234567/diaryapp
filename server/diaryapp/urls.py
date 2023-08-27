from django.urls import path
from . import views

urlpatterns = [
    path('img/', views.get_img, name='img'),
    path('get_url/', views.get_url, name='get_url'),
    path('save_text/', views.save_text, name='save_text'),
    path('get_text/', views.get_text, name='get_text'),
]