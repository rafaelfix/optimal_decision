"""Links url paths to views.

To read more about urls.py and the url-dispatcher, visit djangos documentation:
https://docs.djangoproject.com/en/4.0/topics/http/urls/
"""

from django.urls import path

from . import views

urlpatterns = [
    # link path store_session/ to function store_session in views
    path("store_session/", views.store_session, name="store_session"),
    # and repeat with create_user...
    path("create_user/", views.create_user, name="add_user"),
    path("add_teacher_email/", views.add_teacher_email),
    path("send_access_code", views.send_access_code),
    path("get_user_synchronizations", views.get_user_synchronizations),
    path("add_user_synchronization", views.add_user_synchronization),
    path("get_synchronized_tasks", views.get_synchronized_tasks),
    path("", views.index, name="index"),
    path("csv/get_users", views.get_users),
    path("csv/get_user_tasks", views.get_user_tasks),
    path("csv/get_user_keypresses", views.get_user_keypresses),
    path("csv/get_user_sessions", views.get_user_sessions),
    path("csv/get_user_android_devices", views.get_user_android_devices),
    path("csv/get_user_ios_devices", views.get_user_ios_devices),
    path("csv/get_user_synchronizations", views.get_user_synchronizations_csv),
    path("csv/get_user_management_accounts", views.get_user_management_accounts),
]
