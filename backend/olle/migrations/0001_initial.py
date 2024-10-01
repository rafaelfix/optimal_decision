# Generated by Django 5.0.1 on 2024-02-01 20:11

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='AndroidDevice',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('device_id', models.CharField(default=None, max_length=256)),
                ('board', models.CharField(default=None, max_length=256)),
                ('brand', models.CharField(default=None, max_length=256)),
                ('device', models.CharField(default=None, max_length=256)),
                ('host', models.CharField(default=None, max_length=256)),
                ('hardware', models.CharField(default=None, max_length=256)),
                ('manufacturer', models.CharField(default=None, max_length=256)),
                ('model', models.CharField(default=None, max_length=256)),
                ('product', models.CharField(default=None, max_length=256)),
                ('tags', models.CharField(default=None, max_length=256)),
                ('type', models.CharField(default=None, max_length=256)),
                ('vsdkint', models.IntegerField(default=None)),
                ('vincremental', models.CharField(default=None, max_length=256)),
                ('vrelease', models.CharField(default=None, max_length=256)),
            ],
        ),
        migrations.CreateModel(
            name='IOSDevice',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('identifier_for_vendor', models.CharField(default=None, max_length=256)),
                ('name', models.CharField(default=None, max_length=256)),
                ('system_name', models.CharField(default=None, max_length=256)),
                ('system_version', models.CharField(default=None, max_length=256)),
                ('model', models.CharField(default=None, max_length=256)),
                ('localized_model', models.CharField(default=None, max_length=256)),
                ('utsname_machine', models.CharField(default=None, max_length=256)),
                ('utsname_version', models.CharField(default=None, max_length=256)),
                ('utsname_release', models.CharField(default=None, max_length=256)),
                ('utsname_node_name', models.CharField(default=None, max_length=256)),
                ('utsname_sysname', models.CharField(default=None, max_length=256)),
            ],
        ),
        migrations.CreateModel(
            name='Keypress',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('key', models.CharField(max_length=256)),
                ('timestamp', models.BigIntegerField()),
            ],
        ),
        migrations.CreateModel(
            name='Session',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('timestamp', models.BigIntegerField()),
                ('session_time', models.IntegerField()),
                ('appversion', models.CharField(default=None, max_length=256)),
            ],
        ),
        migrations.CreateModel(
            name='Task',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('x_value', models.SmallIntegerField()),
                ('y_value', models.SmallIntegerField()),
                ('operator', models.CharField(max_length=256)),
                ('answer', models.SmallIntegerField()),
                ('timestamp', models.BigIntegerField()),
            ],
        ),
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=256)),
                ('email', models.CharField(max_length=256)),
                ('device_type', models.IntegerField(default=0)),
                ('task_count', models.IntegerField(default=0)),
            ],
        ),
        migrations.AddConstraint(
            model_name='user',
            constraint=models.UniqueConstraint(fields=('email',), name='email_constraint'),
        ),
        migrations.AddField(
            model_name='task',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='olle.user'),
        ),
        migrations.AddField(
            model_name='session',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='olle.user'),
        ),
        migrations.AddField(
            model_name='keypress',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='olle.user'),
        ),
        migrations.AddField(
            model_name='iosdevice',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='olle.user'),
        ),
        migrations.AddField(
            model_name='androiddevice',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='olle.user'),
        ),
    ]
