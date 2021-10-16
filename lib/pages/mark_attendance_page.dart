import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:pulse_india/app_data.dart';
import 'package:pulse_india/components/custom_cupertino_action.dart';
import 'package:pulse_india/components/custom_cupertino_action_message.dart';
import 'package:pulse_india/components/custom_progress_handler.dart';
import 'package:pulse_india/components/custon_dropdown_list.dart';
import 'package:pulse_india/components/flushbar_message.dart';
import 'package:pulse_india/constants/http_status_codes.dart';
import 'package:pulse_india/constants/message_types.dart';
import 'package:pulse_india/constants/project_settings.dart';
import 'package:pulse_india/handlers/network_handler.dart';
import 'package:pulse_india/input_components/custom_app_drawer.dart';
import 'package:pulse_india/localization/app_translations.dart';
import 'package:pulse_india/models/attendance.dart';
import 'package:pulse_india/models/department.dart';
import 'package:pulse_india/pages/custom_take_picture.dart';

import '../handlers/pop_up_handler.dart';
import 'home_page.dart';

class MarkAttendancePage extends StatefulWidget {
  @override
  _MarkAttendancePageState createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  bool isLoading, islocLoading;
  String loadingText,
      entryType,
      latitude = "",
      longitude = "",
      altitude = "",
      imagePath,
      address = "";
  String selectedItem = "InTime";
  List<String> attendanceType = ['InTime', 'OutTime'];
  GlobalKey<ScaffoldState> _AttendancePageGlobalKey;
  List<String> menus = ['Take Selfie'];
  File imgFile;
  List cameras;
  dynamic firstCamera;
  List<Department> departments = [];
  String selectedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  Department selectedDepartment;
  Size size;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _AttendancePageGlobalKey = GlobalKey<ScaffoldState>();
    this.loadingText = 'Searching Department';
    this.isLoading = true;
    this.islocLoading = true;

