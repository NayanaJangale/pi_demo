import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_india/app_data.dart';
import 'package:pulse_india/components/custom_list_separator.dart';
import 'package:pulse_india/components/custom_progress_handler.dart';
import 'package:pulse_india/components/custom_search_box.dart';
import 'package:pulse_india/constants/file_status.dart';
import 'package:pulse_india/handlers/image_handler.dart';
import 'package:pulse_india/input_components/custom_app_drawer.dart';
import 'package:pulse_india/input_components/loading_shimmer_effect_widget.dart';
import 'package:pulse_india/models/file.dart';
import 'package:pulse_india/models/process_master.dart';
import 'package:pulse_india/pages/file_process_page.dart';
import 'package:pulse_india/pages/zoom_image_page.dart';

import '../app_data.dart';
import '../components/flushbar_message.dart';
import '../constants/http_status_codes.dart';
import '../constants/message_types.dart';
import '../constants/project_settings.dart';
import '../handlers/network_handler.dart';
import '../localization/app_translations.dart';

class ServicePendingFilesPage extends StatefulWidget {
  @override
  _ServicePendingFilesPageState createState() =>
      _ServicePendingFilesPageState();
}

class _ServicePendingFilesPageState extends State<ServicePendingFilesPage> {
  bool isLoading = false, isProcessing = false;
  String loadingText;
  List<TallyFile> pendingFiles = [];
  List<TallyFile> inProcesssFiles = [];
  List<TallyFile> pfilteredList = [];
  List<TallyFile> ipfilteredList = [];

  TextEditingController pfilterController, ipfilterController;
  String pfilter, ipfilter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    loadingText = 'Please wait';

