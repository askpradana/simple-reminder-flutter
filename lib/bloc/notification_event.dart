import 'package:flutter/material.dart';

abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {}

class AddNotification extends NotificationEvent {
  final String title;
  final String description;
  final TimeOfDay time;

  AddNotification(this.title, this.description, this.time);
}

class DeleteNotification extends NotificationEvent {
  final int key;

  DeleteNotification(this.key);
}
