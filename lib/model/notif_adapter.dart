import 'package:flutter/material.dart';
import 'package:gameconsign/model/notif_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final typeId = 0;

  @override
  NotificationModel read(BinaryReader reader) {
    return NotificationModel(
      key: reader.readInt(),
      name: reader.readString(),
      description: reader.readString(),
      time: TimeOfDay(
        hour: reader.readInt(),
        minute: reader.readInt(),
      ),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer.writeInt(obj.key);
    writer.writeString(obj.name!);
    writer.writeString(obj.description!);
    writer.writeInt(obj.time!.hour);
    writer.writeInt(obj.time!.minute);
  }
}