    pfilterController = new TextEditingController();
    pfilterController.addListener(() {
      setState(() {
        pfilter = pfilterController.text;
      });
    });
    ipfilterController = new TextEditingController();
    ipfilterController.addListener(() {
      setState(() {
        ipfilter = ipfilterController.text;
      });
    });
    //ConnectivityManager().initConnectivity(this.context, this);
    getData();
  }

  getData() {
    fetchFiles(FileStatus.pending).then((value) {
      if (value != null) {
        setState(() {
          pendingFiles = value;
        });
      }
      fetchFiles(FileStatus.in_process).then((value) {
        if (value != null) {
          setState(() {
            inProcesssFiles = value;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    pfilteredList = pendingFiles.where((item) {
      if (pfilter == null || pfilter == '')
        return true;
      else {
        return item.FILENAME.toLowerCase().contains(pfilter.toLowerCase()) ||
            item.CONTAINER_NO.toLowerCase().contains(pfilter.toLowerCase());
      }
    }).toList();
    ipfilteredList = inProcesssFiles.where((item) {
      if (ipfilter == null || ipfilter == '')
        return true;
      else {
        return item.FILENAME.toLowerCase().contains(ipfilter.toLowerCase()) ||
            item.CONTAINER_NO.toLowerCase().contains(ipfilter.toLowerCase());
      }
    }).toList();
    Size size = MediaQuery.of(context).size;
    return CustomProgressHandler(
      isLoading: isProcessing,
      loadingText: 'Please wait',
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              appData.service.SERVICEENAME,
            ),
            bottom: TabBar(
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 2,
              unselectedLabelStyle: Theme.of(context).textTheme.bodyText2,
              labelStyle: Theme.of(context).textTheme.bodyText1,
              tabs: [
                Tab(
                  text: 'In Progress',
                ),
                Tab(
                  text: 'Pending',
                ),
              ],
            ),
          ),
          drawer: AppDrawer(),
          body: TabBarView(
            children: [
              Column(
                children: [
                  CustomSearchBox(
                    isVisible:
                        inProcesssFiles != null && inProcesssFiles.isNotEmpty,
                    hintText: 'Search File',
                    filterController: ipfilterController,
                  ),
                  Expanded(
                    child: ipfilteredList != null && ipfilteredList.isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: CupertinoScrollbar(
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  TallyFile file = ipfilteredList[index];
                                  return ListTile(
                                    onTap: () async {
                                      //Call create Process api
                                      await postCreateProcess(file);
                                    },
                                    title: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            file.FILENAME,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                  color: Colors.black87,
                                                ),
                                          ),
                                          Text(
                                            file.CONTAINER_NO ?? file.WEIGHT,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Colors.black45,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    subtitle: LayoutBuilder(
                                      builder: (BuildContext context,
                                          BoxConstraints constraints) {
                                        double mWidth = constraints.maxWidth *
                                            (file.PROCESSPERCENTAGE / 100);

                                        return Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .shade200, //Colors.green.withOpacity(0.2),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              height: 10,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.all(
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
                                    /*Text(
                                      file.SERVICENAME,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .copyWith(
                                            color: Colors.black54,
                                          ),
                                    )*/
                                    trailing: Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: Colors.grey[300],
                                      size: 20,
                                    ),
                                    leading: Container(
                                      height: 50,
                                      width: 50,
                                      child: FutureBuilder(
                                        future: ImageHandler.getVoucherImageUrl(
                                          file.FILEID.toString(),
                                        ),
                                        builder: (context,
                                            AsyncSnapshot<String> snapshot) {
                                          return !snapshot.hasError
                                              ? snapshot.hasData
                                                  ? CachedNetworkImage(
                                                      imageUrl: snapshot.data,
                                                      imageBuilder:
                                                          (context, img) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    ZoomImagePage(
                                                                  siv: file
                                                                      .FILENAME,
                                                                  url: snapshot
                                                                      .data,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image: img,
                                                              ),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .blueAccent),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            height: 20,
                                                            width: 20,
                                                          ),
                                                        );
                                                      },
                                                      errorWidget:
                                                          (context, val, err) {
                                                        print('val:$val');
                                                        return Container(
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .redAccent,
                                                                width: 0.5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Text(
                                                            'Voucher not found',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .overline
                                                                .copyWith(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  letterSpacing:
                                                                      0,
                                                                ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        );
                                                      },
                                                      placeholder:
                                                          (context, val) {
                                                        print('val:$val');
                                                        return CupertinoActivityIndicator(
                                                          radius: 10,
                                                          animating: true,
                                                        );
                                                      },
                                                    )
                                                  : LoadingShimmerWidget(
                                                      enabled: true,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            10,
                                                          ),
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                              : CupertinoActivityIndicator(
                                                  radius: 10,
                                                  animating: true,
                                                );
                                        },
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return CustomListSeparator();
                                },
                                itemCount: ipfilteredList.length,
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
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  width: double.infinity,
                                                  height: 8.0,
                                                  color: Colors.white,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2.0),
                                                ),
                                                Container(
                                                  width: size.width * 0.5,
                                                  height: 8.0,
                                                  color: Colors.white,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2.0),
                                                ),
                                                Container(
                                                  width: size.width * 0.2,
                                                  height: 8.0,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
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
                  ),
                ],
              ),
              Column(
                children: [
                  CustomSearchBox(
                    isVisible: pendingFiles != null && pendingFiles.isNotEmpty,
                    hintText: 'Search File',
                    filterController: pfilterController,
                  ),
                  Expanded(
                    child: pfilteredList != null && pfilteredList.isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            margin: EdgeInsets.all(5),
                            child: CupertinoScrollbar(
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  TallyFile file = pfilteredList[index];
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
                                      file.CONTAINER_NO ?? file.WEIGHT,
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
                                      size: 15,
                                    ),
                                    leading: Container(
                                      height: 50,
                                      width: 50,
                                      child: FutureBuilder(
                                        future: ImageHandler.getVoucherImageUrl(
                                          file.FILEID.toString(),
                                        ),
                                        builder: (context,
                                            AsyncSnapshot<String> snapshot) {
                                          return !snapshot.hasError
                                              ? snapshot.hasData
                                                  ? CachedNetworkImage(
                                                      imageUrl: snapshot.data,
                                                      imageBuilder:
                                                          (context, img) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    ZoomImagePage(
                                                                  siv: file
                                                                      .FILENAME,
                                                                  url: snapshot
                                                                      .data,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image: img,
                                                              ),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .blueAccent),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            height: 20,
                                                            width: 20,
                                                          ),
                                                        );
                                                      },
                                                      errorWidget:
                                                          (context, val, err) {
                                                        print('val:$val');
                                                        return Container(
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .redAccent,
                                                                width: 0.5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Text(
                                                            'Voucher not found',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .overline
                                                                .copyWith(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  letterSpacing:
                                                                      0,
                                                                ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        );
                                                      },
                                                      placeholder:
                                                          (context, val) {
                                                        print('val:$val');
                                                        return CupertinoActivityIndicator(
                                                          radius: 10,
                                                          animating: true,
                                                        );
                                                      },
                                                    )
                                                  : LoadingShimmerWidget(
                                                      enabled: true,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            10,
                                                          ),
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                              : CupertinoActivityIndicator(
                                                  radius: 10,
                                                  animating: true,
                                                );
                                        },
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return CustomListSeparator();
                                },
                                itemCount: pfilteredList.length,
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
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  width: double.infinity,
                                                  height: 8.0,
                                                  color: Colors.white,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2.0),
                                                ),
                                                Container(
                                                  width: size.width * 0.5,
                                                  height: 8.0,
                                                  color: Colors.white,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2.0),
                                                ),
                                                Container(
                                                  width: size.width * 0.2,
                                                  height: 8.0,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<TallyFile>> fetchFiles(String status) async {
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
            "ServiceId": appData.service.SERVICEID.toString(),
            "FileStatus": status,
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
              setState(() {
                isLoading = false;
              });
              /* FlushbarMessage.show(
                this.context,
                data["Message"],
                MessageTypes.ERROR,
              );*/
            } else {
              var parsedJson = data["Data"];
                List responseData = parsedJson;
                allFiles = responseData
                    .map((item) => TallyFile.fromMap(item))
                    .toList();
              setState(() {
                isLoading = false;
              });
            }
          } else {
            setState(() {
              isLoading = false;
            });
            FlushbarMessage.show(
              this.context,
              'Invalid response received (${response.statusCode})',
              MessageTypes.ERROR,
            );
          }
        } else {
          setState(() {
            isLoading = false;
          });
          FlushbarMessage.show(
            this.context,
            AppTranslations.of(context).text("key_no_server"),
            MessageTypes.WARNING,
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        FlushbarMessage.show(
          this.context,
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
      }
    }  catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      FlushbarMessage.show(
        this.context,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }
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

          print(createProcessUri);
          print(jsonBody);

          http.Response response = await http.post(
            createProcessUri,
            headers: NetworkHandler.postHeader(),
            body: jsonBody,
            encoding: Encoding.getByName("utf-8"),
          );

          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);

            if (data["Status"] == HttpStatusCodes.CREATED) {
              setState(() {
                isProcessing = false;
              });
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
      isProcessing = false;
      loadingText = 'Loading..';
    });
  }
}
