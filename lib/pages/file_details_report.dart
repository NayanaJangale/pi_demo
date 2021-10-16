import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pulse_india/app_data.dart';
import 'package:pulse_india/components/custom_cupertino_action.dart';
import 'package:pulse_india/components/custom_cupertino_action_message.dart';
import 'package:pulse_india/components/custom_list_separator.dart';
import 'package:pulse_india/components/custom_progress_handler.dart';
import 'package:pulse_india/components/custom_search_in_dropdown.dart';
import 'package:pulse_india/components/custon_dropdown_list.dart';
import 'package:pulse_india/components/flushbar_message.dart';
import 'package:pulse_india/constants/file_status.dart';
import 'package:pulse_india/constants/http_status_codes.dart';
import 'package:pulse_india/constants/message_types.dart';
import 'package:pulse_india/constants/project_settings.dart';
import 'package:pulse_india/handlers/network_handler.dart';
import 'package:pulse_india/handlers/string_handlers.dart';
import 'package:pulse_india/localization/app_translations.dart';
import 'package:pulse_india/models/file_details.dart';
import 'package:pulse_india/models/file_details_report.dart';
import 'package:pulse_india/models/service.dart';
import 'package:pulse_india/models/user.dart';

class FileDetailsReportPage extends StatefulWidget {
  @override
  _FileDetailsReportPageState createState() => _FileDetailsReportPageState();
}

class _FileDetailsReportPageState extends State<FileDetailsReportPage> {
  bool isLoading, isReportLoading;
  String loadingText;

  double _addItemHeight;

  List<Service> services = [];
  Service selectedService;

  FStatus selectedFileStatus;

  List<User> _user = [];
  List<int> userIndexes = [];
  User selectedEmployee;

  List<FileDetailsReport> reportData = [];

  TextEditingController filterController;
  String filter;

