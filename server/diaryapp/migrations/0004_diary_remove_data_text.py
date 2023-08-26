# Generated by Django 4.2.4 on 2023-08-26 05:14

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('diaryapp', '0003_data_text'),
    ]

    operations = [
        migrations.CreateModel(
            name='Diary',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('conversation', models.CharField(max_length=1000, null=True)),
                ('diary', models.CharField(max_length=1000, null=True)),
            ],
        ),
        migrations.RemoveField(
            model_name='data',
            name='text',
        ),
    ]