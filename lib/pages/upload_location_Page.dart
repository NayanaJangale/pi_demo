import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_india/components/custom_cupertino_action.dart';
import 'package:pulse_india/components/custom_cupertino_action_message.dart';
import 'package:pulse_india/components/custon_dropdown_list.dart';
import 'package:pulse_india/constants/http_status_codes.dart';
import 'package:pulse_india/constants/project_settings.dart';
import 'package:pulse_india/handlers/network_handler.dart';
import 'package:pulse_india/input_components/custom_app_drawer.dart';
import 'package:pulse_india/localization/app_translations.dart';
import 'package:pulse_india/models/department.dart';
import 'package:pulse_india/models/upload_location.dart';

import '../components/custom_progress_handler.dart';
import '../components/custom_text_field.dart';
import '../components/flushbar_message.dart';
import '../constants/message_types.dart';

class UploadClientLocationPage extends StatefulWidget {
  @override
  _UploadClientLocationPage createState() => _UploadClientLocationPage();
}

class _UploadClientLocationPage extends State<UploadClientLocationPage> {
  GlobalKey<ScaffoldState> _addLocationPageGlobalKey;
  bool isLoading, islocLoading;
  String loadingText, latitude = "", longitude = "", altitude = "";
  FocusNode floorNoFocusNode, rediusFocusNode;
  TextEditingController floorNoController,
      rediusController,
      longitudeController,
      latitudeController;
  List<Department> departments = [];
  Department selectedDepartment;

