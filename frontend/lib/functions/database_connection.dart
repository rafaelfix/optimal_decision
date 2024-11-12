import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

import 'package:nativelib/nativelib.dart';

import 'package:olle_app/functions/practice_session.dart';
import 'package:olle_app/functions/profiles.dart';

// The OLLE_SERVER variable specifies the protocol, internet address and port to use
// for connecting to the backend server.
// It is specified at build time and statically compiled into the app, see:
// - https://dart.dev/guides/environment-declarations
// "10.0.2.2" can be used as the address when connecting to a local server from an Android emulator, see:
// - https://developer.android.com/studio/run/emulator-networking
// "localhost" can be used as the address when connecting to a local server from a physical Android device
// (or an emulator), if the "adb reverse" command is used to set up forwarding of network traffic via ADB, see:
// - https://developer.android.com/tools/adb#forwardports
// - https://android.googlesource.com/platform/system/core/+/252586941934d23073a8d167ec240b221062505f
const String _url = String.fromEnvironment('OLLE_SERVER',
    defaultValue: 'https://om2.it.liu.se/http/');

/// Converts the type of device to an int
/// where 0 is for Android and 1 for iOS
///
/// throws [UnsupportedError] if the device is not supported
int get _deviceType {
  if (Platform.isAndroid) {
    return 0;
  } else if (Platform.isIOS) {
    return 1;
  } else {
    throw UnsupportedError('Unsupported Device');
  }
}

/// Extracts relevant fields from the device info to match database fields
///
/// throws an [UnsupportedError] if the device info is not supported
Future<Map<dynamic, dynamic>> get _deviceData async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  var data = {};
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    data['board'] = androidInfo.board;
    data['brand'] = androidInfo.brand;
    data['device_id'] = androidInfo.id;
    data['host'] = androidInfo.host;
    data['hardware'] = androidInfo.hardware;
    data['manufacturer'] = androidInfo.manufacturer;
    data['vincremental'] = androidInfo.version.incremental;
    data['vrelease'] = androidInfo.version.release;
    data['model'] = androidInfo.model;
    data['product'] = androidInfo.product;
    data['tags'] = androidInfo.tags;
    data['type'] = androidInfo.type;
    data['device'] = androidInfo.device;
    data['vsdkint'] = androidInfo.version.sdkInt;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    data['name'] = iosInfo.name;
    data['system_name'] = iosInfo.systemName;
    data['system_version'] = iosInfo.systemVersion;
    data['model'] = iosInfo.model;
    data['localized_model'] = iosInfo.localizedModel;
    data['identifier_for_vendor'] = iosInfo.identifierForVendor;
    data['utsname_machine'] = iosInfo.utsname.machine;
    data['utsname_version'] = iosInfo.utsname.version;
    data['utsname_release'] = iosInfo.utsname.release;
    data['utsname_node_name'] = iosInfo.utsname.nodename;
    data['utsname_sysname'] = iosInfo.utsname.sysname;
  } else {
    throw UnsupportedError('Unsupported Device');
  }
  return data;
}

/// Sends a request to the database to create a new user.
///
/// Throws [HttpException] if the request fails
///
/// Throws [SocketException] if the request fails because of a socket error (no internet)
///
/// Throws [UnsupportedError] if the device is not supported
///
/// Throws [FormatException] if the request fails
///
/// Returns the user ID of the newly created user.
Future<String> createUser(String name) async {
  http.Response res = await http
      .post(
        Uri.parse('$_url/create_user/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'User': {
            'device_type': _deviceType,
            'name': name,
          },
          'DeviceInfo': await _deviceData,
        }),
      )
      .timeout(const Duration(seconds: 3));

  if (res.statusCode != 200) {
    throw HttpException(
        'Server responded with ${res.statusCode} \n ${res.reasonPhrase}');
  }
  return jsonDecode(res.body)["user_id"];
}

