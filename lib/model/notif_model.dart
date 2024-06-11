import 'package:flutter/material.dart';

class NotificationModel {
  final dynamic key;
  final String? name;
  final String? description;
  final TimeOfDay? time;

  NotificationModel({
    this.key,
    this.name,
    this.description,
    this.time,
  });
}
