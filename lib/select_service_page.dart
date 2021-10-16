import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_india/components/custom_search_box.dart';
import 'package:pulse_india/input_components/custom_app_drawer.dart';
import 'package:pulse_india/models/service_with_file_count.dart';
import 'package:pulse_india/pages/service_pending_files_page.dart';
import 'package:pulse_india/utils/circle_paints.dart';
import 'package:pulse_india/utils/clipper.dart';
import 'app_data.dart';
import 'components/flushbar_message.dart';
import 'components/responsive_ui.dart';
import 'constants/http_status_codes.dart';
import 'constants/message_types.dart';
import 'constants/project_settings.dart';
import 'handlers/network_handler.dart';
import 'input_components/loading_shimmer_effect_widget.dart';
import 'localization/app_translations.dart';
import 'pages/home_page.dart';

class Gradients {
  Color startColor, endColor;
  Gradients({
    this.startColor,
    this.endColor,
  });
}

class SelectServicePage extends StatefulWidget {
  @override
  _SelectServicePageState createState() => _SelectServicePageState();
}

class _SelectServicePageState extends State<SelectServicePage> {
  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldHomeKey =
      new GlobalKey<ScaffoldState>();

  String msg = 'Services not available. Kindly contact to Administrator';
  List<ServiceWithFileCount> services = [];
  List<ServiceWithFileCount> filteredList = [];

  TextEditingController filterController;
  String filter;

  List<List<Color>> colorCodes = [
    GradientColors.blue,
    GradientColors.teal,
    GradientColors.pink,
    GradientColors.cherry,
    GradientColors.violet,
    GradientColors.juicyOrange,
    GradientColors.darkPink,
    GradientColors.seaBlue,
    GradientColors.indigo,
    GradientColors.purple,
    GradientColors.purplePink,
    GradientColors.radish,
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;

    filterController = TextEditingController();
    filterController.addListener(() {
      setState(() {
        filter = filterController.text;
      });
    });
    fetchServices().then((value) {
      if (value != null) {
        services = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    filteredList = services.where((item) {
      if (filter == null || filter == '')
        return true;
      else {
        return item.SERVICEENAME.toLowerCase().contains(filter.toLowerCase());
      }
    }).toList();
    Size size = MediaQuery.of(context).size;
    double _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    bool large = ResponsiveWidget.isScreenLarge(size.width, _pixelRatio);
    bool medium = ResponsiveWidget.isScreenMedium(size.width, _pixelRatio);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Select Service'),
        ),
        drawer: AppDrawer(),
        body: Column(
          children: [
            CustomSearchBox(
              isVisible: isLoading != null && services.isNotEmpty,
              hintText: 'Search Service',
              filterController: filterController,
            ),
            Expanded(
              child: filteredList != null && filteredList.isNotEmpty
                  ? GridView.builder(
                      itemCount: filteredList.length,
                      primary: false,
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return new GestureDetector(
                          onTap: () {
                            setState(() {
                              appData.service = filteredList[index];
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServicePendingFilesPage(),
                              ),
                            );
                          },
                          child: _customCard(
                            icon: Icons.add_circle_outline_sharp,
                            item: filteredList[index].SERVICEENAME,
                            count: filteredList[index].FILECOUNT,
                          ),
                        );
                      },
                    )
                  : isLoading
                      ? GridView.builder(
                          itemCount: 6,
                          primary: false,
                          gridDelegate:
                              new SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: size.height * 0.2,
                              width: size.width * 0.4,
                              child: Container(
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: LoadingShimmerWidget(
                                  enabled: isLoading,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 20,
                                        left: 10,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 10,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              height: 10,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          margin: EdgeInsets.only(top: size.height * 0.06),
                          height: size.height * 0.5,
                          width: size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            msg,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      color: Colors.black54,
                                    ),
                          ),
                        ),
            ),
          ],
        ));
  }

