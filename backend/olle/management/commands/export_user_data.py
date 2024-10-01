from django.core.exceptions import ObjectDoesNotExist
from django.core.management.base import BaseCommand, CommandError

from olle.database import get_user, serialize_user_data


class Command(BaseCommand):
    help = "Exports all data for some user for analysis."

    def add_arguments(self, parser):
        parser.add_argument("email", type=str)

    def handle(self, *args, **options):
        email = options["email"]
        try:
            user = get_user(email=email)
        except ObjectDoesNotExist as e:
            raise CommandError(f"User {email} does not exist") from e

        path = serialize_user_data(user=user)
        self.stdout.write(self.style.SUCCESS(f"Exported userdata to {path}"))