  Size size;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.loadingText = 'Loading';
    _addLocationPageGlobalKey = GlobalKey<ScaffoldState>();
    floorNoFocusNode = FocusNode();
    rediusFocusNode = FocusNode();
    floorNoController = TextEditingController();
    rediusController = TextEditingController();
    longitudeController = TextEditingController();
    latitudeController = TextEditingController();
    this.isLoading = true;
    this.islocLoading = true;

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((res) {
      latitude = res.latitude.toString();
      longitude = res.longitude.toString();
      altitude = res.altitude.toString();
      this.islocLoading = false;
    });
    ConnectivityManager().initConnectivity(this.context, this);
    getData();
  }

  getData() {
    fetchDepartment().then((result) {
      setState(() {
        this.departments = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return CustomProgressHandler(
      isLoading: this.isLoading || this.islocLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _addLocationPageGlobalKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            AppTranslations.of(context).text("key_add_department_location"),
          ),
        ),
        drawer: AppDrawer(),
        body: Padding(
          padding: EdgeInsets.only(
            left: size.width * 0.02,
            right: size.width * 0.02,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: size.height * 0.01,
                ),
                CustomDropdownList(
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
                  prefixIcon: Icons.food_bank_outlined,
                  selectedText: selectedDepartment != null
                      ? selectedDepartment.DepEName
                      : AppTranslations.of(context)
                          .text("key_select_department"),
                ),
                /*   GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
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
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: Colors.grey[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                      // side: BorderSide(width: 5, color: Colors.green)
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: size.width * 0.04,
                        top: size.width * 0.04,
                        bottom: size.width * 0.04,
                        left: size.width * 0.03,
                      ),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: size.width * 0.035),
                            child: Icon(
                              Icons.food_bank_outlined,
                              color: Colors.black45,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              selectedDepartment != null
                                  ? selectedDepartment.DepEName
                                  : AppTranslations.of(context)
                                      .text("key_select_department"),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                    color: selectedDepartment != null
                                        ? Colors.grey[700]
                                        : Colors.grey[400],
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: departments == null
                                ? Colors.black45
                                : Theme.of(context).primaryColorLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),*/
                SizedBox(
                  height: size.height * 0.01,
                ),
                CustomTextField(
                  keyboardType: TextInputType.number,
                  textEditingController: floorNoController,
                  autofoucus: false,
                  isElivated: false,
                  icon: Icons.confirmation_num_outlined,
                  hint: AppTranslations.of(context).text("key_floor_no"),
                  focusNode: floorNoFocusNode,
                  onFieldSubmitted: (value) {
                    this.floorNoFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(this.rediusFocusNode);
                  },
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                CustomTextField(
                  keyboardType: TextInputType.number,
                  textEditingController: rediusController,
                  autofoucus: false,
                  isElivated: false,
                  icon: Icons.location_city_rounded,
                  hint: AppTranslations.of(context).text("key_radius"),
                  focusNode: rediusFocusNode,
                  onFieldSubmitted: (value) {
                    this.rediusFocusNode.unfocus();
                  },
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                CustomTextField(
                  enable: false,
                  keyboardType: TextInputType.number,
                  textEditingController: latitudeController,
                  autofoucus: false,
                  isElivated: false,
                  icon: Icons.gps_fixed,
                  hint: AppTranslations.of(context).text("key_latitude") +
                      " :  " +
                      latitude,
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                CustomTextField(
                  keyboardType: TextInputType.number,
                  textEditingController: longitudeController,
                  autofoucus: false,
                  enable: false,
                  isElivated: false,
                  icon: Icons.gps_fixed,
                  hint: AppTranslations.of(context).text("key_longitude") +
                      " :  " +
                      longitude,
                ),
                SizedBox(
                  height: size.height * 0.01,
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
                      postDepartmentLocation();
                    }
                  },
                  child: Container(
                    color: Theme.of(context).accentColor,
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          AppTranslations.of(context)
                              .text("key_upload_location"),
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
                /*      CustomGradientButton(
                    caption:
                        AppTranslations.of(context).text("key_upload_location"),
                    onPressed: () {
                      String valMsg = getValidationMessage();
                      if (valMsg != '') {
                        FlushbarMessage.show(
                          context,
                          valMsg,
                          MessageTypes.WARNING,
                        );
                      } else {
                        postDepartmentLocation();
                      }
                    }),*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getValidationMessage() {
    if (selectedDepartment == null)
      return AppTranslations.of(context).text("key_dept_instruction");

    if (floorNoController.text == '' || floorNoController.text == null) {
      return AppTranslations.of(context).text("key_floor_instruction");
    } else {
      try {
        int.parse(floorNoController.text);
      } catch (e) {
        return AppTranslations.of(context).text("key_number_floor_instruction");
      }
    }

    if (rediusController.text == '' || rediusController.text == null) {
      return AppTranslations.of(context).text("key_radius_instruction");
    } else {
      try {
        int.parse(rediusController.text);
      } catch (e) {
        return AppTranslations.of(context)
            .text("key_number_radius_instruction");
      }
    }

    if (longitude == '' || longitude == null)
      return AppTranslations.of(context).text("key_location_instruction");

    if (latitude == '' || latitude == null)
      return AppTranslations.of(context).text("key_location_instruction");

    return '';
  }

  Future<void> postDepartmentLocation() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Saving . . .';
      });
      UploadLocation location = UploadLocation(
          LocationId: 0,
          DepId: selectedDepartment.DepId,
          FloorNo: int.parse(floorNoController.text.toString()),
          Latitude: latitude,
          Longitude: longitude,
          Altitude: altitude,
          latlongstatus: "A",
          Radius: int.parse(rediusController.text.toString()));

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {};

          Uri saveDeptLocationUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                DeptLocationUrls.POST_DEPT_LOCATION,
            params,
          );

          String jsonBody = json.encode(location);

          http.Response response = await http.post(
            saveDeptLocationUri,
            headers: NetworkHandler.postHeader(),
            body: jsonBody,
            encoding: Encoding.getByName("utf-8"),
          );

          var data = json.decode(response.body);
          if (response.statusCode == HttpStatusCodes.OK) {
            if (data["Status"] == HttpStatusCodes.CREATED) {
              FlushbarMessage.show(
                context,
                data["Message"],
                MessageTypes.SUCCESS,
              );
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
      print(e);
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

  void _clearData() {
    floorNoController.text = '';
    rediusController.text = '';
    selectedDepartment = null;
  }

  Future<List<Department>> fetchDepartment() async {
    List<Department> dept;
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();

      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          "DepId": "0",
        };

        Uri fetchDepartmentUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              DepartmentUrls.GET_DEPT_LIST,
          params,
        );

        print(fetchDepartmentUri);

        http.Response response = await http.get(fetchDepartmentUri,
            headers: NetworkHandler.getHeader());
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
      print(e);
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

  void showClientDepartments() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_department"),
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
