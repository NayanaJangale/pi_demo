import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_india/app_data.dart';
import 'package:pulse_india/components/responsive_ui.dart';
import 'package:pulse_india/handlers/database_handler.dart';
import 'package:pulse_india/models/user.dart';
import 'package:pulse_india/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/flushbar_message.dart';
import 'constants/http_status_codes.dart';
import 'constants/message_types.dart';
import 'constants/project_settings.dart';
import 'handlers/network_handler.dart';
import 'localization/app_translations.dart';
import 'models/app_configuration.dart';
import 'pages/login_page.dart';

class WelcomePage extends StatefulWidget {
  final SharedPreferences preferences;

  const WelcomePage({this.preferences});
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _welcomePageGlobalKey =
      new GlobalKey<ScaffoldState>();
  double _height, _width, _pixelRatio, bottom1;
  bool _large, _medium;
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();

    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));
    animation = new CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
      reverseCurve: Curves.elasticOut,
    );

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    ConnectivityManager().initConnectivity(this.context, this);
    getData();

    /* Duration threeSeconds = Duration(seconds: 3);
    Future.delayed(threeSeconds, () {
      checkCurrentLogin(context);
    });*/
  }

  void getData() {
    //Add code for version control depends on platform
    AppConfiguration appConfig;
    fetchLatestAppVersionCode().then((result) {
      appConfig = result;
      if (appConfig != null) {
        print(appConfig.ConfigurationValue);
        print(ProjectSettings.AppVersion);
        if (Platform.isAndroid &&
            appConfig.ConfigurationValue != ProjectSettings.AppVersion) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => WillPopScope(
              onWillPop: () {
                SystemNavigator.pop();
                return Future.value(true);
              },
              child: AlertDialog(
                title: Text("App Update Available"),
                content: Text("Please update the app to continue"),
                actions: <Widget>[
                  TextButton(
                    child: Text("Update Now"),
                    onPressed: () async {
                      /*const url =
                          "https://play.google.com/store/apps/details?id=net.sunshineagri.amethyst&hl=en";
                      if (await canLaunch(url)) {
                        await launch(url, forceWebView: false); //forceWebView
                      } else {
                        throw 'Could not launch $url';
                      }*/
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (Platform.isIOS &&
            appConfig.ConfigurationValue != ProjectSettings.IosAppVersion) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("App Update Available"),
              content: Text("Please update the app to continue"),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () async {
                    SystemNavigator.pop();
                    //Update this url when app published on App Store
                    /* const url =
                          "https://apps.apple.com/in/app/aarogyasetu/id1505825357";

                      if (await canLaunch(url)) {
                        await launch(url, forceWebView: false); //forceWebView
                      } else {
                        throw 'Could not launch $url';
                      }*/
                  },
                  child: Text("Update Now"),
                )
              ],
            ),
          );
        } else {
          Duration threeSeconds = Duration(seconds: 3);
          Future.delayed(threeSeconds, () {
            checkCurrentLogin(this.context);
          });
        }
      } else {
        Duration threeSeconds = Duration(seconds: 3);
        Future.delayed(threeSeconds, () {
          checkCurrentLogin(this.context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bottom1 = MediaQuery.of(context).viewInsets.bottom;
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Scaffold(
        key: _welcomePageGlobalKey,
        backgroundColor: Colors.white,
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: new AssetImage("assets/images/app_bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png',
                width: animation.value * 200,
                height: animation.value * 200,
              ),
              /*  Text(
                // "Spices & Grain Processing L.L.C.",
                AppTranslations.of(context).text("key_slogan"),
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                    fontSize: _large ? 18 : (_medium ? 18 : 16)),
              ),*/
            ],
          ),
        ));
  }

  Future<AppConfiguration> fetchLatestAppVersionCode() async {
    AppConfiguration appCon;
    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "ConfigurationGroup":
                Platform.isIOS ? "IOS Auto Update" : "Auto Update",
            "UserNo": "0",
          };

          Uri fetchLatestAppVersionCodeUri = Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                AppConfigurationUrls.GET_LATEST_APP_VERSION,
          ).replace(queryParameters: params);

          print(fetchLatestAppVersionCodeUri);
          http.Response response = await http.get(
            fetchLatestAppVersionCodeUri,
            headers: NetworkHandler.getHeader(),
          );
          var data = json.decode(response.body);
          print(data);
          if (response.statusCode == HttpStatusCodes.OK) {
            if (data["Status"] != HttpStatusCodes.OK) {
              appCon = null;
            } else {
              appCon = AppConfiguration.fromMap(data["Data"]);
            }
          } else {
            appCon = null;
            FlushbarMessage.show(
              this.context,
              'Invalid response received (${response.statusCode})',
              MessageTypes.ERROR,
            );
          }
        } else {
          appCon = null;
          FlushbarMessage.show(
            this.context,
            AppTranslations.of(context).text("key_no_server"),
            MessageTypes.WARNING,
          );
        }
      } else {
        appCon = null;
        FlushbarMessage.show(
          this.context,
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
      }
    } on SocketException {
      appCon = null;
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_socket_error"),
        MessageTypes.WARNING,
      );
    } catch (e) {
      print(e);
      appCon = null;
      FlushbarMessage.show(
        this.context,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }
    return appCon;
  }

  Future<User> _getUser(User user) async {
    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Uri getUserDetailsUri = Uri.parse(
            connectionServerMsg + ProjectSettings.rootUrl + UserUrls.GET_USER,
          ).replace(
            queryParameters: {
              "user_id": user.UserID,
              "user_pwd": user.UserPass,
              "deviceId": user.DeviceId,
            },
          );
          print(getUserDetailsUri);
          http.Response response = await http.get(
            getUserDetailsUri,
            headers: NetworkHandler.getHeader(),
          );
          print(getUserDetailsUri);
          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);

            if (data["Status"] != HttpStatusCodes.OK) {
              FlushbarMessage.show(
                this.context,
                data["Message"],
                MessageTypes.ERROR,
              );
            } else {
              print(data["Data"]);
              User user = User.fromJson(
                data["Data"],
              );
              if (user == null) {
                FlushbarMessage.show(
                  context,
                  '${user.UserID} not found in system',
                  MessageTypes.ERROR,
                );
                return null;
              } else {
                await DBHandler().updateUser(user);
                await DBHandler().login(user);

                return user;
              }
            }
          } else {
            FlushbarMessage.show(
              this.context,
              'Invalid response received (${response.statusCode})',
              MessageTypes.ERROR,
            );
            return null;
          }
        } else {
          FlushbarMessage.show(
            this.context,
            AppTranslations.of(context).text("key_no_server"),
            MessageTypes.WARNING,
          );
          return null;
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
        return null;
      }
    } on SocketException {
      FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_connection_lost"),
          MessageTypes.ERROR);
      return null;
    } catch (e) {
      print(e);
      FlushbarMessage.show(
        context,
        e.toString(),
        MessageTypes.ERROR,
      );
      return null;
    }
  }

  Future<void> checkCurrentLogin(BuildContext context) async {
    try {
      User user = await DBHandler().getLoggedInUser();

      user = await _getUser(user);
      if (user != null) {
        print(user.UserNo);
        appData.user = user;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(),
          ),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
      );
    }
  }
}