  _customCard({IconData icon, String item, int count}) {
    List<Color> colors = colorCodes[Random().nextInt(colorCodes.length)];

    Size size = MediaQuery.of(context).size;
    double _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    bool large = ResponsiveWidget.isScreenLarge(size.width, _pixelRatio);
    bool medium = ResponsiveWidget.isScreenMedium(size.width, _pixelRatio);
    return SizedBox(
      height: size.height * 0.2,
      width: size.width * 0.4,
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          // color: color,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 1.0,
              spreadRadius: 1.0,
            )
          ],
        ),
        /*shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 1,*/
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(),
                /* CustomPaint(
                  painter: CircleOne(),
                ),*/
                CustomPaint(
                  painter: CircleTwo(),
                ),
              ],
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.all(3),
                child: Icon(
                  getIcon(item),
                  color: Colors.white,
                  size: large
                      ? 40
                      : medium
                          ? 30
                          : 20,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    item,
                    style: Theme.of(context).textTheme.bodyText1,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getIcon(String service) {
    switch (service) {
      case 'Inward':
        return Icons.arrow_circle_down_outlined;
        break;
      case 'Outward':
        return Icons.outbond_outlined;
        break;
      case 'Bag Transfers':
        return Icons.shopping_bag_outlined;
        break;
      case 'Stock Packaging':
        return Icons.backpack_outlined;
        break;
      case 'Stock Transferred':
        return Icons.filter_tilt_shift_sharp;
        break;
      case 'Stock Manufacturing':
        return Icons.precision_manufacturing_sharp;
        break;
      default:
        return Icons.filter_tilt_shift_sharp;
        break;
    }
  }

  Future<List<ServiceWithFileCount>> fetchServices() async {
    List<ServiceWithFileCount> allServices;
    setState(() {
      isLoading = true;
    });

    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "ServiceId": '0',
            "FileStatus": 'Pending',
          };

          Uri fetchServicesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ServiceWithFileCountUrls.GETSERVICEWISEALLYFILES,
            params,
          );

          print(fetchServicesUri);

          http.Response response = await http.get(
            fetchServicesUri,
            headers: NetworkHandler.getHeader(),
          );

          var data = json.decode(response.body);

          if (response.statusCode == HttpStatusCodes.OK) {
            if (data["Status"] != HttpStatusCodes.OK) {
              msg = data["Message"];
              FlushbarMessage.show(
                this.context,
                data["Message"],
                MessageTypes.ERROR,
              );
            } else {
              var parsedJson = data["Data"];
              setState(() {
                List responseData = parsedJson;
                allServices = responseData
                    .map((item) => ServiceWithFileCount.fromMap(item))
                    .toList();
              });
            }
          } else {
            FlushbarMessage.show(
              this.context,
              'Invalid response received (${response.statusCode})',
              MessageTypes.ERROR,
            );
          }
        } else {
          msg = AppTranslations.of(context).text("key_no_server");
          FlushbarMessage.show(
            this.context,
            AppTranslations.of(context).text("key_no_server"),
            MessageTypes.WARNING,
          );
        }
      } else {
        msg = AppTranslations.of(context).text("key_check_internet");
      }
    } on SocketException catch (error, stackTrace) {
      msg = AppTranslations.of(context).text("key_socket_error");
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_socket_error"),
        MessageTypes.WARNING,
      );
    } catch (e) {
      print(e);
      msg = AppTranslations.of(context).text("key_api_error");
      FlushbarMessage.show(
        this.context,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }

    setState(() {
      isLoading = false;
    });

    return allServices;
  }
}

class SelectServicePageOld extends StatefulWidget {
  @override
  _SelectServicePageOldState createState() => _SelectServicePageOldState();
}

class _SelectServicePageOldState extends State<SelectServicePageOld> {
  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldHomeKey =
      new GlobalKey<ScaffoldState>();

