"""
Provides an interface for the view toward the database-models in models.py.

Functions here are called from the view-module and interact with the models in
the models-module.
"""

import logging
import secrets
import uuid
from enum import IntEnum
from typing import Optional

from django.contrib.auth.models import User as AuthUser
from django.db.models import QuerySet

import olle.models as models


class DeviceType(IntEnum):
    """Enums for operating systems."""

    ANDROID = 0
    IOS = 1


def add_user(user_id: str | uuid.UUID, name: str, device_type: int, **_) -> models.User:
    """Add user entry to database.

    Args:
        user_id (str | uuid.UUID): User ID, which can be a string or a UUID.
        device_type (int): Android=0, IOS=1.

    Returns:
        models.User: The created user model object.
    """
    # If user_id is a string, convert it to UUID
    if isinstance(user_id, str):
        user_id = uuid.UUID(user_id)

    logging.info(
        f"Adding new user ==>\n\t"
        f"User ID: \t\t{user_id}\n\t"
        f"User name: \t\t{name}\n\t"
        f"Device type: \t\t{device_type}\n"
    )

    user = models.User(
        user_id=user_id,
        name=name,
        device_type=device_type,
        task_count=0,
    )
    user.save()
    return user


def add_android_device(user: models.User, device_info: dict) -> models.AndroidDevice:
    """Add Android-device entry to database.

    Args:
        user (models.User): User associated with device.
        device_info (dict): Dictionary containing android device information.

    Returns:
        models.AndroidService: The created device model object.
    """
    logging.info(
        f"Adding Android device ==>\n\t"
        f"User ID: \t\t{user.user_id}\n\t"
        f"Device id: \t\t{device_info['device_id']}\n"
    )
    device = models.AndroidDevice(user=user, **device_info)

    device.save()
    return device


def add_ios_device(user: models.User, device_info: dict) -> models.IOSDevice:
    """Add iOS-device entry to database.

    Args:
        user (models.User): User associated with device.
        device_info (dict): Dictionary containing iOS device information.

    Returns:
        models.IOSDevice: The created device model object.
    """
    logging.info(
        f"Adding iOS device ==>\n\t"
        f"User ID: \t\t{user.user_id}\n\t"
        f"Device id: \t\t{device_info['identifier_for_vendor']}\n"
    )
    device = models.IOSDevice(user=user, **device_info)

    device.save()
    return device


def add_session(
    user: models.User,
    tasks: list[dict],
    client_start_time: int,
    client_end_time: int,
    **_,
) -> models.Session:
    """Add a user session to database.

    Args:
        user (models.User): User who conducted the session.
        user_start_time (str): datetime object of session start time as
                               received from user device.
        user_end_time (str): datetime object of session start time as received
                             from user device.

    Raises:
        ValueError: If given session time interval is invalid

    Returns:
        models.Session: The created session model object.
    """
    if client_start_time > client_end_time:
        raise ValueError("Session start time cannot be after end time")

    session_time = client_end_time - client_start_time

    session = models.Session(
        user=user,
        timestamp=client_start_time,
        session_time=session_time,
        appversion="0.2",
    )

    tasks = create_tasks(user, tasks)

    logging.info(f"Adding session ==>\n\t" f"Session time: \t\t{session_time}\n")

    session.save()

    for task in tasks:
        task["Task"].save()

        for keypress in task["Keypresses"]:
            keypress.save()

    # user.task_count += len(tasks)

    return session


def create_tasks(user: models.User, tasks: list[dict]) -> list[dict]:
    """Add a list of tasks to the database.

    Args:
        user (models.User): User entry model which the tasks relates to.
        session (models.Session): Session model relating to the
                                  current session.
        tasks (list[dict]): List of tasks with associated keypresses.
    """
    db_tasks = []
    for task in tasks:
        task_model = create_task(user=user, **task)
        db_keypresses = []
        for keypress in task["KeypressList"]:
            db_keypresses.append(create_keypress(user=user, **keypress))
        db_tasks.append({"Task": task_model, "Keypresses": db_keypresses})
    return db_tasks


def create_task(
    user: models.User,
    first_number: int,
    second_number: int,
    operator: str,
    user_answer: int | None,
    visual_help: str,
    timestamp: int,
    **_,
) -> models.Task:
    """Create a completed task without adding it to the database.

    Args:
        user (models.User): User who completed the task.
        session (models.Session): Session in which the user completed the task.
        first_number (int): The first known number in the question,
                            in left-to-right reading order.
        second_number (int): The second known number in the question,
                             in left-to-right reading order.
        operator (str): The operator in the question,
                        represented as a single char (see optQuestions.h).
        user_answer (int | None): The user's answer to the question, if given.
        time_offset (str): The time offset given, in millliseconds.
        visual_help (str): The visual help flag from optQuestions.h.

    Returns:
        models.Task: The created task model object.
    """
    task = models.Task(
        user=user,
        first_number=first_number,
        second_number=second_number,
        operator=operator,
        user_answer=user_answer,
        timestamp=timestamp,
        visual_help=visual_help,
    )
    # update task count
    user.task_count += 1
    user.save()

    return task


def create_keypress(
    user: models.User, timestamp: int, key: int, **_
) -> models.Keypress:
    """Create a user keypress without adding it to the database.

    Args:
        user (models.User): User who made the keypress.
        session (models.Session): Session in which the keypress was made.
        task (models.Task): Task in which the keypress was made.
        time_offset (timedelta): datetime instance of time since last keypress
                                (or start of session if first keypress in task)
        key (int): The key that was pressed.

    Returns:
        models.Keypress: The created keypress model object.
    """
    keypress = models.Keypress(user=user, timestamp=timestamp, key=key)

    return keypress


