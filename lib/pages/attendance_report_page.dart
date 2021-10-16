import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pulse_india/app_data.dart';
import 'package:pulse_india/components/custom_cupertino_action.dart';
import 'package:pulse_india/components/custom_cupertino_action_message.dart';
import 'package:pulse_india/components/custom_progress_handler.dart';
import 'package:pulse_india/components/custom_search_in_dropdown.dart';
import 'package:pulse_india/components/custon_dropdown_list.dart';
import 'package:pulse_india/components/flushbar_message.dart';
import 'package:pulse_india/constants/http_status_codes.dart';
import 'package:pulse_india/constants/message_types.dart';
import 'package:pulse_india/constants/project_settings.dart';
import 'package:pulse_india/handlers/network_handler.dart';
import 'package:pulse_india/handlers/string_handlers.dart';
import 'package:pulse_india/localization/app_translations.dart';
import 'package:pulse_india/models/attendance_details.dart';
import 'package:pulse_india/models/attendance_summary.dart';
import 'package:pulse_india/models/department.dart';
import 'package:pulse_india/models/user.dart';

import '../handlers/string_handlers.dart';

class AttendanceReportPage extends StatefulWidget {
  @override
  _AttendanceReportPageState createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  bool isLoading;
  String loadingText;
  List<AttendanceReport> attendanceReports = [];
  List<AttendanceSummary> summaryReports = [];
  List<Department> departments = [];
  Department selectedDepartment;
  String filter,
      selectedReportType = "Details",
      SelectedAttStatus, // = "All",
      deptID,
      attendancecat;
  List<String> reportType = [
    'Details',
    'Summary',
  ];
  List<String> attendanceStatus = [
    'All',
    'Absent',
    'Half Day',
    'Late Mark',
    'Present',
  ];
  List<User> _user = [];
  List<int> userIndexes = [];
  List<User> _filteredList = [];
  User selectedEmployee;
  double _addItemHeight;
  TextEditingController filterController;
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

