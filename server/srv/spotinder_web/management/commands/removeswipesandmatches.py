from django.core.management.base import BaseCommand, CommandError
from spotinder_web.models import *

from datetime import date

class Command(BaseCommand):
    help = 'Delete all stored swipes and matches'

    def handle(self, *args, **options):
        swipes = Swipe.swipes.all()
        for s in swipes:
            s.delete()

        matches = Match.matches.all()
        for m in matches:
            m.delete()

        props = ProfileProposition.propositions.all()
        for p in props:
            p.delete()

        self.stdout.write(self.style.SUCCESS('Successfully deleted the swipes and matches'))
