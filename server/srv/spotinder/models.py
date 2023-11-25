from django.db import models

class User(models.Model):
    username = models.CharField(max_length=50)
    hash = models.CharField(max_length=60)
    spotify_token = models.CharField()
    profile = models.OneToOneField(
        Profile,
        on_delete=models.CASCADE
    )


class Profile(models.Model):
    description = models.TextField(max_length=500)
    localisation = models.CharField('Country code', max_length=2)


class Picture(models.Model):
    data = models.TextField('base64 encoded image')
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE))


class Swipe(models.Model):
    DIRECTION = (
        ('left'),
        ('right'),
        )
    direction = models.CharField(choices=DIRECTION)
    p1 = models.ForeignKey(Profile, on_delete=models.CASCADE, verbose_name='Profile 1')
    p2 = models.ForeignKey(Profile, on_delete=models.CASCADE, verbose_name='Profile 2')


class Match(models.Model):
    p1 = models.ForeignKey(Profile, on_delete=models.CASCADE, verbose_name='Profile 1')
    p2 = models.ForeignKey(Profile, on_delete=models.CASCADE, verbose_name='Profile 2')
    accepted = models.BooleanField(default=False)


class Message(models.Model):
    match = models.ForeignKey(Match, on_delete=CASCADE)
    sender = models.ForeignKey(Profile, on_delete=CASCADE)
    content = models.TextField(max_length=1000)
    timestamp = models.DateTimeField(auto_now=True)