def db_users(synchronization_pk: Optional[str]) -> QuerySet[models.User]:
    """Get users in the database.

    Args:
        synchronization_pk (list[str]): The user synchronization to get
        users for. Can be None, in which case all users are fetched.


    Returns:
        QuerySet[models.User]: A QuerySet of the requested users in the database.
    """
    if synchronization_pk is None:
        logging.info("Fetching all users from database.")
        return models.User.objects.all()
    else:
        logging.info(
            f"Fetching users in synchronization {synchronization_pk} from database."
        )
        return models.User.objects.filter(usersynchronization__id=synchronization_pk)


def db_user_sessions(user_pks: list[str]) -> QuerySet[models.Session]:
    """Get all sessions for a user.

    Args:
        user_pks (list[str]): The user IDs to get sessions for.

    Returns:
        QuerySet[models.Session]: A QuerySet of all sessions for the user.
    """
    logging.info(f"Fetching all sessions for user {user_pks}.")
    return models.Session.objects.filter(user_id__in=user_pks)


def db_user_tasks(user_pks: list[str]) -> QuerySet[models.Task]:
    """Get all tasks for a user.

    Args:
        user_pks (list[str]): The user IDs to get tasks for.

    Returns:
        QuerySet[models.Task]: A QuerySet of all tasks for the user.
    """
    logging.info(f"Fetching all tasks for users {user_pks}.")
    return models.Task.objects.filter(user_id__in=user_pks)


def db_user_keypresses(user_pks: list[str]) -> QuerySet[models.Keypress]:
    """Get all keypresses for a user.

    Args:
        user_pks (list[str]): The user IDs to get keypresses for.

    Returns:
        QuerySet[models.Keypress]: A QuerySet of all keypresses for the user.
    """
    return models.Keypress.objects.filter(user_id__in=user_pks)


def get_user(user_id: str | uuid.UUID) -> models.User:
    """Fetch a specific user.

    Args:
        user_id (str | uuid.UUID): The ID or user object of the user to fetch.

    Returns:
        models.User: The user object fetched from the database.

    Raises:
        RuntimeError: If the user is not found in the database.
    """
    try:
        user = models.User.objects.get(user_id=user_id)
    except NameError as e:
        raise RuntimeError("User not in database.") from e

    return user


def create_account(email: str) -> models.UserManagementAccount:
    logging.info(f"Adding new UserManagementAccount ==>\n\t" f"email: \t\t{email}\n\t")

    # Generate the 6-digit access code used for email verification
    access_code = secrets.randbelow(1000000)
    account = models.UserManagementAccount(
        email=email,
        access_code=access_code,
    )
    account.save()
    return account


def verify_account_access_code(
    account: models.UserManagementAccount,
    access_code: int,
) -> bool:
    return account.access_code == access_code


def create_user_synchronization(
    account: models.UserManagementAccount,
    name: str,
) -> models.UserSynchronization:
    logging.info(f"Adding new UserSynchronization ==>\n\t" f"name: \t\t{name}\n\t")

    synchronization = models.UserSynchronization(
        account=account,
        name=name,
    )
    synchronization.save()
    return synchronization


def authenticate(username: str, password: str) -> bool:
    """Authenticate a django admin user.

    Args:
        username (str): The username of the admin user.
        password (str): The password of the admin user.

    Returns:
        bool: True if the admin user is authenticated, false otherwise.
    """
    user = AuthUser.objects.filter(username=username)
    if not user.exists():
        return False
    return user.get().check_password(password)


def db_user_android_devices(user_pks: list[str]) -> QuerySet[models.AndroidDevice]:
    """Get all Android devices for a user.

    Args:
        user_pks (list[str]): The user IDs to get devices for.

    Returns:
        QuerySet[models.AndroidDevice]: A QuerySet of all devices for the user.
    """
    logging.info(f"Fetching all Android devices for users {user_pks}.")
    return models.AndroidDevice.objects.filter(user_id__in=user_pks)


def db_user_ios_devices(user_pks: list[str]) -> QuerySet[models.IOSDevice]:
    """Get all iOS devices for a user.

    Args:
        user_pks (list[str]): The user IDs to get devices for.

    Returns:
        QuerySet[models.IOSDevice]: A QuerySet of all devices for the user.
    """
    logging.info(f"Fetching all iOS devices for users {user_pks}.")
    return models.IOSDevice.objects.filter(user_id__in=user_pks)


def db_user_synchronizations(
    account_pks: list[str],
) -> QuerySet[models.UserSynchronization]:
    """Get all user synchronizations for a set of accounts.

    Args:
        account_pks (list[str]): The account IDs to get synchronizations for.

    Returns:
        QuerySet[models.UserSynchronization]: A QuerySet of all synchronizations
        for the accounts.
    """
    logging.info(f"Fetching all user synchronizations for accounts {account_pks}.")
    return models.UserSynchronization.objects.filter(account_id__in=account_pks)


def db_user_management_accounts() -> QuerySet[models.UserManagementAccount]:
    """Get all user management accounts.

    Returns:
        QuerySet[models.UserManagementAccount]: A QuerySet of all management accounts.
    """
    logging.info("Fetching all user management accounts.")
    return models.UserManagementAccount.objects.all()
