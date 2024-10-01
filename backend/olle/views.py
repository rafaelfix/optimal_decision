"""Contains the view-functions, returns the response back to the user.

The view functions handle requests and return an appropriate response.
To learn more about views, read about it in djangos documentation here:
https://docs.djangoproject.com/en/4.0/topics/http/views/
"""

import csv
import json
import smtplib
import uuid
from json import JSONDecodeError

from django.core.exceptions import ObjectDoesNotExist
from django.core.mail import send_mail
from django.db.models import QuerySet
from django.http import (
    HttpRequest,
    HttpResponse,
    HttpResponseBadRequest,
    HttpResponseForbidden,
    HttpResponseNotFound,
    HttpResponseServerError,
    JsonResponse,
)
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods

import olle.models as models
from olle.database import (
    DeviceType,
    add_android_device,
    add_ios_device,
    add_session,
    add_user,
    authenticate,
    create_account,
    create_user_synchronization,
    db_user_android_devices,
    db_user_ios_devices,
    db_user_keypresses,
    db_user_management_accounts,
    db_user_sessions,
    db_user_synchronizations,
    db_user_tasks,
    db_users,
    get_user,
    verify_account_access_code,
)
from olle.validity_check import (
    check_add_session_data,
    check_add_teacher_email_data,
    check_add_user_synchronization_data,
    check_create_user_data,
    check_get_synchronized_tasks_data,
    check_get_user_synchronizations_data,
    check_send_access_code_data,
)


def index(request):
    return HttpResponse("Hello, world 😂")


@csrf_exempt
def store_session(request):
    """Handle request to store a user session.

    Args:
        request (HttpRequest): The request object, contains information sent.

    Returns:
        HttpResponse: The response object, contains the response.
    """
    try:
        data = json.loads(request.body.decode("utf-8"))
    except JSONDecodeError:
        return HttpResponseBadRequest("Unable to parse request")

    if not check_add_session_data(data):
        return HttpResponseBadRequest("Bad add session request", status=400)

    user_id = data["User"]["user_id"]

    try:
        user = get_user(user_id)
    except (NameError, ObjectDoesNotExist):
        return HttpResponseBadRequest("User not in database", status=400)

    try:
        add_session(user, data.get("TaskList"), **data.get("Session"))
    except ValueError:
        return HttpResponseBadRequest("Invalid session time", status=400)

    return JsonResponse({"task_count": user.task_count}, status=200)


@csrf_exempt
def create_user(request):
    """Handle request to add new user in the database.

    Args:
        request (HttpRequest): The request object, contains information sent.

    Returns:
        HttpResponse: The response object, contains the response.
    """
    try:
        data = json.loads(request.body.decode("utf-8"))
    except JSONDecodeError:
        return HttpResponseBadRequest("Unable to parse request", status=400)

    if not check_create_user_data(data):
        return HttpResponseBadRequest("Bad create user request", status=400)

    try:
        user_data = data.get("User")
        user = add_user(user_id=uuid.uuid4(), **user_data)
    except RuntimeError:
        return HttpResponseBadRequest("User already exists", status=409)

    if user.device_type == DeviceType.ANDROID:
        add_android_device(user, data.get("DeviceInfo"))
    else:
        add_ios_device(user, data.get("DeviceInfo"))

    return JsonResponse({"user_id": user.user_id}, status=200)


@require_http_methods(["POST"])
@csrf_exempt
def add_teacher_email(request: HttpRequest):
    try:
        data = json.loads(request.body.decode("utf-8"))
    except JSONDecodeError:
        return HttpResponseBadRequest("Unable to parse add_teacher_email request")

    if not check_add_teacher_email_data(data):
        return HttpResponseBadRequest("Bad add_teacher_email request")

    user_id = data.get("user_id")
    teacher_email = data.get("teacher_email")

    try:
        user = get_user(user_id)
    except (NameError, ObjectDoesNotExist):
        return HttpResponseNotFound("User not in database")

    user.teacher_email = teacher_email
    user.save()
    return HttpResponse(status=200)


