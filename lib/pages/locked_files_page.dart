import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_india/components/custom_list_separator.dart';
import 'package:pulse_india/handlers/image_handler.dart';
import 'package:pulse_india/handlers/string_handlers.dart';
import 'package:pulse_india/models/locked_file.dart';
import 'package:pulse_india/models/process_master.dart';
import 'package:pulse_india/pages/zoom_image_page.dart';

import '../components/custom_progress_handler.dart';
import '../components/custom_search_box.dart';
import '../components/flushbar_message.dart';
import '../constants/http_status_codes.dart';
import '../constants/message_types.dart';
import '../constants/project_settings.dart';
import '../handlers/network_handler.dart';
import '../input_components/loading_shimmer_effect_widget.dart';
import '../localization/app_translations.dart';

class LockedFilesPage extends StatefulWidget {
  @override
  _LockedFilesPageState createState() => _LockedFilesPageState();
}

class _LockedFilesPageState extends State<LockedFilesPage> {
  bool isLoading = false, isProcessing = false;
  String loadingText;
  List<LockedFile> lockedFiles = [];
  List<LockedFile> filteredLockedFiles = [];

  TextEditingController filterController;
  String filter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    loadingText = 'Please wait';

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
    fetchFiles().then((value) {
      if (value != null) {
        lockedFiles = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (lockedFiles != null && lockedFiles.isNotEmpty) {
      filteredLockedFiles = lockedFiles.where((item) {
        if (filter == null || filter == '')
          return true;
        else {
          return item.FILE_NAME.toLowerCase().contains(filter.toLowerCase()) ||
              item.CONTAINER_NO.toLowerCase().contains(filter.toLowerCase()) ||
              item.SERVICEENAME.toLowerCase().contains(filter.toLowerCase());
        }
      }).toList();
    }
    return CustomProgressHandler(
      isLoading: isProcessing,
      loadingText: 'Please wait',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Locked Files',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CustomSearchBox(
                isVisible: lockedFiles != null && lockedFiles.isNotEmpty,
                hintText: 'Search File',
                filterController: filterController,
              ),
              Expanded(
                child: filteredLockedFiles != null &&
                        filteredLockedFiles.isNotEmpty
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
                              LockedFile file = filteredLockedFiles[index];
                              return ListTile(
                                contentPadding: EdgeInsets.all(8),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.FILE_NAME,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      file.CONTAINER_NO,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Colors.black54,
                                          ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.SERVICEENAME,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                            color: Colors.black54,
                                          ),
                                    ),
                                    Text(
                                      file.PROCESSSTART != null
                                          ? StringHandlers
                                              .getDisplayFormattedDateTime(
                                              file.PROCESSSTART,
                                            )
                                          : '---',
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .copyWith(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.normal,
                                          ),
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  child: Text(
                                    'Release',
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  onPressed: () async {
                                    await updatePauseProcess(
                                      file.PROCESSID.toString(),
                                    );

                                    fetchFiles().then((value) {
                                      setState(() {
                                        filteredLockedFiles = [];
                                        lockedFiles = value;
                                      });
                                    });
                                  },
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
                                                  imageBuilder: (context, img) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                ZoomImagePage(
                                                              siv: file
                                                                  .FILE_NAME,
                                                              url:
                                                                  snapshot.data,
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
                                                                  .circular(5),
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
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .redAccent,
                                                            width: 0.5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Text(
                                                        'Voucher not found',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .overline
                                                            .copyWith(
                                                              color: Colors
                                                                  .redAccent,
                                                              letterSpacing: 0,
                                                            ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    );
                                                  },
                                                  placeholder: (context, val) {
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
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                            itemCount: filteredLockedFiles.length,
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
                              style:
                                  Theme.of(context).textTheme.caption.copyWith(
                                        color: Colors.black54,
                                      ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<LockedFile>> fetchFiles() async {
    List<LockedFile> allFiles;
    setState(() {
      isLoading = true;
    });

    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "EMPNO": '0', //appData.user.UserNo.toString(),
            "FILESTATUS": 'Inprocess',
          };

          Uri fetchFilesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                LockedFileUrls.GETPROCESSBYSTATUS,
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
              /* FlushbarMessage.show(
                this.context,
                data["Message"],
                MessageTypes.ERROR,
              );*/
            } else {
              var parsedJson = data["Data"];
              setState(() {
                List responseData = parsedJson;
                allFiles = responseData
                    .map((item) => LockedFile.fromMap(item))
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
      isLoading = false;
    });

    return allFiles;
  }

  Future<void> updatePauseProcess(String processId) async {
    try {
      setState(() {
        isProcessing = true;
        loadingText = 'Processing';
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "ProcessId": processId,
          };

          Uri createProcessUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ProcessUrls.PutProcessMaster,
            params,
          );

          print(createProcessUri);

          http.Response response = await http.put(
            createProcessUri,
            encoding: Encoding.getByName("utf-8"),
            headers: NetworkHandler.postHeader(),
          );

          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);

            if (data["Status"] == HttpStatusCodes.OK) {
              /*  FlushbarMessage.show(
                context,
                data["Message"],
                MessageTypes.SUCCESS,
              );*/

              setState(() {
                isProcessing = false;
              });
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
