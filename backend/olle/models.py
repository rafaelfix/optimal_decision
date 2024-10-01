"""Contains models for user, devices, sessions and tasks.

Models are defined here are then translated to the database via Djangos
ORM-implementation. To read more, visit djangos documentation aboout models
and making queries: https://docs.djangoproject.com/en/4.0/topics/db/queries/
"""

import uuid

from django.db import models


class User(models.Model):
    """User table.

    Attributes:
        user_id: User ID as a UUID.
        name: Name of the profile for this User.
        device_type: Device type as models.IntegerField where 0 = android
                     and 1 = iOS.
        teacher_email: Email of associated teacher.
        task_count: The numer of tasks associated with this User (cached).
    """

    user_id = models.UUIDField(default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=256, default="")
    device_type = models.IntegerField(default=0)
    teacher_email = models.CharField(max_length=256, default="")
    task_count = models.IntegerField(default=0)

    class Meta:
        """Django meta-class for User table.

        See: https://docs.djangoproject.com/en/4.2/ref/models/options/#model-meta-options
        """

        # NOTE: UniqueConstraint automatically creates a database index
        # as a side effect, see: https://code.djangoproject.com/ticket/24082.
        # DO NOT add an explicit index to any field that already has a unique
        # constraint. The migration system in Django does not handle this case
        # well and seems to create a duplicate index which leads to migration errors.

        constraints = [
            models.UniqueConstraint(name="user_id_constraint", fields=["user_id"])
        ]

    def __str__(self):
        """Return string representation of User table."""
        return str(self.user_id)


class AndroidDevice(models.Model):
    """Android Device table. Triggered by request from android devices.

    Attributes:
        user: User to whom the device belongs. Foreign key to User.

        Remaining attributes retrieved in Flutter with the device_info_plus
        package. Visit package site for more info:
        https://pub.dev/packages/device_info_plus
    """

    user = models.ForeignKey(User, on_delete=models.CASCADE)

    # Android build.ID
    device_id = models.CharField(max_length=256, default=None)
    board = models.CharField(max_length=256, default=None)
    brand = models.CharField(max_length=256, default=None)
    device = models.CharField(max_length=256, default=None)
    host = models.CharField(max_length=256, default=None)
    hardware = models.CharField(max_length=256, default=None)
    manufacturer = models.CharField(max_length=256, default=None)
    model = models.CharField(max_length=256, default=None)
    product = models.CharField(max_length=256, default=None)
    tags = models.CharField(max_length=256, default=None)
    type = models.CharField(max_length=256, default=None)
    # Note: Missing Android build.User and radio version

    vsdkint = models.IntegerField(default=None)
    vincremental = models.CharField(max_length=256, default=None)
    vrelease = models.CharField(max_length=256, default=None)

    def __str__(self):
        """Return string representation of Android-device."""
        return f"{self.user.user_id}: {self.device_id}"


class IOSDevice(models.Model):
    """Represent iOS device table in database.

    Attributes:
        user: User to whom the device belongs. Foreign key to User.

        Remaining attributes retrieved in Flutter with the device_info_plus
        package. Visit package site for more info:
        https://pub.dev/packages/device_info_plus
    """

    user = models.ForeignKey(User, on_delete=models.CASCADE)

    identifier_for_vendor = models.CharField(max_length=256, default=None)
    name = models.CharField(max_length=256, default=None)
    system_name = models.CharField(max_length=256, default=None)
    system_version = models.CharField(max_length=256, default=None)
    model = models.CharField(max_length=256, default=None)
    localized_model = models.CharField(max_length=256, default=None)
    utsname_machine = models.CharField(max_length=256, default=None)
    utsname_version = models.CharField(max_length=256, default=None)
    utsname_release = models.CharField(max_length=256, default=None)
    utsname_node_name = models.CharField(max_length=256, default=None)
    utsname_sysname = models.CharField(max_length=256, default=None)

    def __str__(self):
        """Return string representation of iOS device table."""
        return f"{self.user.user_id}: {self.identifier_for_vendor}"


