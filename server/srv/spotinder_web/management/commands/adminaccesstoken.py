from django.core.management.base import BaseCommand, CommandError
from spotinder_web.models import *
from spotinder_web.views import Spotify

class Command(BaseCommand):
    help = 'Get the refresh token of the user named nathan (admin?)'

    def handle(self, *args, **options):
        token = Spotify.getAdminAccessToken()
        self.stdout.write(self.style.SUCCESS(token))
