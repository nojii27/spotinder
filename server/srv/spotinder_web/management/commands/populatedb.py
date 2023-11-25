from django.core.management.base import BaseCommand, CommandError
from spotinder_web.models import *

from datetime import date

class Command(BaseCommand):
    help = 'Closes the specified poll for voting'

    def handle(self, *args, **options):
        user = User(username="nathan", hash="$2y$10$ttte6MeSB68YQMx0opNXCO37WkwmXd8eSWumXoP1rJ9aIDsrmY7f2")
        user.save()
        profile = Profile(description="Cherche fille facile.", localisation="BE", gender='M', dateOfBirth=date(1998, 10, 30), surname='Nathan', user=user)
        profile.save()

        user = User(username="nokhtcho", hash="$2y$10$JgLF0ogCBmWUKM1QrK5B5O1ijcfaOrwYaXd3NXdgN/7275eTUvViS")
        user.save()
        profile = Profile(description="Écoute le son pas la description, yo", localisation="BE", surname="Nokhtcho", gender="M", dateOfBirth=date(2002, 3, 20), user=user)
        profile.save()

        # user = User(username="wagner", hash="$2y$10$/z.9r1D0VK/kdbLcPjIoJu1LCM3bS.LpTyAU4PGlYolhIFesAHGj6")
        # user.save()
        # profile = Profile(description="Je cherche un homme pour ma fille", localisation="BE", user=user)
        # profile.save()

        self.stdout.write(self.style.SUCCESS('Successfully populated the db'))
