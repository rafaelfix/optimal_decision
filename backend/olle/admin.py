from django.contrib import admin

import olle.models as models

admin.site.register(models.User)
admin.site.register(models.Session)
admin.site.register(models.Task)
admin.site.register(models.Keypress)
admin.site.register(models.AndroidDevice)
admin.site.register(models.IOSDevice)
