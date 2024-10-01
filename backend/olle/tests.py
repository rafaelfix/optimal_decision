"""Contains test for olle app.

Tests are written through Djangos test engine. To read more about tests,
visit Djangos documentation:
https://docs.djangoproject.com/en/4.0/topics/testing/overview/.
"""

import json
import uuid
from copy import deepcopy

from django.core import mail
from django.test import Client, TestCase
from django.urls import reverse

from olle import database, models, views

client = Client()


class AccountSystemTests(TestCase):
    """Contains tests for the account system."""

    def setUp(self):
        """Test fixture for AccountSystemTests."""
        self.account = database.create_account(email="test.account@example.org")
        self.user1_android = database.add_user(
            user_id=uuid.uuid4(), name="Android", device_type=0
        )
        self.user1_ios = database.add_user(
            user_id=uuid.uuid4(), name="iOS", device_type=1
        )
        self.user2 = database.add_user(
            user_id=uuid.uuid4(), name="User2", device_type=0
        )

    def test_send_access_code_new_account(self):
        request_data = {
            "email": "test@example.org",
        }
        response = self.client.post(
            reverse(views.send_access_code),
            json.dumps(request_data),
            content_type="application/json",
        )

        # Check the response
        self.assertEqual(response.status_code, 200)

        # Check that an account has been created (exception is raised otherwise)
        account = models.UserManagementAccount.objects.get(
            email=request_data["email"],
        )

        # Check 6-digit access code
        self.assertGreaterEqual(account.access_code, 0)
        self.assertLess(account.access_code, 1000000)

        # Check that an email was sent with the correct access code
        self.assertEqual(len(mail.outbox), 1)
        access_code = f"{account.access_code:06}"
        self.assertIn(access_code, mail.outbox[0].body)

    def test_send_access_code_existing_account(self):
        request_data = {
            "email": self.account.email,
        }
        response = self.client.post(
            reverse(views.send_access_code),
            json.dumps(request_data),
            content_type="application/json",
        )

        # Check the response
        self.assertEqual(response.status_code, 200)

        # Check that an email was sent with the correct access code
        self.assertEqual(len(mail.outbox), 1)
        access_code = f"{self.account.access_code:06}"
        self.assertIn(access_code, mail.outbox[0].body)

    def test_get_user_synchronizations_wrong_code(self):
        request_data = {
            "email": self.account.email,
            "access_code": self.account.access_code + 1,
        }
        response = self.client.post(
            reverse(views.get_user_synchronizations),
            json.dumps(request_data),
            content_type="application/json",
        )
        response_str = response.content.decode("utf-8")

        # Check the response
        self.assertEqual(response.status_code, 403)
        self.assertEqual(response_str, "Not authorized")

    def test_get_user_synchronizations_empty(self):
        request_data = {
            "email": self.account.email,
            "access_code": self.account.access_code,
        }
        response = self.client.post(
            reverse(views.get_user_synchronizations),
            json.dumps(request_data),
            content_type="application/json",
        )
        response_data = json.loads(response.content)

        # Check the response
        self.assertEqual(response.status_code, 200)
        synchronizations = response_data["synchronizations"]
        self.assertEqual(len(synchronizations), 0)

    def test_add_user_synchronization(self):
        sync1_name = "SyncUser1"
        sync2_name = "SyncUser2"
        request_data_base = {
            "email": self.account.email,
            "access_code": self.account.access_code,
        }

        # Check that synchronizations can be added for the 3 users from the fixture
        request_data_add1 = {
            **request_data_base,
            "synchronization_name": sync1_name,
            "user_id": str(self.user1_android.user_id),
        }
        response_add1 = self.client.post(
            reverse(views.add_user_synchronization),
            json.dumps(request_data_add1),
            content_type="application/json",
        )
        self.assertEqual(response_add1.status_code, 200)

        request_data_add2 = {
            **request_data_base,
            "synchronization_name": sync1_name,
            "user_id": str(self.user1_ios.user_id),
        }
        response_add2 = self.client.post(
            reverse(views.add_user_synchronization),
            json.dumps(request_data_add2),
            content_type="application/json",
        )
        self.assertEqual(response_add2.status_code, 200)

        request_data_add3 = {
            **request_data_base,
            "synchronization_name": sync2_name,
            "user_id": str(self.user2.user_id),
        }
        response_add3 = self.client.post(
            reverse(views.add_user_synchronization),
            json.dumps(request_data_add3),
            content_type="application/json",
        )
        self.assertEqual(response_add3.status_code, 200)

        # Check that the synchronizations are returned by get_user_synchronizations
        response_synchronizations = self.client.post(
            reverse(views.get_user_synchronizations),
            json.dumps(request_data_base),
            content_type="application/json",
        )
        self.assertEqual(response_synchronizations.status_code, 200)

        response_synchronizations_data = json.loads(response_synchronizations.content)
        synchronizations = response_synchronizations_data["synchronizations"]
        synchronization_names = [sync["name"] for sync in synchronizations]
        self.assertIn(sync1_name, synchronization_names)
        self.assertIn(sync2_name, synchronization_names)

        # Check that the synchronizations exist and contain the right users
        sync1 = models.UserSynchronization.objects.get(
            account=self.account, name=sync1_name
        )
        sync2 = models.UserSynchronization.objects.get(
            account=self.account, name=sync2_name
        )
        self.assertTrue(sync1.users.contains(self.user1_android))
        self.assertTrue(sync1.users.contains(self.user1_ios))
        self.assertTrue(sync2.users.contains(self.user2))

    def test_get_synchronized_tasks(self):
        request_data_base = {
            "email": self.account.email,
            "access_code": self.account.access_code,
            "synchronization_name": "SyncUser",
        }

        # Add a synchronization with 2 users and some tasks for each
        request_data_add1 = {
            **request_data_base,
            "user_id": str(self.user1_android.user_id),
        }
        response_add1 = self.client.post(
            reverse(views.add_user_synchronization),
            json.dumps(request_data_add1),
            content_type="application/json",
        )
        self.assertEqual(response_add1.status_code, 200)

        request_data_session1 = dummy_add_session(str(self.user1_android.user_id))
        response_add1 = self.client.post(
            reverse(views.store_session),
            json.dumps(request_data_session1),
            content_type="application/json",
        )
        self.assertEqual(response_add1.status_code, 200)

        request_data_add2 = {
            **request_data_base,
            "user_id": str(self.user1_ios.user_id),
        }
        response_add2 = self.client.post(
            reverse(views.add_user_synchronization),
            json.dumps(request_data_add2),
            content_type="application/json",
        )
        self.assertEqual(response_add2.status_code, 200)

        request_data_session2 = dummy_add_session(str(self.user1_ios.user_id))
        response_add2 = self.client.post(
            reverse(views.store_session),
            json.dumps(request_data_session2),
            content_type="application/json",
        )
        self.assertEqual(response_add2.status_code, 200)

        # Check that we get correct tasks from get_synchronized_tasks as user1_android
        request_data_get_tasks_android = {
            **request_data_add1,
            "starting_from_timestamp": 0,
        }
        response_get_tasks_android = self.client.post(
            reverse(views.get_synchronized_tasks),
            json.dumps(request_data_get_tasks_android),
            content_type="application/json",
        )
        self.assertEqual(response_get_tasks_android.status_code, 200)

        # Expect to see all tasks from user1_ios
        response_get_tasks_data_android = json.loads(response_get_tasks_android.content)
        users = response_get_tasks_data_android["users"]
        self.assertEqual(len(users), 1)
        user1_ios_data = users[str(self.user1_ios.user_id)]
        user1_ios_tasks = user1_ios_data["tasks"]
        user1_ios_keypresses = user1_ios_data["keypresses"]
        self.assertEqual(len(user1_ios_tasks), 2)
        self.assertEqual(len(user1_ios_keypresses), 4)

        # Check that we get correct tasks, t>=4 from get_synchronized_tasks as user1_ios
        request_data_get_tasks_ios = {
            **request_data_add2,
            "starting_from_timestamp": 4,
        }
        response_get_tasks_ios = self.client.post(
            reverse(views.get_synchronized_tasks),
            json.dumps(request_data_get_tasks_ios),
            content_type="application/json",
        )
        self.assertEqual(response_get_tasks_ios.status_code, 200)

        # Expect to see all (1) tasks from user1_android, after t>=4
        response_get_tasks_data_ios = json.loads(response_get_tasks_ios.content)
        users = response_get_tasks_data_ios["users"]
        self.assertEqual(len(users), 1)
        user1_android_data = users[str(self.user1_android.user_id)]
        user1_android_tasks = user1_android_data["tasks"]
        user1_android_keypresses = user1_android_data["keypresses"]
        self.assertEqual(len(user1_android_tasks), 1)
        self.assertEqual(len(user1_android_keypresses), 2)
        self.assertEqual(user1_android_tasks[0]["visual_help"], "a")