  GlobalKey<ScaffoldState> _AttendanceReportKey =
      new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _AttendanceReportKey = GlobalKey<ScaffoldState>();
    this.loadingText = 'loading...';
    this.isLoading = false;
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
    if (appData.user.RoleNo == 1) {
      fetchDepartment().then((result) {
        setState(() {
          this.departments = result;
          if (departments != null && departments.length != 0) {
            departments.insert(
              0,
              new Department(
                DepId: 0,
                DepEName: "All",
                DepAEName: "",
              ),
            );
            // selectedDepartment = departments[0];
            deptID = selectedDepartment != null
                ? selectedDepartment.DepId.toString()
                : '0';
            fetchEmployee(deptID).then((result) {
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
                  //    selectedEmployee = _user[0];
                }
                /*else if (_user != null && _user.length != 0) {
                  selectedEmployee = _user[0];
                }*/
              });
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_addItemHeight == null) {
      _addItemHeight = MediaQuery.of(context).size.height * 0.5;
    }
    _filteredList = _user.where((item) {
      if (filter == null || filter == '')
        return true;
      else {
        return item.UserName.toLowerCase().contains(filter.toLowerCase());
      }
    }).toList();
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _AttendanceReportKey,
        appBar: AppBar(
          title:
              Text(AppTranslations.of(context).text("key_attendance_report")),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (selectedReportType == "Details") {
              fetchAttendanceReport().then((result) {
                setState(() {
                  attendanceReports = result;
                });
              });
            } else {
              fetchAttendanceSummaryReport().then((result) {
                setState(() {
                  summaryReports = result;
                });
              });
            }
          },
          child: Column(
            //  mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: () => setState(() {
                  _addItemHeight != 0.0
                      ? _addItemHeight = 0.0
                      : _addItemHeight =
                          MediaQuery.of(context).size.height * 0.5;
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
                child: !isLoading
                    ? selectedReportType == "Details"
                        ? getAtendanceDetailReport()
                        : getAtendanceSummaryReport()
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Widgets
  Widget getAtendanceSummaryReport() {
    int count = 0;
    return summaryReports != null && summaryReports.length != 0
        ? CupertinoScrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: CupertinoScrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.grey[300]),
                    child: DataTable(
                      showBottomBorder: true,
                      headingRowHeight: 40,
                      dataRowHeight: 40,
                      columnSpacing: 15,
                      headingTextStyle:
                          Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                      dataTextStyle:
                          Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Colors.black54,
                                //    fontWeight: FontWeight.w500,
                              ),
                      columns: [
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_sr_no"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context)
                                .text("key_employee_name"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_total_days"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_holiday"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context)
                                .text("key_present_count"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_late_mark"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_half_day"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context)
                                .text("key_absent_count"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_extra_count"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      rows: new List<DataRow>.generate(
                        summaryReports.length,
                        (int index) {
                          count++;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  count.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataCell(
                                Text(
                                  StringHandlers.capitalizeWords(
                                      summaryReports[index].UserName),
                                ),
                              ),
                              DataCell(
                                Text(
                                  summaryReports[index].TotalDays.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataCell(
                                Text(
                                  summaryReports[index].Holiday.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataCell(
                                Text(
                                  summaryReports[index].PresentCount.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataCell(
                                Text(
                                  summaryReports[index]
                                      .LateMarkCount
                                      .toString(),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              DataCell(
                                Text(
                                  summaryReports[index].HalfDayCount.toString(),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              DataCell(
                                Text(
                                  summaryReports[index].AbsentCount.toString(),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              DataCell(
                                Text(
                                  summaryReports[index].ExtraCount.toString(),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              'Data not found',
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.red,
                  ),
            ),
          );
  }

  Widget getAtendanceDetailReport() {
    int count = 0;
    return attendanceReports != null && attendanceReports.length != 0
        ? CupertinoScrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: CupertinoScrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.grey[300]),
                    child: DataTable(
                      showBottomBorder: true,
                      headingRowHeight: 40,
                      dataRowHeight: 40,
                      columnSpacing: 15,
                      headingTextStyle:
                          Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                      dataTextStyle:
                          Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Colors.black54,
                                //    fontWeight: FontWeight.w500,
                              ),
                      columns: [
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_sr_no"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_entry_date"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context)
                                .text("key_employee_name"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_in_time"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_out_time"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_status"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context)
                                .text("key_working_hours"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_extra_hours"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppTranslations.of(context).text("key_dept_name"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      rows: new List<DataRow>.generate(
                        attendanceReports.length,
                        (int index) {
                          count++;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  count.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataCell(
                                Text(
                                  attendanceReports[index].EntDate != null
                                      ? StringHandlers.getDisplayFormattedDate(
                                          attendanceReports[index].EntDate)
                                      : '',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataCell(
                                Text(
                                  StringHandlers.capitalizeWords(
                                      attendanceReports[index].UserName),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    attendanceReports[index].Ent_IN != null
                                        ? StringHandlers
                                            .getDisplayFormattedTime(
                                                attendanceReports[index].Ent_IN)
                                        : '---',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    attendanceReports[index].Ent_Out != null
                                        ? StringHandlers
                                            .getDisplayFormattedTime(
                                                attendanceReports[index]
                                                    .Ent_Out)
                                        : '---',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  attendanceReports[index].AtStatus,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              DataCell(
                                Text(
                                  attendanceReports[index].WorkingHrs,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    attendanceReports[index].ExtraHrs,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    attendanceReports[index].DepEName,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              'Data not found',
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.red,
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
            SizedBox(
              height: 10,
            ),
            CustomDropdownList(
              visibilityStatus: appData.user.RoleNo == 1,
              onActionTapped: () {
                if (departments == null) {
                  FlushbarMessage.show(
                    context,
                    AppTranslations.of(context)
                        .text("key_add_department_not_available"),
                    MessageTypes.WARNING,
                  );
                } else {
                  showClientDepartments();
                }
              },
              selectedText: selectedDepartment != null
                  ? selectedDepartment.DepEName
                  : 'Select Department',
            ),
            Visibility(
              visible: appData.user.RoleNo == 1,
              child: SizedBox(
                height: 10,
              ),
            ),
            CustomDropdownList(
              onActionTapped: () {
                showReportType();
              },
              selectedText: selectedReportType,
            ),
            SizedBox(
              height: 10,
            ),
            CustomDropdownList(
              visibilityStatus: selectedReportType == "Details",
              onActionTapped: () {
                showAttendanceStatus();
              },
              selectedText: SelectedAttStatus != null
                  ? SelectedAttStatus
                  : 'Select Attendance type',
            ),
            Visibility(
              visible: selectedReportType == "Details",
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
            Visibility(
              visible: appData.user.RoleNo == 1,
              child: SizedBox(
                height: 10,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColorLight,
              ),
              onPressed: () {
                String valMsg = getValidationMessage();
                if (valMsg != 'ok') {
                  FlushbarMessage.show(
                    context,
                    valMsg,
                    MessageTypes.WARNING,
                  );
                } else {
                  if (SelectedAttStatus == "All") {
                    attendancecat = "%";
                  } else if (SelectedAttStatus == "Absent") {
                    attendancecat = "A";
                  } else if (SelectedAttStatus == "Half Day") {
                    attendancecat = "HD";
                  } else if (SelectedAttStatus == "Late Mark") {
                    attendancecat = "LM";
                  } else if (SelectedAttStatus == "Present") {
                    attendancecat = "P";
                  }

                  if (selectedReportType == "Details") {
                    fetchAttendanceReport().then((result) {
                      setState(() {
                        attendanceReports = result;
                      });
                    });
                  } else {
                    fetchAttendanceSummaryReport().then((result) {
                      setState(() {
                        summaryReports = result;
                      });
                    });
                  }
                  setState(() {
                    _addItemHeight != 0.0
                        ? _addItemHeight = 0.0
                        : _addItemHeight = 450;
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

//Pop ups
  void showClientDepartments() {
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
          message: AppTranslations.of(context).text("key_current_department"),
        ),
        actions: List<Widget>.generate(
          departments.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: departments[i].DepEName,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedDepartment = departments[i];
                this.isLoading = true;
                deptID = selectedDepartment.DepId != null
                    ? selectedDepartment.DepId.toString()
                    : "%";
                fetchEmployee(deptID).then((result) {
                  setState(() {
                    _user = result;
                    if (_user != null &&
                        _user.length != 0 &&
                        _user.length > 1) {
                      _user.insert(0, new User(UserNo: 0, UserName: "ALL"));
                      selectedEmployee = _user[0];
                    } else if (_user != null && _user.length != 0) {
                      selectedEmployee = _user[0];
                    }
                  });
                });
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void showReportType() {
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
          message: AppTranslations.of(context).text("key_report_type"),
        ),
        actions: List<Widget>.generate(
          reportType.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: reportType[i],
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedReportType = reportType[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void showAttendanceStatus() {
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
          message: AppTranslations.of(context).text("key_attendance_status"),
        ),
        actions: List<Widget>.generate(
          attendanceStatus.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: attendanceStatus[i],
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                SelectedAttStatus = attendanceStatus[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  String getValidationMessage() {
    if (appData.user.RoleNo == 1) {
      if (selectedDepartment == null) {
        return AppTranslations.of(context).text("key_ins_select_department");
      } else if (selectedEmployee == null) {
        return AppTranslations.of(context).text("key_ins_select_employee");
      } else if (selectedReportType == 'Details' && SelectedAttStatus == null) {
        return AppTranslations.of(context).text("key_ins_select_att_type");
      }
    } else {
      if (selectedReportType == 'Details' && SelectedAttStatus == null) {
        return AppTranslations.of(context).text("key_ins_select_att_type");
      }
    }

    return 'ok';
  }

  Future<List<Department>> fetchDepartment() async {
    List<Department> dept;
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "DepId":
                appData.user.RoleNo == 1 ? '0' : appData.user.DepId.toString(),
          };

          Uri fetchDepartmentUri = NetworkHandler.getUri(
              connectionServerMsg +
                  ProjectSettings.rootUrl +
                  DepartmentUrls.GET_DEPT_LIST,
              params);

          http.Response response = await http.get(
            fetchDepartmentUri,
            headers: NetworkHandler.getHeader(),
          );

          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);
            if (data["Status"] == HttpStatusCodes.OK) {
              var parsedJson = data["Data"];
              setState(() {
                List responseData = parsedJson;
                dept = responseData
                    .map((item) => Department.fromJson(item))
                    .toList();
              });
            } else {
              FlushbarMessage.show(
                context,
                data["Message"],
                MessageTypes.ERROR,
              );
              dept = null;
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

        dept = null;
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

      dept = null;
    }
    setState(() {
      isLoading = false;
    });
    return dept;
  }

  Future<List<User>> fetchEmployee(String deptID) async {
    List<User> employee = [];

    try {
      setState(() {
        isLoading = true;
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {"DepId": deptID};

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

  Future<List<AttendanceReport>> fetchAttendanceReport() async {
    List<AttendanceReport> attendace = [];
    try {
      setState(() {
        isLoading = true;
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();

      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          String sDte = StringHandlers.getApiFormattedDate(startDate);
          String eDte = StringHandlers.getApiFormattedDate(endDate);
          Map<String, dynamic> param = {
            "sdt": sDte,
            "edt": eDte,
            "DepId": selectedDepartment == null
                ? appData.user.DepId.toString()
                : selectedDepartment.DepId.toString(),
            "AtStatus": attendancecat,
            "Empno": selectedEmployee == null
                ? appData.user.UserNo.toString()
                : selectedEmployee.UserNo.toString(),
          };

          Uri fetchAttendanceReportUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                AttendanceReportUrls.ATTENDANCE_REPORT,
            param,
          );

          print(fetchAttendanceReportUri);

          http.Response response = await http.get(
            fetchAttendanceReportUri,
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
                attendace = responseData
                    .map(
                      (item) => AttendanceReport.fromJson(item),
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
      isLoading = false;
    });

    return attendace;
  }

  Future<List<AttendanceSummary>> fetchAttendanceSummaryReport() async {
    List<AttendanceSummary> attendacesummary = [];

    try {
      setState(() {
        isLoading = true;
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          String sDte = StringHandlers.getApiFormattedDate(startDate);
          String eDte = StringHandlers.getApiFormattedDate(endDate);

          Map<String, dynamic> param = {
            "sdt": sDte,
            "edt": eDte,
            "DepId": selectedDepartment == null
                ? appData.user.DepId.toString()
                : selectedDepartment.DepId.toString(),
            "Empno": selectedEmployee == null
                ? appData.user.UserNo.toString()
                : selectedEmployee.UserNo.toString(),
          };
          Uri fetchStudentAttendanceReportUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                AttendanceSummaryUrls.ATTENDANCE_REPORT,
            param,
          );
          print(fetchStudentAttendanceReportUri);
          http.Response response = await http.get(
              fetchStudentAttendanceReportUri,
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
      isLoading = false;
    });

    return attendacesummary;
  }
}
