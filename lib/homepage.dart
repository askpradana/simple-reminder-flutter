import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaemcosign/cubit/notif_cubit.dart';
import 'package:gaemcosign/model/notif_model.dart';
import 'package:gaemcosign/notification_setting.dart';
import 'package:gaemcosign/theme/color.dart';
import 'package:gaemcosign/theme/custom_text.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final NotificationService notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotifCubit, NotifState>(
      builder: (context, state) {
        if (state is NotifInitial) {
          return Scaffold(
            backgroundColor: CustomColor.background,
            body: _buildBody(state.notifications, context),
            floatingActionButton: FloatingActionButton(
              backgroundColor: CustomColor.white,
              onPressed: () {
                _showAddNotificationModal(context);
              },
              child: const Icon(
                Icons.add,
                color: CustomColor.black,
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildBody(
      List<NotificationModel> notifications, BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(child: Text('It`s empty'));
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: '${notification.time!.hour}:${notification.time!.minute}',
              )
            ],
          ),
          title: CustomText(
            text: notification.name!,
            isBold: true,
          ),
          subtitle: CustomText(
            text: notification.description!,
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.done,
              color: CustomColor.white,
            ),
            onPressed: () {
              context.read<NotifCubit>().deleteNotif(notification.key);
            },
          ),
        );
      },
    );
  }

  _scheduleNotification(BuildContext context, dynamic id) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      await notificationService.scheduleNotification(
        id: id,
        title: titleController.text,
        body: descController.text,
        timeOfDay: TimeOfDay(hour: pickedTime.hour, minute: pickedTime.minute),
      );
      return pickedTime;
    }
  }

  void _showAddNotificationModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: CustomColor.background),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Name',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: CustomColor.background),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Description',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      var uniqueKey =
                          context.read<NotifCubit>().generateUniqueKey();

                      _scheduleNotification(context, uniqueKey).then((value) {
                        // add to hive
                        context.read<NotifCubit>().addNotif(
                              NotificationModel(
                                key: uniqueKey,
                                name: titleController.text,
                                description: descController.text,
                                // Edit this
                                time: value,
                              ),
                            );
                      }).then((value) {
                        // clear form
                        titleController.text = '';
                        descController.text = '';

                        // close modal
                        Navigator.pop(context);
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(CustomColor.background),
                    ),
                    child: const CustomText(
                      text: 'Create New',
                    ),
                  ),
                  const SizedBox(height: 15)
                ],
              ),
            ));
  }
}
