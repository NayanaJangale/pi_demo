import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';
import 'package:pulse_india/components/custom_fancy_button.dart';
import 'package:pulse_india/components/flushbar_message.dart';
import 'package:pulse_india/constants/http_status_codes.dart';
import 'package:pulse_india/constants/message_types.dart';
import 'package:pulse_india/constants/project_settings.dart';
import 'package:pulse_india/design_components/custom_progress_bar.dart';
import 'package:pulse_india/handlers/network_handler.dart';
import 'package:pulse_india/handlers/string_handlers.dart';
import 'package:pulse_india/input_components/custom_app_drawer.dart';
import 'package:pulse_india/input_components/loading_shimmer_effect_widget.dart';
import 'package:pulse_india/models/attendance_summary.dart';
import 'package:pulse_india/models/daywise_file_count.dart';
import 'package:pulse_india/select_service_page.dart';
import 'package:pulse_india/utils/clipper.dart';

import '../app_data.dart';
import '../components/responsive_ui.dart';
import '../localization/app_translations.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int touchedIndex;
  bool isBarLoading, isPieLoading;
  bool isChartReady = false;

  List<AttendanceSummary> attendanceSummary = [];

  Map<String, double> dataMap = Map();

  List<Color> colorList = [
    Color(0xff13d38e),
    Color(0xfff8b250),
    Color(0xff0293ee),
    Color(0xff845bef),
  ];

  List<DaywiseFIlesCount> filesCount = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isBarLoading = false;
    isPieLoading = false;
    ConnectivityManager().initConnectivity(this.context, this);
    getData();
  }

  getData() {
    fetchDaywiseFilesCount().then((value) {
      if (value != null) {
        filesCount = value;
      }
      fetchAttendanceSummary().then((value) {
        if (value != null) {
          attendanceSummary = value;
          processChartData();
        }
      });
    });
  }

  processChartData() {
    int total = attendanceSummary.first.TotalDays;
    int present = attendanceSummary.first.PresentCount;
    int absent = attendanceSummary.first.AbsentCount;
    int extra = attendanceSummary.first.ExtraCount;
    int holiday = attendanceSummary.first.Holiday;

    dataMap.putIfAbsent(
      "Present",
      () => present.toDouble(),
    );
    dataMap.putIfAbsent("Absent", () => absent.toDouble());
    dataMap.putIfAbsent("Holidays", () => holiday.toDouble());
    dataMap.putIfAbsent("Extra Days", () => extra.toDouble());

    isChartReady = true;
  }

  @override
  Widget build(BuildContext context) {
    print(appData.user.RoleName);
    Size size = MediaQuery.of(context).size;
    double _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    bool large = ResponsiveWidget.isScreenLarge(size.width, _pixelRatio);
    bool medium = ResponsiveWidget.isScreenMedium(size.width, _pixelRatio);
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 10, right: 10),
            child: Text(
              'App Version: 1.0.0',
              style: Theme.of(context).textTheme.overline.copyWith(
                    letterSpacing: 0.5,
                    color: Colors.grey,
                  ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Container(
          //height: size.height * 0.87,
          child: Column(
            children: [
              Stack(
                fit: StackFit.loose,
                children: <Widget>[
                  ClipPath(
                    clipper: ClippingClass(),
                    child: Container(
                      width: double.infinity,
                      height: size.height * 0.3,
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
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 16, left: 16),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: size.width * 0.15,
                                  height: size.height * 0.1,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        "assets/images/dummyUser.png",
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.02,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        AppTranslations.of(context)
                                                .text("key_hi") +
                                            ' ' +
                                            appData.user.UserName,
                                        // StringHandlers.getFirstWord(appData.user.UserName),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        appData.user.RoleName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                              color: Colors.white70,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: size.width * 0.05,
                      right: size.width * 0.05,
                      top: size.height * 0.12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                            shadowColor: Colors.grey.withOpacity(0.01), // added
                            type: MaterialType.card,
                            elevation: 10,
                            borderRadius: new BorderRadius.circular(10.0),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 8.0),
                                  child: Text(
                                    'Processed Files',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Colors.black45,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: isBarLoading
                                      ? Container(
                                          height: size.height * 0.25,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: List.generate(
                                              8,
                                              (index) => Container(
                                                width: 30,
                                                child: LoadingShimmerWidget(
                                                  enabled: true,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: new LayoutBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                BoxConstraints
                                                                    constraints) {
                                                          return Stack(
                                                            fit:
                                                                StackFit.expand,
                                                            children: <Widget>[
                                                              Container(
                                                                width: 10,
                                                                decoration:
                                                                    new BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              5.0)),
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.3),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                bottom: 0,
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      new BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(5.0)),
                                                                    shape: BoxShape
                                                                        .rectangle,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  height: constraints
                                                                          .maxHeight *
                                                                      (((index + 1) *
                                                                              10) /
                                                                          100),
                                                                  width: constraints
                                                                      .maxWidth,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        }),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Container(
                                                        decoration:
                                                            new BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5.0)),
                                                          color: Colors.white,
                                                        ),
                                                        height: 10,
                                                        width: 15,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : filesCount.isNotEmpty
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: filesCount
                                                  .map(
                                                    (e) => Container(
                                                      height:
                                                          size.height * 0.25,
                                                      child: ProgressVertical(
                                                        value: e.FILECOUNT,
                                                        date: StringHandlers
                                                            .getDayMonthFormattedDate(
                                                                e.PROCESSDATE),
                                                        isShowDate: true,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            )
                                          : Center(
                                              child: Text(
                                                'Files not found',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .copyWith(
                                                      color: Colors.redAccent,
                                                    ),
                                              ),
                                            ),
                                ),
                              ],
                            ) // added
                            ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Material(
                          shadowColor: Colors.grey.withOpacity(0.01), // added
                          type: MaterialType.card,
                          elevation: 10,
                          borderRadius: new BorderRadius.circular(10.0),
                          color: Colors.white,

                          child: isPieLoading
                              ? Container(
                                  height: size.height * 0.25,
                                  width: size.width * 0.9,
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: size.width * 0.3,
                                          child: LoadingShimmerWidget(
                                            enabled: true,
                                            child: Container(
                                              width: size.width * 0.3,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: size.width * 0.4,
                                        child: LoadingShimmerWidget(
                                          enabled: true,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    color: Colors.white,
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    width: 80,
                                                    margin: EdgeInsets.only(
                                                        left: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    color: Colors.white,
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    width: 80,
                                                    margin: EdgeInsets.only(
                                                        left: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    color: Colors.white,
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    width: 80,
                                                    margin: EdgeInsets.only(
                                                        left: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    color: Colors.white,
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    width: 80,
                                                    margin: EdgeInsets.only(
                                                        left: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              /* Container(
                                  height: size.height * 0.25,
                                  child: Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                )*/
                              : attendanceSummary.isNotEmpty && isChartReady
                                  ? PieChart(
                                      dataMap: dataMap,
                                      animationDuration:
                                          Duration(milliseconds: 800),
                                      chartRadius:
                                          MediaQuery.of(context).size.width *
                                              0.5,
                                      colorList: colorList,
                                      chartType: ChartType.disc,
                                      chartValuesOptions: ChartValuesOptions(
                                        showChartValuesOutside: true,
                                        showChartValues: true,
                                      ),
                                      legendOptions: LegendOptions(
                                        legendShape: BoxShape.rectangle,
                                        legendTextStyle: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                              color: Colors.black87,
                                            ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'Attendance not found',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                              color: Colors.redAccent,
                                            ),
                                      ),
                                    ),
                        ),
                        SizedBox(
                          height: size.height * 0.04,
                        ),
                        CustomFancyButton(
                          child: Text('Start Processing'),
                          size: size.width * 0.2,
                          color: Colors.green.shade500,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SelectServicePage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<AttendanceSummary>> fetchAttendanceSummary() async {
    List<AttendanceSummary> attendacesummary = [];

    try {
      setState(() {
        isBarLoading = true;
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          DateTime eDate = DateTime.now();
          DateTime sDate = DateTime(eDate.year, eDate.month, 1);

          String sDte = StringHandlers.getApiFormattedDate(sDate);
          String eDte = StringHandlers.getApiFormattedDate(eDate);

          Map<String, dynamic> param = {
            "sdt": sDte,
            "edt": eDte,
            "DepId": appData.user.DepId.toString(),
            "Empno": appData.user.UserNo.toString(),
          };
          Uri fetchAttendanceSummaryUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                AttendanceSummaryUrls.ATTENDANCE_REPORT,
            param,
          );
          print(fetchAttendanceSummaryUri);
          http.Response response = await http.get(fetchAttendanceSummaryUri,
              headers: NetworkHandler.getHeader());

          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);
            if (data["Status"] != HttpStatusCodes.OK) {
              FlushbarMessage.show(
                context,
                data["Message"],
                MessageTypes.ERROR,
              );
            } else {
              var parsedJson = data["Data"];
              setState(() {
                List responseData = parsedJson;
                attendacesummary = responseData
                    .map(
                      (item) => AttendanceSummary.fromJson(item),
                    )
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
    } on SocketException catch (error, stackTrace) {
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_socket_error"),
        MessageTypes.WARNING,
      );
    } catch (e) {
      print(e);
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }

    setState(() {
      isBarLoading = false;
    });

    return attendacesummary;
  }

  Future<List<DaywiseFIlesCount>> fetchDaywiseFilesCount() async {
    List<DaywiseFIlesCount> counts = [];

    try {
      setState(() {
        isPieLoading = true;
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          DateTime eDate = DateTime.now().add(Duration(days: -1));
          DateTime sDate = eDate.add(Duration(days: -6));

          String sDte = StringHandlers.getApiFormattedDate(sDate);
          String eDte = StringHandlers.getApiFormattedDate(eDate);

          Map<String, dynamic> param = {
            "sdt": sDte,
            "edt": eDte,
            "Empno": appData.user.UserNo.toString(),
          };
          Uri fetchDaywiseFilesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                DaywiseFIlesCountUrls.GetDatewiseTallyFiles,
            param,
          );
          print(fetchDaywiseFilesUri);
          http.Response response = await http.get(fetchDaywiseFilesUri,
              headers: NetworkHandler.getHeader());

          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);
            if (data["Status"] != HttpStatusCodes.OK) {
              FlushbarMessage.show(
                context,
                data["Message"],
                MessageTypes.ERROR,
              );
            } else {
              var parsedJson = data["Data"];
              setState(() {
                List responseData = parsedJson;
                counts = responseData
                    .map((item) => DaywiseFIlesCount.fromMap(item))
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
    } on SocketException catch (error, stackTrace) {
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_socket_error"),
        MessageTypes.WARNING,
      );
    } catch (e) {
      print(e);
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }

    setState(() {
      isPieLoading = false;
    });

    return counts;
  }
}

/*class HomePageOld extends StatefulWidget {
  @override
  _HomePageOldState createState() => _HomePageOldState();
}

class _HomePageOldState extends State<HomePageOld> {
  bool isLoading = false;
  bool isProcessing = false;
  String loadingText = 'Loading';
  final GlobalKey<ScaffoldState> _scaffoldHomeKey =
      new GlobalKey<ScaffoldState>();

  List<TallyFile> pendingFiles = [];
  List<TallyFile> filteredList = [];

  TextEditingController filterController;
  String filter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    filterController = new TextEditingController();
    filterController.addListener(() {
      setState(() {
        filter = filterController.text;
      });
    });

    fetchPendingFiles().then((value) {
      pendingFiles = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    bool large = ResponsiveWidget.isScreenLarge(size.width, _pixelRatio);
    bool medium = ResponsiveWidget.isScreenMedium(size.width, _pixelRatio);
    filteredList = pendingFiles.where((item) {
      if (filter == null || filter == '')
        return true;
      else {
        return item.FILENAME.toLowerCase().contains(filter.toLowerCase());
      }
    }).toList();
    return CustomProgressHandler(
      isLoading: isProcessing,
      loadingText: 'Processing',
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(appData.service.ServiceEName),
        ),
        drawer: AppDrawer(),
        body: SingleChildScrollView(
          child: Container(
            height: size.height * 0.88,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    shadowColor: Colors.grey.withOpacity(0.01), // added
                    type: MaterialType.card,
                    elevation: 10,
                    borderRadius: new BorderRadius.circular(10.0),
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                AppTranslations.of(context)
                                    .text("key_processed_files"),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(color: Colors.grey),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  ProgressVertical(
                                    value: 73,
                                    date: "Mon",
                                    isShowDate: true,
                                  ),
                                  ProgressVertical(
                                    value: 45,
                                    date: "Tue",
                                    isShowDate: true,
                                  ),
                                  ProgressVertical(
                                    value: 50,
                                    date: "Wed",
                                    isShowDate: true,
                                  ),
                                  ProgressVertical(
                                    value: 30,
                                    date: "Thu",
                                    isShowDate: true,
                                  ),
                                  ProgressVertical(
                                    value: 61,
                                    date: "Fri",
                                    isShowDate: true,
                                  ),
                                  ProgressVertical(
                                    value: 20,
                                    date: "Sat",
                                    isShowDate: true,
                                  ),
                                  ProgressVertical(
                                    value: 45,
                                    date: "Sun",
                                    isShowDate: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ), // added
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.of(context).text("key_pending"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColorDark,
                              ),
                        ),
                        GestureDetector(
                          onTap: () {
                            //Call all pending files page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                //     builder: (_) => ServicePendingFilesPage(),
                                builder: (_) => BarChartSample1(),
                              ),
                            );
                          },
                          child: Text(
                            AppTranslations.of(context).text("key_view_all"),
                            style: Theme.of(context).textTheme.caption.copyWith(
                                  color: Colors.blue,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          children: [
                            CustomSearchBox(
                              isVisible: pendingFiles != null &&
                                  pendingFiles.isNotEmpty,
                              hintText: 'Search File',
                              filterController: filterController,
                            ),
                            filteredList != null && filteredList.isNotEmpty
                                ? Expanded(
                                    child: CupertinoScrollbar(
                                      child: ListView.separated(
                                        itemBuilder: (context, index) {
                                          TallyFile file = filteredList[index];
                                          return ListTile(
                                            onTap: () async {
                                              //Call create Process api
                                              await postCreateProcess(file);
                                            },
                                            title: Text(
                                              file.FILENAME,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                    color: Colors.black87,
                                                  ),
                                            ),
                                            subtitle: Text(
                                              file.SERVICENAME,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .copyWith(
                                                    color: Colors.black54,
                                                  ),
                                            ),
                                            trailing: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              color: Colors.grey[300],
                                              size: 20,
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return CustomListSeparator();
                                        },
                                        itemCount: pendingFiles.length,
                                      ),
                                    ),
                                  )
                                : isLoading
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: LoadingShimmerWidget(
                                          enabled: isLoading,
                                          child: ListView.builder(
                                            itemBuilder: (_, __) => Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                border: Border.all(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              padding: EdgeInsets.all(10.0),
                                              margin: EdgeInsets.all(10.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height: 8.0,
                                                          color: Colors.white,
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      2.0),
                                                        ),
                                                        Container(
                                                          width:
                                                              size.width * 0.5,
                                                          height: 8.0,
                                                          color: Colors.white,
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      2.0),
                                                        ),
                                                        Container(
                                                          width:
                                                              size.width * 0.2,
                                                          height: 8.0,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8.0),
                                                  ),
                                                  Container(
                                                    width: size.width * 0.1,
                                                    height: size.height * 0.05,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            itemCount: 6,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          'Files not available',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .copyWith(
                                                color: Colors.black54,
                                              ),
                                        ),
                                      ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<TallyFile>> fetchPendingFiles() async {
    List<TallyFile> allFiles;
    setState(() {
      isLoading = true;
    });

    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "ServiceId": appData.service.ServiceId.toString(),
            "FileStatus": FileStatus.pending,
          };

          Uri fetchFilesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                TallyFileUrls.GetTallyFiles,
            params,
          );

          print(fetchFilesUri);

          http.Response response = await http.get(
            fetchFilesUri,
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
            } else {
              var parsedJson = data["Data"];
              setState(() {
                List responseData = parsedJson;
                allFiles = responseData
                    .map((item) => TallyFile.fromMap(item))
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
          FlushbarMessage.show(
            this.context,
            AppTranslations.of(context).text("key_no_server"),
            MessageTypes.WARNING,
          );
        }
      } else {
        FlushbarMessage.show(
          this.context,
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
      }
    } catch (e) {
      print(e);
      FlushbarMessage.show(
        this.context,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }

    setState(() {
      isLoading = false;
    });

    return allFiles;
  }

  Future<void> postCreateProcess(TallyFile file) async {
    try {
      setState(() {
        isProcessing = true;
        loadingText = 'Please wait';
      });

      Process process = Process(
        ProcessId: 0,
        FileId: file.FILEID,
        ServiceId: file.SERVICEID,
        UserNo: appData.user.UserNo,
        SignSubmit: false,
        ProcessStart: DateTime.now(),
      );

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {};

          Uri createProcessUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ProcessUrls.PostProcessMaster,
            params,
          );

          String jsonBody = json.encode(process);

          http.Response response = await http.post(
            createProcessUri,
            headers: NetworkHandler.postHeader(),
            body: jsonBody,
            encoding: Encoding.getByName("utf-8"),
          );
          setState(() {
            isProcessing = false;
            loadingText = 'Loading..';
          });
          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);

            if (data["Status"] == HttpStatusCodes.CREATED) {
              FlushbarMessage.show(
                context,
                data["Message"],
                MessageTypes.SUCCESS,
              );
              await Future.delayed(Duration(seconds: 4));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => FileProcessPage(
                    file: file,
                    processId: data["Data"],
                  ),
                ),
              );
            } else {
              FlushbarMessage.show(
                context,
                data["Message"],
                MessageTypes.ERROR,
              );
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
    } catch (e) {
      print(e);
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }
    setState(() {
      isProcessing = false;
      loadingText = 'Loading..';
    });
  }
}*/
