import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaemcosign/bloc/notification_bloc.dart';
import 'package:gaemcosign/bloc/notification_event.dart';
import 'package:gaemcosign/bloc/notification_state.dart';
import 'package:gaemcosign/notification_setting.dart';

import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotificationService notificationService;
  late NotificationBloc notificationBloc;

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  TimeOfDay? tempPickedTime;

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();
    notificationService.initNotification();
    notificationBloc =
        NotificationBloc(notificationService, Hive.box('reminder_box'));
    notificationBloc.add(LoadNotifications());
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final state = notificationBloc.state;
      if (state is NotificationLoaded) {
        final existingItem =
            state.notifications.firstWhere((element) => element.key == itemKey);
        titleController.text = existingItem.name;
        descController.text = existingItem.description;
      }
    }
    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        tempPickedTime = pickedTime;
                        if (itemKey == null) {
                          notificationBloc.add(AddNotification(
                            titleController.text,
                            descController.text,
                            tempPickedTime!,
                          ));
                        } else {
                          notificationBloc.add(AddNotification(
                            titleController.text,
                            descController.text,
                            tempPickedTime!,
                          ));
                        }
                      }
                      titleController.clear();
                      descController.clear();
                      Navigator.pop(context);
                    },
                    child: Text(itemKey == null ? 'Create New' : 'Update'),
                  ),
                  const SizedBox(height: 15)
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Notifications'),
      ),
      body: BlocProvider(
        create: (_) => notificationBloc,
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              return ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (_, index) {
                  final currentItem = state.notifications[index];
                  return Card(
                    color: Colors.orange.shade100,
                    margin: const EdgeInsets.all(10),
                    elevation: 3,
                    child: ListTile(
                      title: Text(currentItem.name),
                      subtitle: Text(currentItem.description),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${currentItem.time.hour.toString().padLeft(2, '0')}:${currentItem.time.minute.toString().padLeft(2, '0')}',
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          notificationBloc
                              .add(DeleteNotification(currentItem.key));
                        },
                      ),
                    ),
                  );
                },
              );
            } else if (state is NotificationError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(
                child: Text('No Data', style: TextStyle(fontSize: 30)),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