    ConnectivityManager().initConnectivity(this.context, this);
    getData();
  }

  getData() {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      firstCamera = cameras[1];
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return CustomProgressHandler(
      isLoading: this.isLoading || this.islocLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _AttendancePageGlobalKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            AppTranslations.of(context).text("key_mark_attendance"),
          ),
        ),
        drawer: AppDrawer(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: size.height * 0.01,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: CustomDropdownList(
                selectedText: selectedDepartment != null
                    ? selectedDepartment.DepEName
                    : 'Select Department',
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
                visibilityStatus: true,
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: CustomDropdownList(
                selectedText: selectedItem,
                onActionTapped: () {
                  showAttendanceType();
                },
                visibilityStatus: true,
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black54,
                    width: 0.5,
                  ),
                ),
                margin: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: imgFile == null
                            ? Container(
                                color: Colors.lightGreen[50],
                                child: Center(
                                  child: Text(
                                    AppTranslations.of(context)
                                        .text("key_attendance_selfie"),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          color: Colors.grey[500],
                                          //    fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              )
                            : Image.file(
                                imgFile,
                                //fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Divider(
                      color: Colors.black54,
                      height: 0.5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomTakePicture(
                              camera: firstCamera,
                            ),
                          ),
                        ).then((res) {
                          setState(() {
                            imgFile = File(res);
                          });
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                          size.height * 0.01,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: Colors.grey[700],
                            ),
                            Text(
                              menus[0],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            GestureDetector(
              onTap: () {
                String valMsg = getValidationMessage();
                if (valMsg != '') {
                  FlushbarMessage.show(
                    context,
                    valMsg,
                    MessageTypes.WARNING,
                  );
                } else {
                  postAttendance();
                }
              },
              child: Container(
                color: Theme.of(context).accentColor,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      AppTranslations.of(context).text("key_mark_attendance"),
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ),
                ),
              ),
            ),
            /*   CustomGradientButton(
                caption:
                    AppTranslations.of(context).text("key_mark_attendance"),
                onPressed: () {
                  String valMsg = getValidationMessage();
                  if (valMsg != '') {
                    FlushbarMessage.show(
                      context,
                      valMsg,
                      MessageTypes.WARNING,
                    );
                  } else {
                    postAttendance();
                  }
                },),*/
          ],
        ),
      ),
    );
  }

  Future<void> postAttendance() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Saving . . .';
      });
      if (selectedItem == "InTime") {
        entryType = 'I';
      } else {
        entryType = 'O';
      }
      Attendance attendance = Attendance(
          AttendanceId: 0,
          UserNo: appData.user.UserNo,
          EntDate: DateTime.now(),
          EntType: entryType,
          DepId: selectedDepartment.DepId,
          Latitude: latitude,
          Longitude: longitude,
          Address: address,
          IsNet: "Y",
          Selfie: null);

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {};
          Uri SaveDeptLocationUri = NetworkHandler.getUri(
              connectionServerMsg +
                  ProjectSettings.rootUrl +
                  AttendanceUrls.POST_ATTENDANCE,
              params);
          String jsonBody = json.encode(attendance);
          http.Response response = await http.post(
            SaveDeptLocationUri,
            headers: NetworkHandler.postHeader(),
            body: jsonBody,
            encoding: Encoding.getByName("utf-8"),
          );

          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);

            if (data["Status"] == HttpStatusCodes.CREATED) {
              if (imgFile != null) {
                await postAttendancveSelfie(data["Message"]);
              } else {
                FlushbarMessage.show(
                  context,
                  data["Message"],
                  MessageTypes.SUCCESS,
                );
              }

              _clearData();
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
      loadingText = 'Loading..';
    });
  }

  Future<void> postAttendancveSelfie(int locEntNo) async {
    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Uri postUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                AttendanceUrls.PostVisitSelfy,
            {
              'LocEntNo': locEntNo.toString(),
            },
          );

          final mimeTypeData =
              lookupMimeType(imgFile.path, headerBytes: [0xFF, 0xD8])
                  .split('/');
          final imageUploadRequest =
              http.MultipartRequest(HttpRequestMethods.POST, postUri);
          final file = await http.MultipartFile.fromPath(
            'image',
            imgFile.path,
            contentType: MediaType(
              mimeTypeData[0],
              mimeTypeData[1],
            ),
          );

          imageUploadRequest.fields['ext'] = mimeTypeData[1];
          imageUploadRequest.files.add(file);
          imageUploadRequest.headers.addAll(NetworkHandler.getHeader());
          final streamedResponse = await imageUploadRequest.send();
          final response = await http.Response.fromStream(streamedResponse);
          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);

            if (data["Status"] == HttpStatusCodes.CREATED) {
              PopupHandler.showSuccessPopup(
                context: this.context,
                title: 'Marked',
                description: 'Attendance marked successfully',
                onOkClick: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => HomePage(),
                    ),
                  );
                },
              );
              /* FlushbarMessage.show(
                context,
                data["Message"],
                MessageTypes.SUCCESS,
              );*/
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
  }

  _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    debugPrint('location: ${position.latitude}');
    /* Get Address from Lat Long
   install geocoder plugin
   final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print("${first.featureName} : ${first.addressLine}");
     address = first.addressLine;*/
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    altitude = position.altitude.toString();
    address = "";

    this.islocLoading = false;
    if (longitude == '' ||
        longitude == null ||
        latitude == '' ||
        latitude == null) {
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_location_instruction"),
        MessageTypes.WARNING,
      );
    } else {
      fetchDepartment().then((result) {
        setState(() {
          this.departments = result;
          if (departments != null && departments.length != 0) {
            selectedDepartment = departments[0];
            //departments.insert(0, new Department(DepId:  0,DepAEName: "" , DepEName:  "Select Department"));
          }
        });
      });
    }
  }

  void showAttendanceType() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_entry_type"),
        ),
        actions: List<Widget>.generate(
          attendanceType.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: attendanceType[i] == 'InTime' ? 'InTime' : 'OutTime',
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedItem =
                    attendanceType[i] == 'InTime' ? 'InTime' : 'OutTime';
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  String getValidationMessage() {
    if (selectedDepartment == '' || selectedDepartment == null)
      return AppTranslations.of(context).text("key_dept_instruction");

    if (longitude == '' || longitude == null)
      return AppTranslations.of(context).text("key_location_instruction");

    if (latitude == '' || latitude == null)
      return AppTranslations.of(context).text("key_location_instruction");

    if (this.imgFile == null) {
      return AppTranslations.of(context).text("key_selfie_instruction");
    }
    return '';
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
            "latitude": latitude, //"20.9972931",
            "longitude": longitude, //"75.5559695",
            "DepId": appData.user.DepId.toString()
          };

          Uri fetchDepartmentUri = NetworkHandler.getUri(
              connectionServerMsg +
                  ProjectSettings.rootUrl +
                  DepartmentUrls.GET_DEPT_FOR_OFFICE,
              params);

          print(fetchDepartmentUri);
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

  void _clearData() {
    setState(() {
      imgFile = null;
    });
  }

  void showClientDepartments() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
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
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