  DateTime startDate =
      DateTime.utc(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime.now();

  Future<Null> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2021, 4),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
      if (endDate.isBefore(startDate)) {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_date_not_valid"),
          MessageTypes.ERROR,
        );
        setState(() {
          startDate = DateTime.now();
        });
      }
    }
  }

  Future<Null> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2021, 4),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
      if (endDate.isBefore(startDate)) {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_date_not_valid"),
          MessageTypes.ERROR,
        );

        setState(() {
          endDate = DateTime.now();
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.loadingText = 'loading...';
    this.isLoading = false;
    this.isReportLoading = false;

    filterController = new TextEditingController();
    filterController.addListener(() {
      setState(() {
        filter = filterController.text;
      });
    });

    ConnectivityManager().initConnectivity(this.context, this);
    getData();
  }

  getData() {
    fetchEmployee().then((result) {
      setState(() {
        _user = result;
        if (_user != null && _user.length != 0 && _user.length > 1) {
          _user.insert(
            0,
            new User(
              UserNo: 0,
              UserName: "All",
            ),
          );
        }
      });
    });
    fetchServices().then((result) {
      setState(() {
        services = result;
        if (services != null && services.length > 0) {
          services.insert(
            0,
            new Service(ServiceId: 0, ServiceEName: 'All'),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_addItemHeight == null) {
      _addItemHeight = MediaQuery.of(context).size.height * 0.4;
    }
    return CustomProgressHandler(
      isLoading: isLoading,
      loadingText: loadingText,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'File Details Report',
            //     AppTranslations.of(context).text("key_attendance_report"),
          ),
        ),
        body: Column(
          //  mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () => setState(() {
                _addItemHeight != 0.0
                    ? _addItemHeight = 0.0
                    : _addItemHeight = MediaQuery.of(context).size.height * 0.4;
              }),
              child: Container(
                color: Theme.of(context).primaryColorLight,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        AppTranslations.of(context).text("key_filter"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Theme.of(context).primaryColorDark,
                            ),
                      ),
                      Icon(
                        Icons.filter_alt_outlined,
                        color: Theme.of(context).primaryColorDark,
                        size: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: _addItemHeight,
              child: getInputWidgets(context),
            ),
            Expanded(
              child: isReportLoading
                  ? Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : reportData != null && reportData.isNotEmpty
                      ? ListView.builder(
                          itemCount: reportData.length,
                          itemBuilder: (context, index) {
                            FileDetailsReport item = reportData[index];

                            return Card(
                              color: Colors.grey.shade300,
                              child: ExpansionTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.SERVICENAME,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      StringHandlers.getDisplayFormattedDate(
                                        item.ENTDATETIME,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                            color: Colors.black87,
                                          ),
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.USERNAME,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                            color: Colors.black54,
                                          ),
                                    ),
                                    Text(
                                      item.FILECOUNT > 1
                                          ? '${item.FILECOUNT} files'
                                          : '${item.FILECOUNT} file',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                            color: Colors.black54,
                                          ),
                                    ),
                                  ],
                                ),
                                children: [
                                  LayoutBuilder(
                                    builder: (BuildContext context,
                                            BoxConstraints constraints) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: double.infinity,
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                      ),
                                      child: CupertinoScrollbar(
                                        child: ListView.separated(
                                          itemBuilder: (context, i) {
                                            FileDetails file = item.Details[i];
                                            return ListTile(
                                              title: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          file.FILENAME,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText1
                                                                  .copyWith(
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                        ),
                                                        Text(
                                                          getStatusText(
                                                              file.FILESTATUS),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText2
                                                                  .copyWith(
                                                                    color: getStatusColor(
                                                                        file.FILESTATUS),
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      file.container_no,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .copyWith(
                                                            color:
                                                                Colors.black45,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              subtitle: LayoutBuilder(
                                                builder: (BuildContext context,
                                                    BoxConstraints
                                                        constraints) {
                                                  double mWidth = constraints
                                                          .maxWidth *
                                                      (file.PROCESSPERCENTAGE /
                                                          100);

                                                  return Stack(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.green
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(5),
                                                          ),
                                                        ),
                                                        height: 10,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(5),
                                                          ),
                                                        ),
                                                        height: 10,
                                                        width: mWidth,
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                              /*trailing: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                color: Colors.grey[300],
                                                size: 20,
                                              ),*/
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return CustomListSeparator();
                                          },
                                          itemCount: item.Details.length,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'Report Not Available..',
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      color: Colors.red,
                                    ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getInputWidgets(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(5),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: Theme.of(context).accentColor,
                      ),
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: Text(
                            DateFormat('dd-MMM-yyyy').format(startDate),
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      color: Colors.grey[700],
                                    ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 8.0,
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _selectStartDate(context);
                            },
                            child: Icon(
                              Icons.date_range,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'To',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: Theme.of(context).accentColor,
                      ),
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: Text(
                            DateFormat('dd-MMM-yyyy').format(endDate),
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      color: Colors.grey[700],
                                    ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 8.0,
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _selectEndDate(context);
                            },
                            child: Icon(
                              Icons.date_range,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: appData.user.RoleNo == 1,
              child: SizedBox(
                height: 10,
              ),
            ),
            Visibility(
              visible: appData.user.RoleNo == 1,
              child: SearchInDropdown(
                iconEnabledColor: Colors.black54,
                items: _user.map((e) {
                  return DropdownMenuItem<User>(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        StringHandlers.capitalizeWords(
                          e.UserName,
                        ),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ),
                    value: e,
                  );
                }).toList(),
                value: selectedEmployee,
                hint: Text(
                  'Select Employee',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.black54,
                      ),
                ),
                searchHint: new Text(
                  'Search Employee',
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                        color: Colors.black54,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                onChanged: (dynamic Value) {
                  setState(() {
                    selectedEmployee = Value;
                  });
                },
                isExpanded: true,
                underline: Text(''),
                showIndexes: userIndexes,
                updateList: (String keyword) {
                  userIndexes.clear();
                  int i = 0;
                  _user.forEach((item) {
                    bool isContains = false;
                    isContains = item.UserName.toString()
                        .toLowerCase()
                        .contains(keyword.toLowerCase());
                    if (keyword.isEmpty || isContains) {
                      userIndexes.add(i);
                    }
                    i++;
                  });
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            CustomDropdownList(
              visibilityStatus: true,
              onActionTapped: () {
                showServices();
              },
              selectedText: selectedService != null
                  ? selectedService.ServiceEName
                  : 'Select Service',
            ),
            SizedBox(
              height: 10,
            ),
            CustomDropdownList(
              visibilityStatus: true,
              onActionTapped: () {
                showFileStatus();
              },
              selectedText: selectedFileStatus != null
                  ? selectedFileStatus.label
                  : 'Select File Status',
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColorLight,
              ),
              onPressed: () async {
                String valMsg = getValidationMessage();
                if (valMsg != 'Ok') {
                  FlushbarMessage.show(
                    context,
                    valMsg,
                    MessageTypes.WARNING,
                  );
                } else {
                  fetchReport().then((result) {
                    setState(() {
                      reportData = result;
                    });
                  });
                  setState(() {
                    _addItemHeight != 0.0
                        ? _addItemHeight = 0.0
                        : _addItemHeight =
                            MediaQuery.of(context).size.height * 0.4;
                  });
                }
              },
              child: Text(
                AppTranslations.of(context).text("key_view"),
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Theme.of(context).primaryColorDark,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getStatusText(String status) {
    switch (status) {
      case FileStatus.processed:
        return FileStatus.processed;
        break;
      case FileStatus.completed:
        return FileStatus.completed;
        break;
      case FileStatus.audited:
        return FileStatus.audited;
        break;
      case FileStatus.pending:
        return FileStatus.pending;
        break;

      case FileStatus.in_process:
        return 'In Process';
        break;
      case FileStatus.rejected:
        return FileStatus.rejected;
        break;
      default:
        return '';
        break;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case FileStatus.processed:
        return Colors.orange;
        break;
      case FileStatus.completed:
        return Colors.green.shade900;
        break;
      case FileStatus.audited:
        return Colors.green.shade900;
        break;
      case FileStatus.pending:
        return Colors.amber;
        break;
      case FileStatus.in_process:
        return Colors.blue;
        break;
      case FileStatus.rejected:
        return Colors.red;
        break;
      default:
        return Colors.black45;
        break;
    }
  }

  String getValidationMessage() {
    if (appData.user.RoleNo == 1) {
      if (selectedEmployee == null) {
        return 'Please Select Employee';
      } else if (selectedService == null) {
        return 'Please Select Service';
      } else if (selectedFileStatus == null) {
        return 'Please Select File Status';
      } else {
        return 'Ok';
      }
    } else {
      if (selectedService == null) {
        return 'Please Select Service';
      } else if (selectedFileStatus == null) {
        return 'Please Select File Status';
      } else {
        return 'Ok';
      }
    }
  }

  void showServices() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        message: CustomCupertinoActionMessage(
          message:
              'Select Service', //AppTranslations.of(context).text("key_attendance_status"),
        ),
        actions: List<Widget>.generate(
          services.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: services[i].ServiceEName,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedService = services[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void showFileStatus() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        message: CustomCupertinoActionMessage(
          message:
              'Select File Status', //AppTranslations.of(context).text("key_attendance_status"),
        ),
        actions: FStatus.fileStatusList
            .map((i) => CustomCupertinoActionSheetAction(
                  actionText: i.label,
                  actionIndex: FStatus.fileStatusList.indexOf(i),
                  onActionPressed: () {
                    setState(() {
                      selectedFileStatus = i;
                    });
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  Future<List<User>> fetchEmployee() async {
    List<User> employee = [];

    try {
      setState(() {
        isLoading = true;
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "DepId": '0',
          };

          Uri fetchEmployeeUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                UserUrls.GET_EMPLOYEE_FOR_REPORT,
            params,
          );

          http.Response response = await http.get(
            fetchEmployeeUri,
            headers: NetworkHandler.getHeader(),
          );

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
                employee = responseData
                    .map(
                      (item) => User.fromJson(item),
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
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }
    setState(() {
      isLoading = false;
    });

    return employee;
  }

  Future<List<Service>> fetchServices() async {
    List<Service> allServices;
    setState(() {
      isLoading = true;
    });

    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {};

          Uri fetchServicesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ServiceUrls.GetServices,
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
                allServices =
                    responseData.map((item) => Service.fromMap(item)).toList();
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
    }

    setState(() {
      isLoading = false;
    });

    return allServices;
  }

  Future<List<FileDetailsReport>> fetchReport() async {
    List<FileDetailsReport> filesReport;
    setState(() {
      isReportLoading = true;
      loadingText = 'Fetching Report';
    });

    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          String sDte = StringHandlers.getApiFormattedDate(startDate);
          String eDte = StringHandlers.getApiFormattedDate(endDate);

          Map<String, dynamic> params = {
            "sdt": sDte,
            "edt": eDte,
            "Empno": selectedEmployee != null
                ? selectedEmployee.UserNo.toString()
                : appData.user.UserNo.toString(),
            "ServiceId": selectedService.ServiceId.toString(),
            "FileStatus": selectedFileStatus.value,
          };

          Uri fetchReportUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                FileDetailsReportUrls.GetDatewiseProceedTallyFiles,
            params,
          );

          print(fetchReportUri);

          http.Response response = await http.get(
            fetchReportUri,
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
                filesReport = responseData
                    .map((item) => FileDetailsReport.fromMap(item))
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
    }

    setState(() {
      isReportLoading = false;
    });

    return filesReport;
  }
}
