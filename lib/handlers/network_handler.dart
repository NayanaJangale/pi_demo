import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pulse_india/app_data.dart';
import 'package:pulse_india/constants/internet_connection.dart';
import 'package:pulse_india/models/user.dart';
import 'package:pulse_india/pages/no_connectivity_page.dart';

import '../app_data.dart';
import '../constants/project_settings.dart';

class NetworkHandler {
  static Uri getUri(String url, Map<String, dynamic> params) {
    try {
      params.addAll({
        UserFieldNames.UserNo:
            appData.user != null ? appData.user.UserNo.toString() : '',
        UserFieldNames.ClientId:
            appData.user == null ? "" : appData.user.ClientId.toString(),
        UserFieldNames.Brcode:
            appData.user == null ? "" : appData.user.Brcode.toString(),
        UserFieldNames.UserID:
            appData.user == null ? "" : appData.user.UserID.toString()
      });
      Uri uri = Uri.parse(url);

      return uri.replace(queryParameters: params);
    } catch (e) {
      return null;
    }
  }

  static Map<String, String> getHeader() {
    return {
      "CheckSum": ProjectSettings.AppKey,
    };
  }

  static Map<String, String> postHeader() {
    return {
      "CheckSum": ProjectSettings.AppKey,
      "Accept": "application/json",
      "content-type": "application/json",
    };
  }

  static Future<String> checkInternetConnection() async {
    String status;
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        // I am connected to a mobile network.
        status = InternetConnection.CONNECTED;
      } else {
        // I am connected to no network.
        status = InternetConnection.NOT_CONNECTED;
      }
    } catch (e) {
      status = InternetConnection.NOT_CONNECTED;
      status = 'Exception: ' + e.toString();
    }
    return status;
  }

  static Future<String> getServerWorkingUrl() async {
    String connectionStatus = await NetworkHandler.checkInternetConnection();
    if (connectionStatus == InternetConnection.CONNECTED) {
      //Uncomment following to test local api
        return ProjectSettings.LocalApiUrl;

      return ProjectSettings.GlobalApiUrl;

      /*List<LiveServer> liveServers = [];

      Uri getLiveUrlsUri = Uri.parse(
        LiveServerUrls.serviceUrl,
      );

      http.Response response = await http.get(getLiveUrlsUri);

      if (response.statusCode == HttpStatusCodes.OK) {
        var data = json.decode(response.body);

        var parsedJson = data["Data"];

        List responseData = parsedJson;
        liveServers =
            responseData.map((item) => LiveServer.fromMap(item)).toList();

        String url;
        if (liveServers.length != 0 && liveServers.isNotEmpty) {
          for (var server in liveServers) {
            try {
              Uri checkUrl = Uri.parse(
                server.ipurl,
              );
              http.Response checkResponse = await http.get(checkUrl).timeout(
                    Duration(seconds: 10),
                  );

              if (checkResponse.statusCode == HttpStatusCodes.OK) {
                return server.ipurl;
              }
            } on TimeoutException catch (_) {
              continue;
            }
          }
          return "key_no_server";
        } else {
          return "key_no_server";
        }
      } else {
        return "key_no_server";
      }*/
    } else {
      return "key_check_internet";
    }
  }
}

class ConnectivityManager {
  StreamSubscription<ConnectivityResult> subscription;
  Connectivity connectivity = new Connectivity();
  ConnectivityState _connectivityState;
  bool isPageAdded = false;

  void initConnectivity(BuildContext context, dynamic contextState) {
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        print("rak : $contextState");
       // contextState.getData();
        if (_connectivityState != null &&
            _connectivityState != ConnectivityState.online)
          _connectivityState = ConnectivityState.online;

        if (isPageAdded) Navigator.of(context).pop();
        isPageAdded = false;
      } else {
        _connectivityState = ConnectivityState.offline;

        pushInternetOffScreen(context);
      }
    });
  }

  void pushInternetOffScreen(BuildContext context) {
    Navigator.of(context).push(
      new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return NoConnectivityPage();
        },
        fullscreenDialog: true,
      ),
    );
    isPageAdded = true;
  }

  void dispose() {
    subscription.cancel();
  }
}

enum ConnectivityState { offline, online }