@csrf_exempt
@require_http_methods(["POST"])
def get_users(request: HttpRequest):
    try:
        username = request.GET["username"]
        password = request.GET["password"]
        synchronization_pk = request.GET.get("synchronization_pk", None)
    except KeyError:
        return HttpResponseBadRequest("Unable to parse get_users request")

    if not authenticate(username, password):
        return HttpResponse("Unauthorized", status=401)

    res = HttpResponse(content_type="text/csv", status=200)
    writer = csv.writer(res)
    users = db_users(synchronization_pk)
    for user in users:
        writer.writerow(
            [
                user.pk,
                user.name,
                user.device_type,
                user.teacher_email,
                user.task_count,
                user.user_id,
            ]
        )
    return res


@csrf_exempt
@require_http_methods(["POST"])
def get_user_tasks(request: HttpRequest):
    try:
        username = request.GET["username"]
        password = request.GET["password"]
        user_pks = request.GET["user_pks"].split(",")
    except KeyError:
        return HttpResponseBadRequest("Unable to parse get_user_tasks request")

    if not authenticate(username, password):
        return HttpResponse("Unauthorized", status=401)

    res = HttpResponse(content_type="text/csv", status=200)
    writer = csv.writer(res)
    tasks = db_user_tasks(user_pks)
    for task in tasks:
        writer.writerow(
            [
                task.pk,
                task.user_id,
                task.first_number,
                task.second_number,
                task.operator,
                task.timestamp,
                task.visual_help,
                task.user_answer,
            ]
        )
    return res


@csrf_exempt
@require_http_methods(["POST"])
def get_user_keypresses(request: HttpRequest):
    try:
        username = request.GET["username"]
        password = request.GET["password"]
        user_pks = request.GET["user_pks"].split(",")
    except KeyError:
        return HttpResponseBadRequest("Unable to parse get_user_keypresses request")

    if not authenticate(username, password):
        return HttpResponse("Unauthorized", status=401)

    res = HttpResponse(content_type="text/csv", status=200)
    writer = csv.writer(res)
    keypresses = db_user_keypresses(user_pks)
    for keypress in keypresses:
        writer.writerow(
            [
                keypress.pk,
                keypress.user_id,
                keypress.key,
                keypress.timestamp,
            ]
        )
    return res


@csrf_exempt
@require_http_methods(["POST"])
def get_user_sessions(request: HttpRequest):
    try:
        username = request.GET["username"]
        password = request.GET["password"]
        user_pks = request.GET["user_pks"].split(",")
    except KeyError:
        return HttpResponseBadRequest("Unable to parse get_user_sessions request")

    if not authenticate(username, password):
        return HttpResponse("Unauthorized", status=401)

    res = HttpResponse(content_type="text/csv", status=200)
    writer = csv.writer(res)
    sessions = db_user_sessions(user_pks)
    for session in sessions:
        writer.writerow(
            [
                session.pk,
                session.user_id,
                session.timestamp,
                session.session_time,
                session.appversion,
            ]
        )
    return res


@csrf_exempt
@require_http_methods(["POST"])
def get_user_android_devices(request: HttpRequest):
    try:
        username = request.GET["username"]
        password = request.GET["password"]
        user_pks = request.GET["user_pks"].split(",")
    except KeyError:
        return HttpResponseBadRequest(
            "Unable to parse get_user_android_devices request"
        )

    if not authenticate(username, password):
        return HttpResponse("Unauthorized", status=401)

    res = HttpResponse(content_type="text/csv", status=200)
    writer = csv.writer(res)
    devices = db_user_android_devices(user_pks)
    for device in devices:
        writer.writerow(
            [
                device.pk,
                device.user_id,
                device.device_id,
                device.board,
                device.brand,
                device.device,
                device.host,
                device.hardware,
                device.manufacturer,
                device.model,
                device.product,
                device.tags,
                device.type,
                device.vsdkint,
                device.vincremental,
                device.vrelease,
            ]
        )
    return res


