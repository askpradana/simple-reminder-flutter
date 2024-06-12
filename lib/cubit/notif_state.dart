part of 'notif_cubit.dart';

abstract class NotifState {}

class NotifInitial extends NotifState {
  final List<NotificationModel> notifications;

  NotifInitial({required this.notifications});
}

class NotifLoading extends NotifState {}
