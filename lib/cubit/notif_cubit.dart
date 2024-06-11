import 'package:bloc/bloc.dart';
import 'package:gaemcosign/model/notif_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'notif_state.dart';

class NotifCubit extends Cubit<NotifInitial> {
  late final Box<NotificationModel> _notificationsBox;

  NotifCubit() : super(NotifInitial(notifications: [])) {
    _initializeBox();
  }

  void _initializeBox() async {
    _notificationsBox = Hive.box<NotificationModel>('notifications');
    emit(NotifInitial(notifications: _notificationsBox.values.toList()));
  }

  void addNotif(NotificationModel model) {
    _notificationsBox.put(model.key, model);
    emit(NotifInitial(notifications: _notificationsBox.values.toList()));
  }

  void deleteNotif() {
    _notificationsBox.clear();
    emit(NotifInitial(notifications: _notificationsBox.values.toList()));
  }
}
