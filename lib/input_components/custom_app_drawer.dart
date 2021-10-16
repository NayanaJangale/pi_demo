import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_india/app_data.dart';
import 'package:pulse_india/handlers/database_handler.dart';
import 'package:pulse_india/models/menu.dart';
import 'package:pulse_india/pages/attendance_report_page.dart';
import 'package:pulse_india/pages/completed_files_page.dart';
import 'package:pulse_india/pages/file_details_report.dart';
import 'package:pulse_india/pages/locked_files_page.dart';
import 'package:pulse_india/pages/login_page.dart';
import 'package:pulse_india/pages/mark_attendance_page.dart';
import 'package:pulse_india/pages/upload_location_Page.dart';
import 'package:pulse_india/pages/view_sop_page.dart';

import '../components/flushbar_message.dart';
import '../constants/http_status_codes.dart';
import '../constants/menu_constants.dart';
import '../constants/message_types.dart';
import '../constants/project_settings.dart';
import '../handlers/network_handler.dart';
import '../localization/app_translations.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<Menu> menus = [];
  bool isLoading;
  bool isLocation;
  String loadingText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isLoading = false;
    isLocation = false;
    loadingText = 'Loading Menus';

    ConnectivityManager().initConnectivity(this.context, this);
    getData();
  }

  getData() {
    fetchMenus().then((value) {
      if (value != null) {
        menus = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0.0,
      child: Column(
        children: <Widget>[
          _createHeader(context),
          Divider(
            color: Colors.grey,
          ),
          isLoading
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CupertinoActivityIndicator(),
                )
              : Expanded(
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(),
                    itemCount: menus.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ExpansionTile(
                        title: Text(
                          menus[index].Name,
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                                color: Colors.black54,
                              ),
                        ),
                        children: menus[index].child.map((e) {
                          return _createDrawerItem(
                            context: context,
                            text: e.action_desc,
                            asset: getMenuImage(e.action_desc),
                            onTap: getMenuTap(e.action_desc),
                          );
                        }).toList(),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _createHeader(BuildContext context) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: MediaQuery.of(context).size.width * 0.02,
            top: MediaQuery.of(context).size.height * 0.03,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
                // color: Colors.white,
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/logo.png",
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.02,
            bottom: MediaQuery.of(context).size.height * 0.03,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appData.user.UserName,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.02,
            bottom: MediaQuery.of(context).size.height * 0.001,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  appData.user.DepEName,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Theme.of(context).primaryColorLight,
                      ),
                ),
                TextButton(
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.only(
                      top: 30,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    showLogoutConfirmationDialog();
                  },
                  child: Text(
                    'Log Out',
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context).primaryColorDark,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  showLogoutConfirmationDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            insetAnimationCurve: Curves.bounceIn,
            insetAnimationDuration: Duration(seconds: 2),
            title: Text(
              AppTranslations.of(context).text("key_logout"),
            ),
            content: Text(
              AppTranslations.of(context).text("key_cnf_logout"),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  AppTranslations.of(context).text("key_cancel"),
                ),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  DBHandler().logout(appData.user).then((user) {
                    if (user != null) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  });
                },
                child: Text(
                  AppTranslations.of(context).text("key_logout"),
                ),
              )
            ],
          );
        });
  }

  Widget _createDrawerItem(
      {IconData asset,
      String text,
      GestureTapCallback onTap,
      BuildContext context}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(
            asset,
            size: 25,
            color: Theme.of(context).accentColor,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.black54,
                  ),
            ),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  Function getMenuTap(String menuName) {
    switch (menuName) {
      case MenuNameConst.Attendance:
        print(MenuNameConst.Attendance);
        return () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MarkAttendancePage(),
            ),
          );
        };
        break;
      case MenuNameConst.UpdateLocation:
        return () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UploadClientLocationPage(),
            ),
          );
        };
        break;
      case MenuNameConst.ViewSop:
        return () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewSopPage(),
            ),
          );
        };
        break;
      case MenuNameConst.AttendanceReport:
        return () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttendanceReportPage(),
            ),
          );
        };
        break;
      case MenuNameConst.FileDetailsReport:
        return () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FileDetailsReportPage(),
            ),
          );
        };
        break;
      case MenuNameConst.LockedFiles:
        return () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LockedFilesPage(),
            ),
          );
        };
        break;
      case MenuNameConst.SignNdSubmit:
        return () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompletedFilesPage(),
            ),
          );
        };
        break;
      default:
        return () {
          FlushbarMessage.show(
            context,
            'Coming Soon...!',
            MessageTypes.WARNING,
          );
        };
        break;
    }
  }

  String getMenuName(String menuName) {
    switch (menuName) {
      default:
        return 'Menu';
        break;
    }
  }

  IconData getMenuImage(String menuName) {
    switch (menuName) {
      case MenuNameConst.Attendance:
        return Icons.person_add_alt_1_outlined;
        break;
      case MenuNameConst.UpdateLocation:
        return Icons.add_location_outlined;
        break;
      case MenuNameConst.AttendanceReport:
        return Icons.margin;
        break;
      default:
        return Icons.description;
        break;
    }
  }

  Future<List<Menu>> fetchMenus() async {
    List<Menu> allMenus;
    setState(() {
      isLoading = true;
    });

    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "UserNo": appData.user.UserNo.toString(),
          };

          Uri fetchMenusUri = NetworkHandler.getUri(
            connectionServerMsg + ProjectSettings.rootUrl + MenuUrls.GET_MENUS,
            params,
          );

          print(fetchMenusUri);

          http.Response response = await http.get(
            fetchMenusUri,
            headers: NetworkHandler.getHeader(),
          );

          var data = json.decode(response.body);

          if (response.statusCode == HttpStatusCodes.OK) {
            if (data["Status"] != HttpStatusCodes.OK) {
              FlushbarMessage.show(
                this.context,
                data["Message"],
                MessageTypes.ERROR,
              );
              //allMenus = await DBHandler().getMenuList();
            } else {
              var parsedJson = data["Data"];
              setState(() {
                List responseData = parsedJson;
                allMenus =
                    responseData.map((item) => Menu.fromMap(item)).toList();
              });

              //  await DBHandler().deleteMenus();
              //  await DBHandler().saveMenus(allMenus);
            }
          } else {
            // allMenus = await LocalDbHandler().getMenuList();

            FlushbarMessage.show(
              this.context,
              'Invalid response received (${response.statusCode})',
              MessageTypes.ERROR,
            );
          }
        } else {
          //    allMenus = await DBHandler().getMenuList();

          FlushbarMessage.show(
            this.context,
            AppTranslations.of(context).text("key_no_server"),
            MessageTypes.WARNING,
          );
        }
      } else {
        // allMenus = await DBHandler().getMenuList();
      }
    } on SocketException catch (error, stackTrace) {
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_socket_error"),
        MessageTypes.WARNING,
      );
    } catch (e) {
      print(e);
      FlushbarMessage.show(
        this.context,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
      //  allMenus = await DBHandler().getMenuList();
    }

    setState(() {
      isLoading = false;
    });

    return allMenus;
  }
}
