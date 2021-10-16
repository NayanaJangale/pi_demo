import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:pulse_india/components/custom_progress_handler.dart';
import 'package:pulse_india/components/flushbar_message.dart';
import 'package:pulse_india/constants/http_status_codes.dart';
import 'package:pulse_india/constants/message_types.dart';
import 'package:pulse_india/constants/project_settings.dart';
import 'package:pulse_india/handlers/image_handler.dart';
import 'package:pulse_india/handlers/network_handler.dart';
import 'package:pulse_india/input_components/custom_app_drawer.dart';
import 'package:pulse_india/input_components/loading_shimmer_effect_widget.dart';
import 'package:pulse_india/localization/app_translations.dart';
import 'package:pulse_india/models/file.dart';
import 'package:pulse_india/models/uploaded_process.dart';
import 'package:video_player/video_player.dart';

import '../components/flushbar_message.dart';
import '../constants/message_types.dart';
import '../models/process_master.dart';
import 'custom_take_picture.dart';
import 'home_page.dart';

class SignNdSubmitPage extends StatefulWidget {
  final TallyFile file;
  final int processId;

  SignNdSubmitPage({
    this.file,
    this.processId,
  });

  @override
  _SignNdSubmitPageState createState() => _SignNdSubmitPageState();
}

class _SignNdSubmitPageState extends State<SignNdSubmitPage> {
  bool isLoading;
  String loadingText;

  List<UploadedProcess> process;
  List cameras;
  dynamic firstCamera;

  File selfieFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
    loadingText = 'Loading';

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