@csrf_exempt
@require_http_methods(["POST"])
def get_user_ios_devices(request: HttpRequest):
    try:
        username = request.GET["username"]
        password = request.GET["password"]
        user_pks = request.GET["user_pks"].split(",")
    except KeyError:
        return HttpResponseBadRequest("Unable to parse get_user_ios_devices request")

    if not authenticate(username, password):
        return HttpResponse("Unauthorized", status=401)

    res = HttpResponse(content_type="text/csv", status=200)
    writer = csv.writer(res)
    devices: QuerySet[models.IOSDevice] = db_user_ios_devices(user_pks)
    for device in devices:
        writer.writerow(
            [
                device.pk,
                device.user_id,
                device.identifier_for_vendor,
                device.name,
                device.system_name,
                device.system_version,
                device.model,
                device.localized_model,
                device.utsname_machine,
                device.utsname_version,
                device.utsname_release,
                device.utsname_node_name,
                device.utsname_sysname,
            ]
        )
    return res


@csrf_exempt
@require_http_methods(["POST"])
def get_user_synchronizations_csv(request: HttpRequest):
    try:
        username = request.GET["username"]
        password = request.GET["password"]
        account_pks = request.GET["account_pks"].split(",")
    except KeyError:
        return HttpResponseBadRequest(
            "Unable to parse get_user_synchronizations request"
        )

    if not authenticate(username, password):
        return HttpResponse("Unauthorized", status=401)

    res = HttpResponse(content_type="text/csv", status=200)
    writer = csv.writer(res)
    synchronizations: QuerySet[models.UserSynchronization] = db_user_synchronizations(
        account_pks
    )
    for synchronization in synchronizations:
        writer.writerow(
            [
                synchronization.pk,
                synchronization.account_id,
                synchronization.name,
            ]
        )
    return res


@csrf_exempt
@require_http_methods(["POST"])
def get_user_management_accounts(request: HttpRequest):
    try:
        username = request.GET["username"]
        password = request.GET["password"]
    except KeyError:
        return HttpResponseBadRequest(
            "Unable to parse get_user_management_accounts request"
        )

    if not authenticate(username, password):
        return HttpResponse("Unauthorized", status=401)

    res = HttpResponse(content_type="text/csv", status=200)
    writer = csv.writer(res)
    accounts: QuerySet[models.UserManagementAccount] = db_user_management_accounts()

    for account in accounts:
        writer.writerow(
            [
                account.pk,
                account.email,
                account.access_code,
            ]
        )
    return res


@csrf_exempt
@require_http_methods(["POST"])
def send_access_code(request: HttpRequest):
    try:
        data = json.loads(request.body.decode("utf-8"))
    except JSONDecodeError:
        return HttpResponseBadRequest("Unable to parse send_access_code request")

    if not check_send_access_code_data(data):
        return HttpResponseBadRequest("Bad send_access_code request")

    email = data.get("email")

    try:
        account = models.UserManagementAccount.objects.get(email=email)
    except ObjectDoesNotExist:
        account = create_account(email)

    try:
        send_token_mail(account, account.access_code)
        return HttpResponse(status=200)
    except smtplib.SMTPException:
        return HttpResponseServerError("Unable to send email")


def send_token_mail(account: models.UserManagementAccount, access_code: int):
    # Note the use of the :06 format specifier (we have a 6-digit code).
    # We want to display the code as "002378" instead of "2378", for example.
    send_mail(
        subject="Your account verification code",
        message=(
            f"Here is your account verification code: {access_code:06}\n\n"
            + "Paste it into the app to activate your account."
        ),
        recipient_list=[account.email],
        from_email=None,  # Uses DEFAULT_FROM_EMAIL
    )


