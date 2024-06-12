import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaemcosign/cubit/notif_cubit.dart';
import 'package:gaemcosign/theme/color.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    this.notifKey,
  });

  final String title;
  final String description;
  final String time;
  final dynamic notifKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.read<NotifCubit>().deleteNotif(notifKey);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: CustomColor.black,
                content: Text(
                  'Nice 🎉',
                  style: TextStyle(
                    color: CustomColor.white,
                  ),
                ),
                duration: Duration(seconds: 1),
              ),
            );
            Navigator.pop(context);
          },
          elevation: 0,
          backgroundColor: CustomColor.black,
          label: const Text('Mark as completed'),
        ),
        body: ListView(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.short_text),
                      const SizedBox(width: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