/// Task format for the database
///
/// [question] is the question
///
/// [userAnswer] given by the user, not always the correct answer
///
/// [timestamp] is the time offset from the start of the session
///
/// [keypressList] is a list of keypresses using [KeypressSchema]
///
/// TODO combine with Task in task.dart?
class TaskSchema {
  final Question question;
  final int? userAnswer;
  final int timestamp;
  final List<KeypressSchema> keypressList;

  const TaskSchema(
    this.question,
    this.userAnswer,
    this.timestamp,
    this.keypressList,
  );

  /// Converts the task to json format
  Map<String, dynamic> toJson() {
    return {
      'first_number': question.firstNumber,
      'second_number': question.secondNumber,
      // TODO: Rename the "operator" field to "task_type" in the database
      'operator': question.questionType,
      'user_answer': userAnswer,
      'timestamp': timestamp,
      'visual_help': question.visualHelp,
      'KeypressList': keypressList,
    };
  }
}

/// Keypress format for the database
///
/// [key] is the key pressed, either '0'-'9', 'C' or '='
///
/// [timestamp] is the time in unix time that the key was pressed
class KeypressSchema {
  final String key;
  final int timestamp;

  const KeypressSchema(
    this.key,
    this.timestamp,
  );

  /// Converts the keypress to json format
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'timestamp': timestamp,
    };
  }
}

/// Indicates that the session was empty,
/// meaning that no answers were given
///
/// message could be static
class EmptySessionException implements Exception {
  EmptySessionException(this.message);

  final String message;
}

/// Calculates the answer given by the user based on [KeypressSchema]s
///
/// returns answer as an integer, or null if there was no answer
/// (visualHelp questions cannot be answered, for example).
int? _calcAnswer(List<KeypressSchema> keypressList) {
  String answer = "";
  for (String key in keypressList.map((e) => e.key)) {
    if (key == '?' || key == 'R') {
      // Skip visualization markers since they don't contribute to the answer
      continue;
    }

    if (key == 'C') {
      // clear on 'C
      answer = '';
    } else if (key == 'E' || key == '=') {
      // every answer should end with 'E' or '='
      return int.parse(answer);
    } else if (key == 'B' || key == '<') {
      // remove last character, if it's not empty
      if (answer.isNotEmpty) answer = answer.substring(0, answer.length - 1);
    } else {
      // assumes that the key is a number between 0 and 9
      answer = answer + key;
    }
  }

  // The question was never answered (for example, if it was a visualHelp question)
  return null;
}

/// Gets task from nativelib.
///
/// [fromTask] is the first index of a question to read from
Future<List<TaskSchema>> getTasks({
  required int fromTask,
}) async {
  List<TaskSchema> tasks = [];
  String times = await Nativelib.call('getDataTimesStart', [fromTask]);
  String inputs = await Nativelib.call('getDataInputsStart', [fromTask]);

  // Självklart är fromTask större...
  // if (fromTask >= timesList.length) {
  //   throw Exception('fromTask is too large, local data is behind...');
  // }

  if (times.isEmpty || inputs.isEmpty) {
    throw EmptySessionException(
        'No sessions found, local data is probably behind...');
  }

  List<String> timesList = times.split(' ');
  // Ugly workaround for new question format: Filter out empty strings,
  // because the ' ' character is now not only used as a delimiter, but also
  // as an "enum" value for the visualHelp field, so spaces are ambiguous.
  // The "inputs" string looks something like:
  // "4+0  4 = 2+0  2 = 0+2  2 = 0+9  9 = 1+1  2 = 8+0  8 ="
  // The string contains a question, e.g. "4+0 " or "4+0a", followed by a number
  // of keypresses, such as "4" or "=", and so on.
  List<String> inputsList =
      inputs.split(" ").where((s) => s.isNotEmpty).toList();

  if (timesList.length != inputsList.length) {
    throw Exception(
        'Times and inputs are not the same length, file is corrupt');
  }

  // Check if string is a question (otherwise it is a keypress).
  // Note: Using ".?" for the visualHelp flag because it may or may not
  // have been removed by the isNotEmpty filter above, depending on whether
  // or not visualHelp is set to the space character.
  RegExp isQuestion = RegExp(r'^\d+[^\d]+\d+.?$');

  Question? question; // the question asked
  int lastQuestionTime = 0; // the time of when the question was asked
  List<KeypressSchema> tempKeypressList = [];
  for (int i = 0; i < inputsList.length; i++) {
    if (isQuestion.hasMatch(inputsList[i])) {
      if (question != null) {
        // if there is a question, add it to the list
        tasks.add(
          TaskSchema(
            question,
            _calcAnswer(tempKeypressList),
            lastQuestionTime,
            tempKeypressList,
          ),
        );
      }
      // question found
      tempKeypressList = [];
      question = Question.fromXyString(inputsList[i]);
      lastQuestionTime = int.parse(timesList[i]);
    } else {
      KeypressSchema keypress = KeypressSchema(
        inputsList[i],
        int.parse(timesList[i]),
      );
      tempKeypressList.add(keypress);
    }
  }

  // add last task, null check incase there is no question
  if (question != null) {
    tasks.add(
      TaskSchema(
        question,
        _calcAnswer(tempKeypressList),
        lastQuestionTime,
        tempKeypressList,
      ),
    );
  }

  return tasks;
}

