from django.core.management.base import BaseCommand, CommandError
from spotinder_web.models import *

from datetime import date

class Command(BaseCommand):
    help = 'Delete all stored messages for id 7'

    def handle(self, *args, **options):
        msg = Message.messages.filter(match__id=7)
        for m in msg:
            m.delete()

        self.stdout.write(self.style.SUCCESS('Successfully deleted the messages fro match id 7'))
