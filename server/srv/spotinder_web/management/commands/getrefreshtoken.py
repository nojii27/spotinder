from django.core.management.base import BaseCommand, CommandError
from spotinder_web.models import *

class Command(BaseCommand):
    help = 'Get the refresh token of the user named nathan (admin?)'

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE(options['username']))
        token = User.users.get(username=options['username']).spotify_token
        self.stdout.write(self.style.SUCCESS(token))

    def add_arguments(self, parser):
        parser.add_argument('username', type=str)