class StoreRequestViewTests(TestCase):
    """Contains tests for storing a request."""

    def setUp(self):
        """Add a base user to run tests on."""
        response = self.client.post(
            reverse(views.create_user),
            json.dumps(dummy_new_user_android),
            content_type="application/json",
        )
        response_object = json.loads(response.content)
        self.user_id = response_object["user_id"]

    def test_create_user(self):
        """
        Creates a user with corresponding device data.

        Expected: status code 200 - OK
        """
        response = self.client.post(
            reverse(views.create_user),
            json.dumps(dummy_new_user_android),
            content_type="application/json",
        )

        # Fetch dummy user_id and check if user exists in database.
        response_object = json.loads(response.content)
        user_id = response_object["user_id"]
        user_exist = models.User.objects.filter(user_id=user_id).exists()
        self.assertTrue(user_exist, "User wasn't added to database correctly")

        # Query database for user and check if attributes are correctly added.
        user = models.User.objects.get(user_id=user_id)
        self.assertEqual(user.name, "Android")
        self.assertEqual(
            user.device_type, dummy_new_user_android["User"]["device_type"]
        )
        self.assertEqual(user.teacher_email, "")

        # Check status
        self.assertEqual(response.status_code, 200)

    def test_store_data(self):
        """
        Sends a request with correct data, creates a user.

        Expected: status code 200 - OK
        """
        # Store session data
        response = self.client.post(
            reverse(views.store_session),
            json.dumps(dummy_add_session(self.user_id)),
            content_type="application/json",
        )

        self.assertEqual(response.status_code, 200)

        # Fetch user and their only added session from database.
        user = models.User.objects.get(user_id=self.user_id)
        user_sessions = models.Session.objects.filter(user=user)
        added_session = user_sessions[0]

        # Test that task count is incremented correctly
        self.assertEqual(user.task_count, 2)

        # Check that attributes has the correct format
        self.assertIsInstance(added_session.timestamp, int)
        self.assertIsInstance(added_session.session_time, int)

        # Check that session time is reasonable.
        self.assertLess(added_session.session_time, 10000000)  # ~27 hours

        # Fetch session tasks and keypresses and check that correct that data
        # was added with correct formatting
        added_tasks = models.Task.objects.filter(
            timestamp__range=[
                added_session.timestamp,
                added_session.timestamp + added_session.session_time,
            ]
        )

        self.assertEqual(
            len(added_tasks), len(dummy_add_session(self.user_id)["TaskList"])
        )

        for added_task in added_tasks:
            self.assertEqual(added_task.user, user)
            self.assertIsInstance(added_task.second_number, int)
            self.assertIsInstance(added_task.first_number, int)
            self.assertIsInstance(added_task.user_answer, int | None)
            self.assertIsInstance(added_task.timestamp, int)
            self.assertIsInstance(added_task.visual_help, str)

        self.assertEqual(added_tasks[0].visual_help, " ")
        self.assertEqual(added_tasks[1].visual_help, "a")

        added_keypresses = models.Keypress.objects.filter(
            timestamp__range=[
                added_session.timestamp,
                added_session.timestamp + added_session.session_time,
            ],
            user=user,
        )

        for added_keypress in added_keypresses:
            self.assertEqual(added_keypress.user, user)
            self.assertIsInstance(added_keypress.key, str)
            self.assertIsInstance(added_keypress.timestamp, int)

        self.assertEqual(response.status_code, 200)

        response_data = json.loads(response.content.decode("UTF-8"))
        task_count = response_data.get("task_count")
        self.assertEqual(task_count, 2)

    def test_no_data(self):
        """
        Sends an empty request.

        Expected: status code 400 - Bad request
        """
        response = self.client.post(
            reverse(views.store_session),
            json.dumps(dummy_empty),
            content_type="application/json",
        )

        self.assertEqual(response.status_code, 400)

    def test_store_data_user_does_not_exist(self):
        """
        Store data for user which hasn't been added.

        Expected: status code 400 - Bad request
        """
        dummy_add_session_wrong = deepcopy(dummy_add_session(self.user_id))
        dummy_add_session_wrong["User"]["user_id"] = (
            "801766d2-2fe0-43f4-be84-38eb2a5c2658"
        )

        response = self.client.post(
            reverse(views.store_session),
            json.dumps(dummy_add_session_wrong),
            content_type="application/json",
        )

        self.assertEqual(response.status_code, 400)

    def test_bad_session_times(self):
        """
        Add session with start time later than end time.

        Expected: status code 400 - Bad request
        """
        response = self.client.post(
            reverse(views.store_session),
            json.dumps(dummy_add_session_bad_times(self.user_id)),
            content_type="application/json",
        )
        self.assertEqual(response.status_code, 400)

    def test_negative_task_time_offset(self):
        """
        Add task with negative time offset.

        Expected: status code 400 - Bad request
        """
        dummy_add_session_negative_offset = deepcopy(
            dummy_add_session_bad_times(self.user_id)
        )
        dummy_add_session_negative_offset["TaskList"][0]["time_offset"] = -5
        json_dump = json.dumps(dummy_add_session_negative_offset)

        response = self.client.post(
            reverse(views.store_session), json_dump, content_type="application/json"
        )

        self.assertEqual(response.status_code, 400)

    def test_bad_request_type(self):
        """
        Tets bad request data.

        Expected: status code 400 - Bad request
        """
        response_js = self.client.post(
            reverse(views.store_session),
            'console.log("DEADBEEF")',
            content_type="application/javascript",
        )

        response_html = self.client.post(
            reverse(views.create_user), "<html></html>", content_type="text/html"
        )

        self.assertEqual(response_js.status_code, 400)
        self.assertEqual(response_html.status_code, 400)

    def test_bad_long_request(self):
        """
        Test request with a delay.

        Expected: Response with status code 400 - Bad request
        """
        d = {}
        for i in range(0, 1000):
            d[str(i)] = "DEADBEEF"

        response = self.client.post(
            reverse(views.create_user), json.dumps(d), content_type="application/json"
        )

        self.assertEqual(response.status_code, 400)

    def test_add_teacher_email(self):
        request = {
            "user_id": self.user_id,
            "teacher_email": "teacher@example.org",
        }
        response = self.client.post(
            reverse(views.add_teacher_email),
            json.dumps(request),
            content_type="application/json",
        )

        user = models.User.objects.get(user_id=self.user_id)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(user.teacher_email, request["teacher_email"])


