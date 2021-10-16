import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_india/components/custom_list_separator.dart';
import 'package:pulse_india/components/custom_progress_handler.dart';
import 'package:pulse_india/components/custom_search_box.dart';
import 'package:pulse_india/components/flushbar_message.dart';
import 'package:pulse_india/constants/http_status_codes.dart';
import 'package:pulse_india/constants/message_types.dart';
import 'package:pulse_india/constants/project_settings.dart';
import 'package:pulse_india/handlers/image_handler.dart';
import 'package:pulse_india/handlers/network_handler.dart';
import 'package:pulse_india/handlers/string_handlers.dart';
import 'package:pulse_india/input_components/loading_shimmer_effect_widget.dart';
import 'package:pulse_india/localization/app_translations.dart';
import 'package:pulse_india/models/file.dart';
import 'package:pulse_india/pages/sign_submit_page.dart';
import 'package:pulse_india/pages/zoom_image_page.dart';

class CompletedFilesPage extends StatefulWidget {
  const CompletedFilesPage({Key key}) : super(key: key);

  @override
  _CompletedFilesPageState createState() => _CompletedFilesPageState();
}

class _CompletedFilesPageState extends State<CompletedFilesPage> {
  bool isLoading = false, isProcessing = false;
  String loadingText;
  List<TallyFile> pendingFiles = [];
  List<TallyFile> pfilteredList = [];

  TextEditingController pfilterController;
  String pfilter;

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

    ConnectivityManager().initConnectivity(this.context, this);
    getData();
  }

  getData() {
    fetchFiles().then((value) {
      if (value != null) pendingFiles = value;
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
    Size size = MediaQuery.of(context).size;
    return CustomProgressHandler(
      isLoading: isProcessing,
      loadingText: 'Please wait',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Completed Files',
          ),
        ),
        body: Column(
          children: [
            CustomSearchBox(
              isVisible: pendingFiles != null && pendingFiles.isNotEmpty,
              hintText: 'Search File',
              filterController: pfilterController,
            ),
            Expanded(
              child: pfilteredList != null && pfilteredList.isNotEmpty
                  ? CupertinoScrollbar(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          TallyFile file = pfilteredList[index];
                          return Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
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
                                                              siv:
                                                                  file.FILENAME,
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
                                                        ),
                                                        height: 20,
                                                        width: 20,
                                                      ),
                                                    );
                                                  },
                                                  errorWidget:
                                                      (context, val, err) {
                                                    print('val:$val');
                                                    return LoadingShimmerWidget(
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                          Text(
                                            '${file.Details?.length} item(s)',
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
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Last accessed',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Colors.black45,
                                                ),
                                          ),
                                          Text(
                                            StringHandlers
                                                .getDisplayFormattedDateTime(
                                                    file.STATUSTIME),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SignNdSubmitPage(
                                            file: file,
                                            processId: file.PROCESSID,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text('Sign and Submit'),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return CustomListSeparator();
                        },
                        itemCount: pfilteredList.length,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
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
                            style: Theme.of(context).textTheme.caption.copyWith(
                                  color: Colors.black54,
                                ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<TallyFile>> fetchFiles() async {
    List<TallyFile> allFiles;
    setState(() {
      isLoading = true;
    });

    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {};

          Uri fetchFilesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                TallyFileUrls.GETSTEPCOMPLETEFILE_WITHPARTIALSTATUS,
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
}
