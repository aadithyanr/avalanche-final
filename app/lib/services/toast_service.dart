import 'package:flutter/material.dart';
import '../widgets/toast_notification.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();
  static ToastService get instance => _instance;

  GlobalKey<State<StatefulWidget>>? _homeScreenKey;

  ToastService._internal();

  void setHomeScreen(GlobalKey<State<StatefulWidget>> homeScreenKey) {
    _homeScreenKey = homeScreenKey;
  }

  void showToast({
    required String message,
    Color backgroundColor = Colors.grey,
    Widget? icon,
  }) {
    // This is a simplified toast service that just prints to console
    // In a real app, you'd want to show actual toast notifications
    print('Toast: $message');
  }
} 