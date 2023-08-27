from django.urls import path
from . import views

urlpatterns = [
    path('img/', views.get_img, name='img'),
    path('get_url/', views.get_url, name='get_url'),
    path('get_text/', views.get_text, name='get_text'),
    path('save_user/', views.save_user_data, name='save_user_data'),
    path('get_user/', views.get_user, name='get_user'),
    path('make_diary/', views.make_diary, name='make_diary'),
]