class Session(models.Model):
    """Represents a Session.

    Attributes:
        user: User who conducted the session. Foreign key to User.
        timestamp: Start time of session as milliseconds since Unix epoch.
        session_time: Total time spent by user in milliseconds.
    """

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    timestamp = models.BigIntegerField()
    session_time = models.IntegerField()
    appversion = models.CharField(max_length=256, default=None)

    def __str__(self):
        """Representation of a Session."""
        return f"{self.user.user_id}: {self.session_time} ms"


class Task(models.Model):
    """Represents a task, also known as a question."""

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    """User who completed the task."""

    first_number = models.SmallIntegerField()
    """The first known number in the question, in left-to-right reading order.

    For example:
    * If the question is "2+4=?", then first_number is 2.
    * If the question is "3+?=7", then first_number is 3.
    """

    second_number = models.SmallIntegerField()
    """The second known number in the question, in left-to-right reading order.

    For example:
    * If the question is "2+4=?", then second_number is 4.
    * If the question is "3+?=7", then second_number is 7.
    """

    operator = models.CharField(max_length=1)
    """The operator in the question, represented as a single char."""

    user_answer = models.SmallIntegerField(null=True)
    """The user's answer to the question, if given."""

    timestamp = models.BigIntegerField()
    """Time since start of the task as milliseconds since Unix epoch."""

    visual_help = models.CharField(max_length=1, default=" ")
    """A single-char flag from optQuestions.h which determines
    the type of visual help to show for this question.
    """

    def __str__(self):
        """Representation of a task."""
        contents = (
            self.user,
            self.first_number,
            self.second_number,
            self.operator,
            self.user_answer,
            self.timestamp,
        )
        return f"{contents}"


class Keypress(models.Model):
    """Represents a keypress.

    Attributes:
        user: User who made the keypress. Foreign key to User.
        task: The task during which the key was pressed. Foreign key to Task.
        key: The key that was pressed as an ASCII character.
        timestamp: Time since start of the keypress as milliseconds since Unix epoch.
    """

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    key = models.CharField(max_length=256)
    timestamp = models.BigIntegerField()

    def __str__(self):
        """Representation of a keypress."""
        return str(self.key)


class UserManagementAccount(models.Model):
    email = models.CharField(max_length=256)
    access_code = models.BigIntegerField()

    class Meta:
        """Django meta-class for UserManagementAccount table.

        See: https://docs.djangoproject.com/en/4.2/ref/models/options/#model-meta-options
        """

        # NOTE: UniqueConstraint automatically creates a database index
        # as a side effect, see: https://code.djangoproject.com/ticket/24082.
        # DO NOT add an explicit index to any field that already has a unique
        # constraint. The migration system in Django does not handle this case
        # well and seems to create a duplicate index which leads to migration errors.

        constraints = [
            models.UniqueConstraint(name="email_constraint", fields=["email"])
        ]

    def __str__(self):
        """Representation of a UserManagementAccount."""
        return str(self.email)


class UserSynchronization(models.Model):
    name = models.CharField(max_length=256)
    account = models.ForeignKey(UserManagementAccount, on_delete=models.CASCADE)
    users = models.ManyToManyField(User)

    class Meta:
        """Django meta-class for UserSynchronization table.

        See: https://docs.djangoproject.com/en/4.2/ref/models/options/#model-meta-options
        """

        # NOTE: UniqueConstraint automatically creates a database index
        # as a side effect, see: https://code.djangoproject.com/ticket/24082.
        # DO NOT add an explicit index to any field that already has a unique
        # constraint. The migration system in Django does not handle this case
        # well and seems to create a duplicate index which leads to migration errors.

        constraints = [
            # Enforce unique names (per account, not globally)
            models.UniqueConstraint(
                name="per_account_name_constraint",
                fields=["account", "name"],
            ),
        ]

    def __str__(self):
        """Representation of a UserSynchronization."""
        return str(self.name)
