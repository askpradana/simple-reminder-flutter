import 'package:bloc/bloc.dart';
import 'package:gameconsign/model/notif_model.dart';
import 'package:gameconsign/core/notification_setting.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'notif_state.dart';

class NotifCubit extends Cubit<NotifState> {
  late final Box<NotificationModel> _notificationsBox;

  NotifCubit() : super(NotifLoading()) {
    _initializeBox();
  }

  void _initializeBox() async {
    _notificationsBox = Hive.box<NotificationModel>('notifications');
    emit(NotifInitial(notifications: _notificationsBox.values.toList()));
  }

  int generateUniqueKey() {
    final currentKeys = _notificationsBox.keys.cast<int>();
    if (currentKeys.isEmpty) {
      return 0;
    } else {
      return currentKeys.reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  void addNotif(NotificationModel model) async {
    await _notificationsBox.put(model.key, model);
    emit(NotifInitial(notifications: _notificationsBox.values.toList()));
  }

  void deleteNotif(int key) async {
    await _notificationsBox.delete(key);
    NotificationService().cancelNotification(key);
    emit(NotifInitial(notifications: _notificationsBox.values.toList()));
  }
}
