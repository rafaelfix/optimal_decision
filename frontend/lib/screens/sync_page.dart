import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:olle_app/functions/database_connection.dart';
import 'package:olle_app/functions/profiles.dart';
import 'package:provider/provider.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({
    super.key,
    required this.profile,
    required this.email,
    required this.accessCode,
    required this.synchronizations,
  });

  final Profile profile;
  final String email;
  final int accessCode;
  final List<String> synchronizations;

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  /// Name of the new synchronization that the user generates using the "+" button.
  /// Null if it has not yet been generated.
  String? newSynchronizationName;

  void onPressCreateSynchronization(BuildContext context) {
    newSynchronizationName = widget.profile.name;
    // Names must be uniqe per user management account, so it it's taken already
    // then we will put a random 4-digit number at the end of it, until we find one that isn't taken.
    while (widget.synchronizations.contains(newSynchronizationName)) {
      newSynchronizationName =
          widget.profile.name + Random().nextInt(10000).toString();
    }
    setState(() {
      /* newSynchronizationName changed */
    });
  }

  void onTapSynchronization(BuildContext context, String name) async {
    try {
      await addUserSynchronization(
        email: widget.email,
        accessCode: widget.accessCode,
        synchronizationName: name,
        userId: widget.profile.userId,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Unable to add user synchronization");
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Unable to add synchronization, please try again and check your internet connection.")));
      return; // Don't close the sync page
    }

    // Save credentials for account
    Provider.of<ProfileModel>(context, listen: false).linkAccount(
      widget.profile,
      UserManagementAccount(
        email: widget.email,
        accessCode: widget.accessCode,
      ),
    );

    // Synchronization setup done
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final synchronizationList = [
      ...widget.synchronizations,
      if (newSynchronizationName != null) newSynchronizationName!
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: const CloseButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Icon(
              Icons.cloud_upload_outlined,
              size: 175,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            ListView.builder(
              itemCount: synchronizationList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final name = synchronizationList[index];
                return SynchronizationRowWidget(
                  synchronizationName: name,
                  onTap: () => onTapSynchronization(context, name),
                );
              },
            ),
            if (newSynchronizationName == null)
              IconButton(
                onPressed: () {
                  onPressCreateSynchronization(context);
                },
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                iconSize: 54,
              )
          ],
        ),
      ),
    );
  }
}

class SynchronizationRowWidget extends StatelessWidget {
  const SynchronizationRowWidget({
    super.key,
    required this.synchronizationName,
    required this.onTap,
  });

  final String synchronizationName;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                blurRadius: 0.1,
                spreadRadius: 0,
                offset: const Offset(0, 4))
          ]),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        leading: Icon(
          size: 48,
          Icons.group_outlined,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            synchronizationName,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