class StoreRequestViewTestsIOS(TestCase):
    """Contains tests for storing a request."""

    def setUp(self):
        """Add a base user to run tests on."""
        response = self.client.post(
            reverse(views.create_user),
            json.dumps(dummy_new_user_ios),
            content_type="application/json",
        )
        response_object = json.loads(response.content)
        self.user_id = response_object["user_id"]

    def test_create_user(self):
        """
        Creates a user with corresponding device data.

        Expected: status code 200 - OK
        """
        response = self.client.post(
            reverse(views.create_user),
            json.dumps(dummy_new_user_ios),
            content_type="application/json",
        )

        # Fetch dummy user_id and check if user exists in database.
        response_object = json.loads(response.content)
        user_id = response_object["user_id"]
        user_exist = models.User.objects.filter(user_id=user_id).exists()
        self.assertTrue(user_exist, "User wasn't added to database correctly")

        # Query database for user and check if attributes are correctly added.
        user = models.User.objects.get(user_id=user_id)
        self.assertEqual(user.name, "iOS")
        self.assertEqual(user.device_type, dummy_new_user_ios["User"]["device_type"])
        self.assertEqual(user.teacher_email, "")

        # Check status
        self.assertEqual(response.status_code, 200)

    def test_store_data(self):
        """
        Sends a request with correct data, creates a user.

        Expected: status code 200 - OK
        """
        # Store session data
        response = self.client.post(
            reverse(views.store_session),
            json.dumps(dummy_add_session(self.user_id)),
            content_type="application/json",
        )

        self.assertEqual(response.status_code, 200)

        # Fetch user and their only added session from database.
        user = models.User.objects.get(user_id=self.user_id)
        user_sessions = models.Session.objects.filter(user=user)
        added_session = user_sessions[0]

        # Test that task count is incremented correctly
        self.assertEqual(user.task_count, 2)

        # Check that attributes has the correct format
        self.assertIsInstance(added_session.timestamp, int)
        self.assertIsInstance(added_session.session_time, int)

        # Check that session time is reasonable.
        self.assertLess(added_session.session_time, 10000000)  # ~27 hours

        # Fetch session tasks and keypress and check that correct that data
        # was added with correct formatting.
        added_tasks = models.Task.objects.filter(
            timestamp__range=[
                added_session.timestamp,
                added_session.timestamp + added_session.session_time,
            ]
        )

        self.assertEqual(
            len(added_tasks), len(dummy_add_session(self.user_id)["TaskList"])
        )

        for added_task in added_tasks:
            self.assertEqual(added_task.user, user)
            self.assertIsInstance(added_task.second_number, int)
            self.assertIsInstance(added_task.first_number, int)
            self.assertIsInstance(added_task.user_answer, int | None)
            self.assertIsInstance(added_task.timestamp, int)
            self.assertIsInstance(added_task.visual_help, str)

        self.assertEqual(added_tasks[0].visual_help, " ")
        self.assertEqual(added_tasks[1].visual_help, "a")

        added_keypresses = models.Keypress.objects.filter(
            timestamp__range=[
                added_session.timestamp,
                added_session.timestamp + added_session.session_time,
            ],
            user=user,
        )

        for added_keypress in added_keypresses:
            self.assertEqual(added_keypress.user, user)
            self.assertIsInstance(added_keypress.key, str)
            self.assertIsInstance(added_keypress.timestamp, int)

        self.assertEqual(response.status_code, 200)

        response_data = json.loads(response.content.decode("UTF-8"))
        task_count = response_data.get("task_count")
        self.assertEqual(task_count, 2)

    def test_no_data(self):
        """
        Sends an empty request.

        Expected: status code 400 - Bad request
        """
        response = self.client.post(
            reverse(views.store_session),
            json.dumps(dummy_empty),
            content_type="application/json",
        )

        self.assertEqual(response.status_code, 400)

    def test_store_data_user_does_not_exist(self):
        """
        Store data for user which hasn't been added.

        Expected: status code 400 - Bad request
        """
        dummy_add_session_wrong_user = deepcopy(dummy_add_session(self.user_id))
        dummy_add_session_wrong_user["User"]["user_id"] = (
            "801766d2-2fe0-43f4-be84-38eb2a5c2658"
        )

        response = self.client.post(
            reverse(views.store_session),
            json.dumps(dummy_add_session_wrong_user),
            content_type="application/json",
        )

        self.assertEqual(response.status_code, 400)

    def test_bad_session_times(self):
        """
        Add session with start time later than end time.

        Expected: status code 400 - Bad request
        """
        response = self.client.post(
            reverse(views.store_session),
            json.dumps(dummy_add_session_bad_times(self.user_id)),
            content_type="application/json",
        )
        self.assertEqual(response.status_code, 400)

    def test_negative_task_time_offset(self):
        """
        Add task with negative time offset.

        Expected: status code 400 - Bad request
        """
        dummy_add_session_negative_offset = deepcopy(
            dummy_add_session_bad_times(self.user_id)
        )
        dummy_add_session_negative_offset["TaskList"][0]["time_offset"] = -5
        json_dump = json.dumps(dummy_add_session_negative_offset)

        response = self.client.post(
            reverse(views.store_session), json_dump, content_type="application/json"
        )

        self.assertEqual(response.status_code, 400)

    def test_bad_request_type(self):
        """
        Tets bad request data.

        Expected: status code 400 - Bad request
        """
        response_js = self.client.post(
            reverse(views.store_session),
            'console.log("DEADBEEF")',
            content_type="application/javascript",
        )

        response_html = self.client.post(
            reverse(views.create_user), "<html></html>", content_type="text/html"
        )

        self.assertEqual(response_js.status_code, 400)
        self.assertEqual(response_html.status_code, 400)

    def test_bad_long_request(self):
        """
        Test request with a delay.

        Expected: Response with status code 400 - Bad request
        """
        d = {}
        for i in range(0, 1000):
            d[str(i)] = "DEADBEEF"

        response = self.client.post(
            reverse(views.create_user), json.dumps(d), content_type="application/json"
        )

        self.assertEqual(response.status_code, 400)


