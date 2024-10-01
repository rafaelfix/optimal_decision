from django.core.mail import send_mail
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = "Sends an email to the specified address"

    def add_arguments(self, parser):
        parser.add_argument("email", type=str)

    def handle(self, *args, **options):
        email: str = options["email"]

        send_mail(
            subject="Optimalmeasurements test",
            message="Hej!\n\nDetta är ett testutskick från optimalmeasurements.",
            recipient_list=[email],
            from_email=None,  # Uses DEFAULT_FROM_EMAIL
        )

        self.stdout.write(self.style.SUCCESS(f"Sent an email to {email}"))
