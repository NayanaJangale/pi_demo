import 'package:pulse_india/models/service_with_file_count.dart';
import 'package:pulse_india/models/user.dart';

class AppData {
  static final AppData _appData = new AppData._internal();

  int client_No, Domain;
  String deviceId;
  ServiceWithFileCount service;
  User user;

  factory AppData() {
    return _appData;
  }
  AppData._internal();
}

final appData = AppData();