dummy_new_user_android = {
    "DeviceInfo": {
        "board": "xxxxx",
        "brand": "Nokia",
        "device_id": "ABC:123",
        "host": "Agnes Nokia",
        "hardware": "xxxxx",
        "manufacturer": "Finland",
        "vincremental": "xxxxx",
        "vrelease": "2002",
        "model": "Nokia 3310",
        "product": "Phone",
        "tags": "#phone",
        "type": "Brick",
        "device": "MyDevice",
        "vsdkint": 3,
    },
    "User": {
        "device_type": 0,
        "name": "Android",
    },
}

dummy_new_user_ios = {
    "DeviceInfo": {
        "name": "Agnes",
        "system_name": "iOS",
        "system_version": "14.1",
        "model": "Agnes Nokia",
        "localized_model": "xxxxx",
        "identifier_for_vendor": "MAC:ADDRESS:01:02",
        "utsname_machine": "xxxxx",
        "utsname_version": "xxxxx",
        "utsname_release": "xxxxx",
        "utsname_node_name": "xxxxx",
        "utsname_sysname": "xxxxx",
    },
    "User": {
        "device_type": 1,
        "name": "iOS",
    },
}


def dummy_add_session(user_id):
    return {
        "User": {"user_id": user_id},
        "Session": {"client_start_time": 0, "client_end_time": 10},
        "TaskList": [
            {
                "first_number": 1,
                "second_number": 2,
                "operator": "+",
                "user_answer": 3,
                "timestamp": 1,
                "visual_help": " ",
                "KeypressList": [
                    {"key": "3", "timestamp": 2},
                    {"key": "=", "timestamp": 3},
                ],
            },
            {
                "first_number": 2,
                "second_number": 1,
                "operator": "-",
                "user_answer": None,
                "timestamp": 4,
                "visual_help": "a",
                "KeypressList": [
                    {"key": "?", "timestamp": 6},
                    {"key": "R", "timestamp": 8},
                ],
            },
        ],
    }


def dummy_add_session_bad_times(user_id):
    return {
        "User": {"user_id": user_id},
        "Session": {"client_start_time": 10, "client_end_time": 0},
        "TaskList": [
            {
                "first_number": 1,
                "second_number": 2,
                "operator": "+",
                "user_answer": 3,
                "timestamp": 0,
                "visual_help": " ",
                "KeypressList": [
                    {"key": "3", "timestamp": 1},
                    {"key": "=", "timestamp": 2},
                ],
            },
            {
                "first_number": 2,
                "second_number": 1,
                "operator": "-",
                "user_answer": None,
                "timestamp": 2,
                "visual_help": "a",
                "KeypressList": [
                    {"key": "?", "timestamp": 3},
                    {"key": "R", "timestamp": 9},
                ],
            },
        ],
    }


dummy_empty: dict[str, str] = {}