/// Defines a timespan that starts at [start] and ends at [end]
///
/// [start] and [end] are in unixtime (milliseconds)
///
/// [start] must be before [end]
class Interval {
  const Interval({
    required this.start,
    required this.end,
  }) : assert(start < end);
  final int start;
  final int end;

  /// Creates an interval from a space delimited string
  ///
  /// [interval] must be in the format "start end"
  factory Interval.fromString(String interval) {
    List<String> intervalList = interval.split(' ');
    return Interval(
      start: int.parse(intervalList[0]),
      end: int.parse(intervalList[1]),
    );
  }

  /// Determines if a [task] is within the interval
  bool taskInInterval(TaskSchema task) {
    return task.timestamp >= start && task.timestamp <= end;
  }
}

/// Gets the client times for each session from NativeLib
///
/// returns a list of [Interval]
Future<List<Interval>> get _clientTime async {
  String clientTimeFile = await Nativelib.call("readGamingTimeFile");
  List<String> clientTimes = clientTimeFile.trim().split('\n');
  return clientTimes.map((time) => Interval.fromString(time)).toList();
}

/// Splits a list of [TaskSchema] into the correct [Interval]s
///
/// returns a map of [Interval]s to a list of [TaskSchema]
///
/// An [Interval] that has no tasks in it will not be in the map
Map<Interval, List<TaskSchema>> _splitTasksToIntervals(
  List<TaskSchema> tasks,
  List<Interval> intervals,
) {
  Map<Interval, List<TaskSchema>> tasksByInterval = {};
  for (TaskSchema task in tasks) {
    for (Interval interval in intervals) {
      if (interval.taskInInterval(task)) {
        // set to empty list if null
        tasksByInterval[interval] ??= [];
        tasksByInterval[interval]!.add(task);
      }
    }
  }
  return tasksByInterval;
}

/// Sends a request to the database to add a new practice session.
///
/// This is used by [sendSessions]
///
/// [userId] is the user ID of the user
///
/// [clientStartTime] is the time in unix time that the client started the session
///
/// [clientEndTime] is the time in unix time that the client ended the session
///
/// [taskList] is a list of tasks that the user did during the session
Future<http.Response> _sendSession({
  required String userId,
  required int clientStartTime,
  required int clientEndTime,
  required List<TaskSchema> taskList,
}) async {
  http.Response res = await http
      .post(
        Uri.parse('$_url/store_session/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'User': {
            'user_id': userId,
          },
          'Session': {
            'client_start_time': clientStartTime,
            'client_end_time': clientEndTime,
          },
          'TaskList': taskList.map((TaskSchema t) => t.toJson()).toList(),
        }),
      )
      .timeout(const Duration(seconds: 3));

  if (res.statusCode == 404) {
    throw ArgumentError.value(userId, 'userId', 'User not found in database');
  } else if (res.statusCode != 200) {
    throw HttpException(
        'Server responded with ${res.statusCode} \n ${res.reasonPhrase}');
  }
  return res;
}

