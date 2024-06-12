import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaemcosign/cubit/notif_cubit.dart';
import 'package:gaemcosign/model/notif_model.dart';
import 'package:gaemcosign/notification_setting.dart';
import 'package:gaemcosign/pages/detail_page.dart';
import 'package:gaemcosign/theme/color.dart';
import 'package:gaemcosign/theme/custom_text.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

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
            body: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildBody(state.notifications, context),
            ),
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
      return const Center(
        child: CustomText(text: 'It`s empty 👀'),
      );
    }

    return ListView.builder(
      itemCount: notifications.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
            child: Column(
              children: const [
                Text(
                  'Hello John! 👋',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'What You want to do today? 🤔',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        } else {
          final notification = notifications[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SwipeableTile(
              key: UniqueKey(),
              color: CustomColor.primary,
              direction: SwipeDirection.horizontal,
              onSwiped: (direction) {
                context.read<NotifCubit>().deleteNotif(notification.key);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: CustomColor.white,
                    content: Text(
                      'Deleted 👍',
                      style: TextStyle(
                        color: CustomColor.black,
                      ),
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              backgroundBuilder: (context, direction, progress) {
                if (direction == SwipeDirection.endToStart) {
                  return Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  );
                } else if (direction == SwipeDirection.startToEnd) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20.0),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  );
                }
                return Container();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: CustomColor.primary,
                  boxShadow: [
                    BoxShadow(
                      color: CustomColor.primary.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(
                        title: notification.name!,
                        description:
                            notification.description ?? 'Add a description',
                        time:
                            '${notification.time!.hour.toString().padLeft(2, '0')}:${notification.time!.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text:
                              '${notification.time!.hour.toString().padLeft(2, '0')}:${notification.time!.minute.toString().padLeft(2, '0')}',
                          colour: CustomColor.onPrimary,
                        ),
                      ],
                    ),
                    title: CustomText(
                      text: notification.name!,
                      isBold: true,
                      colour: CustomColor.onPrimary,
                    ),
                    subtitle: notification.description != null &&
                            notification.description!.isNotEmpty
                        ? CustomText(
                            text: notification.description!,
                            colour: CustomColor.onPrimary,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          );
        }
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
    } else {
      return null;
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
                      hintText: 'Reminder Title',
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
                      hintText: 'Reminder Description',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: CustomColor.white,
                            content: Text(
                              'Hey! at least put some effort to write title 🫠',
                              style: TextStyle(
                                color: CustomColor.black,
                              ),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      var uniqueKey =
                          context.read<NotifCubit>().generateUniqueKey();

                      _scheduleNotification(context, uniqueKey).then((value) {
                        if (value == null) {
                          // Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: CustomColor.white,
                              content: Text(
                                'Forget to set time❓',
                                style: TextStyle(
                                  color: CustomColor.black,
                                ),
                              ),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          return;
                        }
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

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: CustomColor.white,
                            content: Text(
                              'Ok, I`ll remind you 👋, swipe to cancel',
                              style: TextStyle(
                                color: CustomColor.black,
                              ),
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        // close modal
                        Navigator.pop(context);
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(CustomColor.black),
                    ),
                    child: const CustomText(
                      text: 'Create New',
                      colour: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15)
                ],
              ),
            ));
  }
}