  String msg = 'Services not available. Kindly contact to Administrator';
  List<ServiceWithFileCount> services = [];
  /* List<String> options = [
    'Inward',
    'Outward',
    'Stock Manufacturing',
    'Stock Transferred',
    'Stock Packaging',
    'Bag Transfers',
  ];*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    fetchServices().then((value) {
      services = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    bool large = ResponsiveWidget.isScreenLarge(size.width, _pixelRatio);
    bool medium = ResponsiveWidget.isScreenMedium(size.width, _pixelRatio);
    return Scaffold(
      drawer: AppDrawer(),
      body: Stack(
        overflow: Overflow.visible,
        fit: StackFit.loose,
        children: <Widget>[
          ClipPath(
            clipper: ClippingClass(),
            child: Container(
              width: double.infinity,
              height: size.height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: size.width * 0.02,
            top: size.height * 0.04,
            child: Container(
              width: size.width * 0.15,
              height: size.height * 0.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/logo.png",
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: size.width * 0.05,
            right: size.width * 0.2,
            top: size.height * 0.14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppTranslations.of(context).text("key_hi") +
                      ' ' +
                      appData.user.UserName,
                  // StringHandlers.getFirstWord(appData.user.UserName),
                  style: Theme.of(context).textTheme.bodyText1,
                  //overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                /* Text(
                  "Manage your work",
                  style: Theme.of(context).textTheme.bodyText2,
                ),*/
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: size.height * 0.05, right: 10),
              child: Text(
                'App Version: 1.0.0',
                style: Theme.of(context).textTheme.overline.copyWith(
                      letterSpacing: 0.5,
                      color: Colors.grey,
                    ),
              ),
            ),
          ),
          Positioned(
            left: size.width * 0.05,
            top: size.height * 0.15,
            right: size.width * 0.05,
            child: Container(
              alignment: Alignment.topCenter,
              height: size.height * 0.8,
              width: size.width,
              child: services != null && services.isNotEmpty
                  ? GridView.builder(
                      itemCount: services.length,
                      primary: false,
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return new GestureDetector(
                          onTap: () {
                            setState(() {
                              appData.service = services[index];
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomePage(),
                              ),
                            );
                          },
                          child: _customCard(
                            icon: Icons.add_circle_outline_sharp,
                            item: services[index].SERVICEENAME,
                          ),
                        );
                      },
                    )
                  : isLoading
                      ? GridView.builder(
                          itemCount: 6,
                          primary: false,
                          gridDelegate:
                              new SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: size.height * 0.2,
                              width: size.width * 0.4,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                              child: LoadingShimmerWidget(
                                enabled: isLoading,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: size.height * 0.06,
                                      width: size.width * 0.3,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      height: size.height * 0.02,
                                      width: size.width * 0.3,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          margin: EdgeInsets.only(top: size.height * 0.06),
                          height: size.height * 0.5,
                          width: size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            msg,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      color: Colors.black54,
                                    ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  _customCard({IconData icon, String item}) {
    Size size = MediaQuery.of(context).size;
    double _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    bool large = ResponsiveWidget.isScreenLarge(size.width, _pixelRatio);
    bool medium = ResponsiveWidget.isScreenMedium(size.width, _pixelRatio);
    return SizedBox(
      height: size.height * 0.2,
      width: size.width * 0.4,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              getIcon(item),
              color: Theme.of(context).primaryColorLight,
              size: large
                  ? 40
                  : medium
                      ? 30
                      : 20,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getIcon(String service) {
    switch (service) {
      case 'Inward':
        return Icons.arrow_circle_down_outlined;
        break;
      case 'Outward':
        return Icons.outbond_outlined;
        break;
      case 'Bag Transfers':
        return Icons.shopping_bag_outlined;
        break;
      case 'Stock Packaging':
        return Icons.backpack_outlined;
        break;
      case 'Stock Transferred':
        return Icons.filter_tilt_shift_sharp;
        break;
      case 'Stock Manufacturing':
        return Icons.precision_manufacturing_sharp;
        break;
      default:
        return Icons.filter_tilt_shift_sharp;
        break;
    }
  }

  Future<List<ServiceWithFileCount>> fetchServices() async {
    List<ServiceWithFileCount> allServices;
    setState(() {
      isLoading = true;
    });

    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "ServiceId": '0',
            "FileStatus": '%',
          };

          Uri fetchServicesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ServiceWithFileCountUrls.GETSERVICEWISEALLYFILES,
            params,
          );

          print(fetchServicesUri);

          http.Response response = await http.get(
            fetchServicesUri,
            headers: NetworkHandler.getHeader(),
          );

          var data = json.decode(response.body);

          if (response.statusCode == HttpStatusCodes.OK) {
            if (data["Status"] != HttpStatusCodes.OK) {
              msg = data["Message"];
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
                allServices = responseData
                    .map((item) => ServiceWithFileCount.fromMap(item))
                    .toList();
              });
            }
          } else {
            FlushbarMessage.show(
              this.context,
              'Invalid response received (${response.statusCode})',
              MessageTypes.ERROR,
            );
          }
        } else {
          msg = AppTranslations.of(context).text("key_no_server");
          FlushbarMessage.show(
            this.context,
            AppTranslations.of(context).text("key_no_server"),
            MessageTypes.WARNING,
          );
        }
      } else {
        msg = AppTranslations.of(context).text("key_check_internet");
      }
    } on SocketException catch (error, stackTrace) {
      msg = AppTranslations.of(context).text("key_socket_error");
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_socket_error"),
        MessageTypes.WARNING,
      );
    } catch (e) {
      print(e);
      msg = AppTranslations.of(context).text("key_api_error");
      FlushbarMessage.show(
        this.context,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }

    setState(() {
      isLoading = false;
    });

    return allServices;
  }
}
