"""Contains functions for validating the data passed in requests.

If the data does not pass the validation test, the functions will return
False for the calling function to handle.
"""

import datetime

import dateutil

schema_create_user = {
    "User": {
        "device_type": int,
        "name": str,
    },
    "DeviceInfo": dict,
}

schema_add_session = {
    "User": {"user_id": str},
    "Session": {"client_start_time": int, "client_end_time": int},
    "TaskList": list,
}

schema_task = {
    "first_number": int,
    "second_number": int,
    "operator": str,
    "user_answer": int | None,
    "timestamp": int,
    "visual_help": str,
    "KeypressList": list,
}

schema_keypress = {"key": str, "timestamp": int}

schema_android = {
    "board": str,
    "brand": str,
    "device_id": str,
    "host": str,
    "hardware": str,
    "manufacturer": str,
    "vincremental": str,
    "vrelease": str,
    "model": str,
    "product": str,
    "tags": str,
    "type": str,
    "device": str,
    "vsdkint": int,
}

schema_ios = {
    "name": str,
    "system_name": str,
    "system_version": str,
    "model": str,
    "localized_model": str,
    "identifier_for_vendor": str,
    "utsname_machine": str,
    "utsname_version": str,
    "utsname_release": str,
    "utsname_node_name": str,
    "utsname_sysname": str,
}

schema_send_access_code = {
    "email": str,
}

schema_get_user_synchronizations = {
    "email": str,
    "access_code": int,
}

schema_add_user_synchronization = {
    "email": str,
    "access_code": int,
    "synchronization_name": str,
    "user_id": str,
}

schema_get_synchronized_tasks = {
    "email": str,
    "access_code": int,
    "synchronization_name": str,
    "user_id": str,
    "starting_from_timestamp": int,
}


schema_add_teacher_email = {
    "user_id": str,
    "teacher_email": str,
}


def is_datetime_convertible(string: str) -> bool:
    """Determine if some string is parsable as a python datetime object.

    Args:
        string (str): some string to attempt to parse.

    Returns: True if parsable as a datetime object, else False.
    """
    try:
        dateutil.parser.parse(string)
    except ValueError:
        return False
    return True


def is_valid(data: dict, schema: dict) -> bool:
    """Return whether all key and type pairs are valid with given user info.

    Args:
        data (dict): User info dict.
        *pairs (tuple[str, type]): List of pairs to be checked.
    """
    if len(data) != len(schema):
        return False

    def is_valid_pair(key: str, val) -> bool:
        """Return whether pair passes validity check."""
        if isinstance(val, dict):
            return is_valid(data[key], val)
        elif val == datetime.datetime:
            return key in data and is_datetime_convertible(data.get(key))
        else:
            return key in data and isinstance(data[key], val)

    return all(is_valid_pair(key, val) for key, val in schema.items())


def check_create_user_data(data: dict) -> bool:
    """Determine if the input data is valid for creating user.

    Args:
        data (json): a json object containing a request to add a new user.

    Returns: True if given object contains all necessary fields and all fields
             are convertible to the expected types.

    """
    if not is_valid(data, schema_create_user):
        return False

    device_type = data["User"]["device_type"]
    if device_type == 0:
        if not is_valid(data["DeviceInfo"], schema_android):
            return False
    elif device_type == 1:
        if not is_valid(data["DeviceInfo"], schema_ios):
            return False
    else:
        return False
    return True


def check_add_session_data(data: dict) -> bool:
    """Determine if the input data is valid for creating session.

    Args:
        data (json): a json object containing a request to add a new session.

    Returns: True if given object contains all necessary fields and all fields
             are convertible to the expected types.
    """
    if not is_valid(data, schema_add_session):
        return False

    for task in data["TaskList"]:
        if not is_valid(task, schema_task):
            return False
        for keypress in task["KeypressList"]:
            if not is_valid(keypress, schema_keypress):
                return False

    return True


def check_add_teacher_email_data(data: dict) -> bool:
    """Determine if the input data is valid for add_teacher_email.

    Args:
        data (json): a json object containing a add_teacher_email request.

    Returns: True if given object contains all necessary fields and all fields
             are convertible to the expected types.
    """
    return is_valid(data, schema_add_teacher_email)


def check_send_access_code_data(data: dict) -> bool:
    """Determine if the input data is valid for send_access_code endpoint.

    Args:
        data (json): a json object containing a send_access_code request.

    Returns: True if given object contains all necessary fields and all fields
             are convertible to the expected types.

    """
    return is_valid(data, schema_send_access_code)


def check_get_user_synchronizations_data(data: dict) -> bool:
    """Determine if the input data is valid for get_user_synchronizations endpoint.

    Args:
        data (json): a json object containing a get_user_synchronizations request.

    Returns: True if given object contains all necessary fields and all fields
             are convertible to the expected types.

    """
    return is_valid(data, schema_get_user_synchronizations)


def check_add_user_synchronization_data(data: dict) -> bool:
    """Determine if the input data is valid for add_user_synchronization endpoint.

    Args:
        data (json): a json object containing a add_user_synchronization request.

    Returns: True if given object contains all necessary fields and all fields
             are convertible to the expected types.

    """
    return is_valid(data, schema_add_user_synchronization)


def check_get_synchronized_tasks_data(data: dict) -> bool:
    """Determine if the input data is valid for get_synchronized_tasks endpoint.

    Args:
        data (json): a json object containing a get_synchronized_tasks request.

    Returns: True if given object contains all necessary fields and all fields
             are convertible to the expected types.

    """
    return is_valid(data, schema_get_synchronized_tasks)