/// Sends all sessions based on the tasks in [taskList]
///
/// [userId] is the user ID of the user
///
/// [taskList] is a list of tasks, spanning over one or more sessions
///
/// The client [Interval]s (start and end time) are collected from NativeLib
/// using [_clientTime]
///
/// Stops at the first failure
///
/// Uses [_sendSession] to send each session
///
/// Uses [_splitTasksToIntervals] to split the tasks into sessions
Future<void> sendSessions({
  required Profile profile,
  required List<TaskSchema> taskList,
}) async {
  List<Interval> clientTimeList = await _clientTime;
  Map<Interval, List<TaskSchema>> tasksByInterval =
      _splitTasksToIntervals(taskList, clientTimeList);

  if (kDebugMode) {
    print('[Send Session] ${profile.toJson()} | ${tasksByInterval.length}');
  }
  // goes through each interval and sends the session
  for (Interval interval in tasksByInterval.keys) {
    // extra check to make sure the interval is not empty
    if (tasksByInterval[interval] == null ||
        tasksByInterval[interval]!.isEmpty) {
      continue;
    }
    List<TaskSchema> tasks = tasksByInterval[interval]!;

    http.Response res = await _sendSession(
      userId: profile.userId,
      clientStartTime: interval.start,
      clientEndTime: interval.end,
      taskList: tasks,
    );

    if (res.statusCode != 200) {
      throw HttpException(
          'Server responded with ${res.statusCode} \n ${res.reasonPhrase}');
    }

    // The server returns the new amount of tasks stored in the database
    // after each session upload.
    profile.uploadedTaskCount = jsonDecode(res.body)["task_count"];

    if (kDebugMode) print('[Send Session] Succeeded: ${profile.toJson()}');
  }
}

Future<void> addTeacherEmail({
  required String userId,
  required String teacherEmail,
}) async {
  http.Response res = await http
      .post(
        Uri.parse('$_url/add_teacher_email/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          <String, String>{
            'user_id': userId,
            'teacher_email': teacherEmail,
          },
        ),
      )
      .timeout(const Duration(seconds: 3));

  if (res.statusCode == 404) {
    throw ArgumentError.value(userId, 'userId', 'User not found in database');
  } else if (res.statusCode != 200) {
    throw HttpException(
        'Server responded with ${res.statusCode} \n${res.reasonPhrase}');
  }
}

Future<void> sendAccessCode({
  required String email,
}) async {
  http.Response res = await http
      .post(
        Uri.parse('$_url/send_access_code'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
        }),
      )
      .timeout(const Duration(seconds: 3));

  if (res.statusCode != 200) {
    throw HttpException(
        'Server responded with ${res.statusCode} \n${res.reasonPhrase}');
  }
}

Future<List<String>> getUserSynchronizations({
  required String email,
  required int accessCode,
}) async {
  http.Response res = await http
      .post(
        Uri.parse('$_url/get_user_synchronizations'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'access_code': accessCode,
        }),
      )
      .timeout(const Duration(seconds: 3));

  if (res.statusCode != 200) {
    throw HttpException(
        'Server responded with ${res.statusCode} \n${res.reasonPhrase}');
  }

  final data = jsonDecode(res.body);
  final synchronizations = data["synchronizations"] as List;
  return synchronizations.map((sync) => sync["name"] as String).toList();
}

Future<void> addUserSynchronization({
  required String email,
  required int accessCode,
  required String synchronizationName,
  required String userId,
}) async {
  http.Response res = await http
      .post(
        Uri.parse('$_url/add_user_synchronization'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'access_code': accessCode,
          'synchronization_name': synchronizationName,
          'user_id': userId,
        }),
      )
      .timeout(const Duration(seconds: 3));

  if (res.statusCode != 200) {
    throw HttpException(
        'Server responded with ${res.statusCode} \n${res.reasonPhrase}');
  }
}
