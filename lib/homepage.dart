import 'package:flutter/material.dart';
import 'package:gaemcosign/model/notif_model.dart';
import 'package:gaemcosign/notification_setting.dart' as ns;
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ns.NotificationService notificationService;

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<NotificationModel> _reminderItem = [];
  final _reminderBox = Hive.box('reminder_box');

  int notificationId = 1;

  TimeOfDay? tempPickedTime;

  @override
  void initState() {
    super.initState();
    notificationService = ns.NotificationService();
    notificationService.initNotification();
    _refreshItems();
  }

  void _refreshItems() {
    List<NotificationModel> data = _reminderBox.keys.map((key) {
      final value = _reminderBox.get(key);
      int hour = int.parse(value['time'].split(':')[0]);
      int minute = int.parse(value['time'].split(':')[1].split(' ')[0]);
      String period = value['time'].split(' ')[1];

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return NotificationModel(
        key: key,
        name: value["name"],
        description: value['description'],
        time: TimeOfDay(hour: hour, minute: minute),
      );
    }).toList();

    setState(() {
      _reminderItem = data.reversed.toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _reminderBox.add(newItem);
    _refreshItems();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _reminderBox.put(itemKey, item);
    _refreshItems();
  }

  Future<void> _deleteItem(int itemKey) async {
    await _reminderBox.delete(itemKey);
    _refreshItems();

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Reminder deleted')));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _reminderItem.firstWhere((element) => element.key == itemKey);
      titleController.text = existingItem.name!;
      descController.text = existingItem.description!;
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
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: descController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _scheduleNotification(context).then((value) {
                        if (itemKey == null) {
                          _createItem({
                            "name": titleController.text,
                            "description": descController.text,
                            "time": tempPickedTime?.format(context)
                          });
                        }

                        if (itemKey != null) {
                          _updateItem(itemKey, {
                            'name': titleController.text.trim(),
                            'description': descController.text.trim()
                          });
                        }
                      }).then((value) {
                        titleController.text = '';
                        descController.text = '';

                        Navigator.pop(context);
                      });
                    },
                    child: Text(itemKey == null ? 'Create New' : 'Update'),
                  ),
                  const SizedBox(
                    height: 15,
                  )
                ],
              ),
            ));
  }

  showSnackbar(int hour, int minute) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm set for: $hour:$minute'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _scheduleNotification(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      await notificationService.scheduleNotification(
        id: notificationId,
        title: titleController.text,
        body: descController.text,
        timeOfDay: TimeOfDay(hour: pickedTime.hour, minute: pickedTime.minute),
      );
      notificationId++;
      tempPickedTime = pickedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _reminderItem.isEmpty
          ? const Center(
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 30),
              ),
            )
          : ListView.builder(
              itemCount: _reminderItem.length,
              itemBuilder: (_, index) {
                final currentItem = _reminderItem[index];
                return Card(
                  color: Colors.orange.shade100,
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                      title: Text(currentItem.name!),
                      subtitle: Text(currentItem.description.toString()),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${currentItem.time!.hour.toString().padLeft(2, '0')}:${currentItem.time!.minute.toString().padLeft(2, '0')}',
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteItem(currentItem.key),
                          ),
                        ],
                      )),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
