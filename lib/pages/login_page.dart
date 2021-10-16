import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_india/components/custom_gradient_button.dart';
import 'package:pulse_india/components/custom_progress_handler.dart';
import 'package:pulse_india/components/flushbar_message.dart';
import 'package:pulse_india/constants/http_status_codes.dart';
import 'package:pulse_india/constants/message_types.dart';
import 'package:pulse_india/constants/project_settings.dart';
import 'package:pulse_india/handlers/database_handler.dart';
import 'package:pulse_india/handlers/network_handler.dart';
import 'package:pulse_india/localization/app_translations.dart';
import 'package:pulse_india/models/user.dart';
import 'package:pulse_india/pages/home_page.dart';
import 'package:pulse_india/pages/sign_up_page.dart';

import '../app_data.dart';
import '../components/custom_password_field.dart';
import '../components/custom_text_field.dart';
import '../components/flushbar_message.dart';
import '../constants/message_types.dart';
import '../constants/project_settings.dart';
import '../handlers/network_handler.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double bottom1;
  bool _isLoading;
  String _loadingText;
  String smsAutoId;
  DBHandler _dbHandler;

  TextEditingController userIDController;
  TextEditingController passwordController;
  FocusNode _userIDFocusNode;
  FocusNode _passwordFocusNode;
  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _loginPageGlobalKey =
      new GlobalKey<ScaffoldState>();
  String deviceId = "1";

  @override
  Future<void> initState() {
    // TODO: implement initState
    super.initState();
    _getId().then((res) {
      setState(() {
        deviceId = res;
      });
    });
    _dbHandler = DBHandler();
    userIDController = TextEditingController();
    _userIDFocusNode = FocusNode();
    passwordController = TextEditingController();
    _userIDFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _isLoading = false;
    _loadingText = 'Loading . . .';

    ConnectivityManager().initConnectivity(this.context, this);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return CustomProgressHandler(
      isLoading: this._isLoading,
      loadingText: this._loadingText,
      child: Scaffold(
        key: _loginPageGlobalKey,
        resizeToAvoidBottomInset: true,
        body: Container(
          height: double.infinity,
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: new AssetImage("assets/images/app_bg.jpg"),
                fit: BoxFit.cover),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  Container(
                    // margin: EdgeInsets.only(top: _large? _height/20 : (_medium? _height/20 : _height/15)),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width * 0.2,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  CustomTextField(
                    keyboardType: TextInputType.text,
                    autofoucus: false,
                    textEditingController: userIDController,
                    focusNode: _userIDFocusNode,
                    onFieldSubmitted: (value) {
                      this._userIDFocusNode.unfocus();
                      FocusScope.of(context)
                          .requestFocus(this._passwordFocusNode);
                    },
                    icon: Icons.person_outline_outlined,
                    hint: AppTranslations.of(context).text("key_userId"),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  CustomPasswordField(
                    keyboardType: TextInputType.text,
                    textEditingController: passwordController,
                    obscureText: true,
                    icon: Icons.lock_outline_sharp,
                    hint: AppTranslations.of(context).text("key_password"),
                    focusNode: _passwordFocusNode,
                    onFieldSubmitted: (value) {
                      this._passwordFocusNode.unfocus();
                    },
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      FlushbarMessage.show(
                          context,
                          AppTranslations.of(context)
                              .text("key_forgot_password_instruction"),
                          MessageTypes.SUCCESS);
                    },
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        AppTranslations.of(context).text("key_forgot_password"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Theme.of(context).primaryColorLight,
                              //fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  CustomGradientButton(
                    caption: AppTranslations.of(context).text("key_login"),
                    onPressed: () async {
                      String validation = await _validateLoginForm(
                          userIDController.text, passwordController.text);
                      if (validation == "")
                        _loginUser();
                      else
                        FlushbarMessage.show(
                          context,
                          AppTranslations.of(context).text(validation),
                          MessageTypes.WARNING,
                        );
                    },
                  ),
                  signUpTextRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget signUpTextRow() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            AppTranslations.of(context).text("key_account_instruction"),
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
          ),
          RawMaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SignUpPage(),
                  ),
                );
              },
              constraints: BoxConstraints(),
              padding: EdgeInsets.all(
                5.0,
              ),
              // optional, in order to add additional space around text if needed
              child: Text(
                AppTranslations.of(context).text("key_sign_up"),
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ))
        ],
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _loadingText = AppTranslations.of(context).text("key_validating");
    });

    try {
      String retMsg = await _validateLoginForm(
        userIDController.text,
        passwordController.text,
      );

      if (retMsg == '') {
        User user = await getLocalUser(
          userIDController.text,
          passwordController.text,
        );
        if (user != null) {
          setState(() {
            _isLoading = false;
          });
          user = await _dbHandler.login(user);
          print(user.RoleName);
          appData.user = await _dbHandler.login(user);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              //  builder: (_) => SelectServicePage(),
              builder: (_) => HomePage(),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          _loginUser();
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        FlushbarMessage.show(
          context,
          retMsg,
          MessageTypes.ERROR,
        );
      }
    } on SocketException {
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_connection_lost"),
        MessageTypes.ERROR,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_login_instruction"),
        MessageTypes.WARNING,
      );
    }
  }

  Future<String> _validateLoginForm(String userID, String userPassword) async {
    if (userID.length == 0) {
      return AppTranslations.of(context).text("key_enter_user_id");
    }
    /*if (userID.length != 10 || userID.length < 10) {
      return "Enter Valid Mobile Number.";
    }*/

    if (userPassword.length == 0) {
      return AppTranslations.of(context).text("key_enter_user_password");
    }
    if (deviceId == '' || deviceId == null)
      return AppTranslations.of(context).text("key_enter_device_id");

    return "";
  }

  Future<User> getLocalUser(String userID, String userPassword) async {
    try {
      User user;

      await _dbHandler.getUser(userID, userPassword).then(
        (result) {
          user = result;
        },
      );

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
      _loadingText = AppTranslations.of(context).text("key_validating");
    });
    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Uri getUserDetailsUri = Uri.parse(
            connectionServerMsg + ProjectSettings.rootUrl + UserUrls.GET_USER,
          ).replace(
            queryParameters: {
              /*"user_id": userIDController.text,
              "user_pwd": passwordController.text,
              "deviceId": deviceId,*/
              "user_id": "Kazi",
              "user_pwd": "Yessir@123",
              "deviceId": "cc72d2c2d1e542f1"
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
                  AppTranslations.of(context).text("key_invalid_User_id"),
                  MessageTypes.ERROR,
                );
              } else {
                if (user.UserPass == passwordController.text) {
                  //Save user to local db
                  user = await _dbHandler.saveUser(user);
                  if (user != null) {
                    user = await _dbHandler.login(user);
                    appData.user = user;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    FlushbarMessage.show(
                      context,
                      AppTranslations.of(context)
                          .text("key_invalid_local_login"),
                      MessageTypes.ERROR,
                    );
                  }
                } else {
                  FlushbarMessage.show(
                    context,
                    AppTranslations.of(context).text("key_invalid_password"),
                    MessageTypes.ERROR,
                  );
                }
              }
            }
          } else {
            FlushbarMessage.show(
              this.context,
              'Invalid response received (${response.statusCode})',
              MessageTypes.ERROR,
            );
          }
        } else {
          FlushbarMessage.show(
            this.context,
            AppTranslations.of(context).text("key_no_server"),
            MessageTypes.WARNING,
          );
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
      }
    } on SocketException {
      FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_connection_lost"),
          MessageTypes.ERROR);
    } catch (e) {
      print(e);
      FlushbarMessage.show(
        context,
        e.toString(),
        MessageTypes.ERROR,
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
}