    fetchProcess().then((value) {
      process = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: isLoading,
      loadingText: loadingText,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.file.FILENAME,
          ),
        ),
        drawer: AppDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /* Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                'Process Completed', //  AppTranslations.of(context).text("key_processed"),
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ),*/
            process != null && process.length != 0
                ? Expanded(
                    flex: 3,
                    child: Card(
                      elevation: 0.0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: CupertinoScrollbar(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                  // horizontalMargin: 10,
                                  showBottomBorder: true,
                                  columnSpacing: 10,
                                  columns: [
                                    /*  DataColumn(
                                      label: Text(
                                        AppTranslations.of(context)
                                            .text("key_sr_no"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              color: Colors.black,
                                            ),
                                      ),
                                    ),*/
                                    DataColumn(
                                      label: Text(
                                        ' ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                              color: Colors.black,
                                            ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Process ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                              color: Colors.black,
                                            ),
                                      ),
                                    ),
                                  ],
                                  rows: process.map((m) {
                                    return DataRow(
                                      cells: [
                                        /*   DataCell(
                                          Text(
                                            '${process.indexOf(m) + 1}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .copyWith(
                                                  color: Colors.black54,
                                                ),
                                          ),
                                        ),*/
                                        DataCell(
                                          FutureBuilder(
                                            future: ImageHandler
                                                .getProcessLogImageUrl(
                                              m.PROCESSLOGID.toString(),
                                            ),
                                            builder: (context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              return Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.1,
                                                //  padding: EdgeInsets.all(1),
                                                child: snapshot.hasData
                                                    ? m.FILETYPE == 'Image'
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              _zoomImage(
                                                                  context,
                                                                  snapshot.data
                                                                      .toString());
                                                            },
                                                            child:
                                                                CachedNetworkImage(
                                                              httpHeaders:
                                                                  NetworkHandler
                                                                      .getHeader(),
                                                              imageUrl: snapshot
                                                                  .data
                                                                  .toString(),
                                                              imageBuilder: (context,
                                                                      imageProvider) =>
                                                                  snapshot.hasData
                                                                      ? GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            _zoomImage(context,
                                                                                snapshot.data.toString());
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                EdgeInsets.all(1),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.blueAccent, width: 0.5),
                                                                              color: Colors.white,
                                                                            ),
                                                                            child:
                                                                                Image.network(
                                                                              snapshot.data.toString(),
                                                                              fit: BoxFit.contain,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Container(),
                                                              fit: BoxFit.fill,
                                                              errorWidget:
                                                                  (context, url,
                                                                      error) {
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Text(
                                                                    'Refresh',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .caption
                                                                        .copyWith(
                                                                          color:
                                                                              Colors.blueAccent,
                                                                        ),
                                                                  ),
                                                                );
                                                                /*  return Image.asset(
                                                                'assets/images/no_image.jpg',
                                                              );*/
                                                              },
                                                              placeholder:
                                                                  (context,
                                                                      url) {
                                                                return LoadingShimmerWidget(
                                                                  enabled:
                                                                      snapshot !=
                                                                          null,
                                                                  child:
                                                                      CircleAvatar(
                                                                    radius: 80,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        : VideoPlayer(
                                                            VideoPlayerController
                                                                .network(
                                                              snapshot.data,
                                                            ),
                                                          )
                                                    : Text(
                                                        'Loading...',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption
                                                            .copyWith(
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                      ),
                                              );
                                            },
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            m.STEPSUBENAME,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                  color: Colors.black54,
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList()),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        'Process not available',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.all(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      //   color: Theme.of(context).primaryColorLight,
                      border: Border.all(
                        color: Colors.black12,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: selfieFile == null
                              ? Center(
                                  child: Text(
                                    'Selfie',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          color: Colors.black54,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Image.file(
                                  selfieFile,
                                  //   fit: BoxFit.fill,
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
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
                                      selfieFile = File(res);
                                    });
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  color: Colors.white70,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 20,
                                      ),
                                      Text(
                                        'Take Selfie',
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(
                                              color: Colors.black,
                                            ),
                                      )
                                    ],
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
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (selfieFile == null) {
                  FlushbarMessage.show(
                    context,
                    'Please take selfie',
                    MessageTypes.ERROR,
                  );
                } else {
                  await postSelfieFile(widget.processId);
                }
              },
              child: Container(
                color: Theme.of(context).accentColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      AppTranslations.of(context).text("key_sign_submit"),
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
          ],
        ),
      ),
    );
  }

  Future<void> _zoomImage(BuildContext context, String file) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        print('file:$file');
        return AlertDialog(
          contentPadding: EdgeInsets.all(0.0),
          content: Image.network(
            file,
            fit: BoxFit.contain,
            /*  height: MediaQuery.of(context).size.height * 3 / 4,
            width: MediaQuery.of(context).size.height * 3 / 4,*/
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.green,
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<UploadedProcess>> fetchProcess() async {
    List<UploadedProcess> allProcess;
    setState(() {
      isLoading = true;
    });

    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "ProcessId": widget.processId.toString(), //"6",
          };

          Uri fetchProcessUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                UploadedProcessUrls.GetprocessDetails,
            params,
          );

          print(fetchProcessUri);

          http.Response response = await http.get(
            fetchProcessUri,
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
                allProcess = responseData
                    .map((item) => UploadedProcess.fromMap(item))
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

    return allProcess;
  }

  Future<void> postSelfieFile(int processId) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Saving';
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> param = {
            'ProcessId': widget.processId.toString(),
          };

          Uri postUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ProcessUrls.PostProcessMasterImage,
            param,
          );

          final mimeTypeData = lookupMimeType(selfieFile.path).split('/');
          //  final mimeTypeData = lookupMimeType(capturedImage.path, headerBytes: [0xFF, 0xD8]).split('/');
          final imageUploadRequest =
              http.MultipartRequest(HttpRequestMethods.POST, postUri);
          final file = await http.MultipartFile.fromPath(
            'image',
            selfieFile.path,
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
          print(response.statusCode);
          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);

            if (data["Status"] == HttpStatusCodes.CREATED) {
              setState(() {
                isLoading = false;
              });
              FlushbarMessage.show(
                context,
                'Signed and Submitted successfully...!',
                MessageTypes.SUCCESS,
              );

              await Future.delayed(Duration(seconds: 4));

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(),
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
  }
}
