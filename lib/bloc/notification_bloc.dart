import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:gaemcosign/bloc/notification_event.dart';
import 'package:gaemcosign/bloc/notification_state.dart';
import 'package:gaemcosign/notification_setting.dart';
import 'package:hive/hive.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService notificationService;
  final Box _reminderBox;

  NotificationBloc(this.notificationService, this._reminderBox)
      : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<AddNotification>(_onAddNotification);
    on<DeleteNotification>(_onDeleteNotification);
  }

  int _generateNotificationId(DateTime dateTime) {
    // Generate a 32-bit integer from the timestamp
    return dateTime.hashCode & 0x7FFFFFFF; // Ensure positive 32-bit integer
  }

  void _onLoadNotifications(
      LoadNotifications event, Emitter<NotificationState> emit) async {
    try {
      emit(NotificationLoading());
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
      emit(NotificationLoaded(data.reversed.toList()));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  void _onAddNotification(
      AddNotification event, Emitter<NotificationState> emit) async {
    try {
      emit(NotificationLoading());
      int notificationId = _generateNotificationId(DateTime.now());
      await notificationService.scheduleNotification(
        id: notificationId,
        title: event.title,
        body: event.description,
        timeOfDay: event.time,
      );
      await _reminderBox.add({
        "name": event.title,
        "description": event.description,
        "time":
            '${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')} ${event.time.period == DayPeriod.am ? 'AM' : 'PM'}',
      });
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  void _onDeleteNotification(
      DeleteNotification event, Emitter<NotificationState> emit) async {
    try {
      emit(NotificationLoading());
      await _reminderBox.delete(event.key);
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