@csrf_exempt
@require_http_methods(["POST"])
def get_user_synchronizations(request: HttpRequest):
    try:
        data = json.loads(request.body.decode("utf-8"))
    except JSONDecodeError:
        return HttpResponseBadRequest(
            "Unable to parse get_user_synchronizations request"
        )

    if not check_get_user_synchronizations_data(data):
        return HttpResponseBadRequest("Bad get_user_synchronizations request")

    email = data.get("email")
    access_code = data.get("access_code")

    try:
        account = models.UserManagementAccount.objects.get(email=email)
    except ObjectDoesNotExist:
        return HttpResponseNotFound("UserManagementAccount not in database")

    if not verify_account_access_code(account, access_code):
        return HttpResponseForbidden("Not authorized")

    synchronizations = models.UserSynchronization.objects.filter(account=account)
    return JsonResponse(
        {
            "synchronizations": [{"name": s.name} for s in synchronizations],
        },
        status=200,
    )


@csrf_exempt
@require_http_methods(["POST"])
def add_user_synchronization(request: HttpRequest):
    try:
        data = json.loads(request.body.decode("utf-8"))
    except JSONDecodeError:
        return HttpResponseBadRequest(
            "Unable to parse add_user_synchronization request"
        )

    if not check_add_user_synchronization_data(data):
        return HttpResponseBadRequest("Bad add_user_synchronization request")

    email = data.get("email")
    access_code = data.get("access_code")
    synchronization_name = data.get("synchronization_name")
    user_id = data.get("user_id")

    try:
        account = models.UserManagementAccount.objects.get(email=email)
    except ObjectDoesNotExist:
        return HttpResponseNotFound("UserManagementAccount not in database")

    if not verify_account_access_code(account, access_code):
        return HttpResponseForbidden("Not authorized")

    try:
        user = models.User.objects.get(user_id=user_id)
    except ObjectDoesNotExist:
        return HttpResponseNotFound("User not in database")

    try:
        synchronization = models.UserSynchronization.objects.get(
            account=account,
            name=synchronization_name,
        )
    except ObjectDoesNotExist:
        synchronization = create_user_synchronization(account, synchronization_name)

    synchronization.users.add(user)
    return HttpResponse(status=200)


@csrf_exempt
@require_http_methods(["POST"])
def get_synchronized_tasks(request: HttpRequest):
    try:
        data = json.loads(request.body.decode("utf-8"))
    except JSONDecodeError:
        return HttpResponseBadRequest("Unable to parse get_synchronized_tasks request")

    if not check_get_synchronized_tasks_data(data):
        return HttpResponseBadRequest("Bad get_synchronized_tasks request")

    email = data.get("email")
    access_code = data.get("access_code")
    synchronization_name = data.get("synchronization_name")
    user_id = data.get("user_id")
    starting_from_timestamp = data.get("starting_from_timestamp")

    try:
        account = models.UserManagementAccount.objects.get(email=email)
    except ObjectDoesNotExist:
        return HttpResponseNotFound("UserManagementAccount not in database")

    if not verify_account_access_code(account, access_code):
        return HttpResponseForbidden("Not authorized")

    try:
        synchronization = models.UserSynchronization.objects.get(
            account=account,
            name=synchronization_name,
        )
    except ObjectDoesNotExist:
        return HttpResponseNotFound("UserSynchronization not in database")

    # Exclude the user who requested the synchronization, who already has their own data
    synchronized_users: QuerySet[models.User] = synchronization.users.exclude(
        user_id=user_id
    )
    return JsonResponse(
        {
            "users": {
                str(user.user_id): {
                    "tasks": [
                        {
                            "first_number": task.first_number,
                            "second_number": task.second_number,
                            "operator": task.operator,
                            "timestamp": task.timestamp,
                            "visual_help": task.visual_help,
                        }
                        for task in models.Task.objects.filter(
                            user=user,
                            timestamp__gte=starting_from_timestamp,
                        )
                    ],
                    "keypresses": [
                        {
                            "key": keypress.key,
                            "timestamp": keypress.timestamp,
                        }
                        for keypress in models.Keypress.objects.filter(
                            user=user,
                            timestamp__gte=starting_from_timestamp,
                        )
                    ],
                }
                for user in synchronized_users
            }
        },
        status=200,
    )
