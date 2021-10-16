import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_editor/image_editor.dart' as i;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pulse_india/components/custom_progress_handler.dart';
import 'package:pulse_india/constants/http_status_codes.dart';
import 'package:pulse_india/constants/project_settings.dart';
import 'package:pulse_india/design_components/video_preview.dart';
import 'package:pulse_india/handlers/network_handler.dart';
import 'package:pulse_india/handlers/pop_up_handler.dart';
import 'package:pulse_india/models/file.dart';
import 'package:pulse_india/models/process_detail.dart';
import 'package:pulse_india/models/process_master.dart';
import 'package:pulse_india/models/step_detail.dart';
import 'package:pulse_india/pages/home_page.dart';
import 'package:pulse_india/pages/sign_submit_page.dart';
import 'package:pulse_india/utils/blinking_widget.dart';
import 'package:video_player/video_player.dart';

import '../components/flushbar_message.dart';
import '../constants/message_types.dart';
import '../handlers/pop_up_handler.dart';
import '../localization/app_translations.dart';
import '../select_service_page.dart';

class FileProcessPage extends StatefulWidget {
  final TallyFile file;
  final int processId;

  FileProcessPage({this.file, this.processId});

  @override
  _FileProcessPageState createState() => _FileProcessPageState();
}

class _FileProcessPageState extends State<FileProcessPage> {
  File capturedImage;
  bool isLoading;
  String loadingText;

  ImagePicker picker;
  String _retrieveDataError;

  VideoPlayerController _controller;
  VideoPlayerController _toBeDisposed;

  List<StepDetail> steps = [];
  int stepIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    picker = ImagePicker();
    isLoading = false;
    loadingText = 'Loading';

    fetchSteps().then((value) {
      steps = value;
    });
  }

  Future<void> _setUpVideo(PickedFile file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      VideoPlayerController controller;
      controller = VideoPlayerController.file(File(file.path));
      _controller = controller;

      final double volume = 1.0;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {});
    }
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();

    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Widget _previewVideo() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return Center(
        child: Text(
          steps[stepIndex]
              .StepSubEName, //AppTranslations.of(context).text("key_not_recorded_video_yet"),
          style: Theme.of(context).textTheme.bodyText2.copyWith(
                color: Colors.black54,
              ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(
        _retrieveDataError,
        style: Theme.of(context).textTheme.bodyText2.copyWith(
              color: Colors.redAccent,
            ),
      );
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return PopupHandler.showQuestionPopup(
          context: this.context,
          title: 'Warning',
          description: 'Do you want to Pause Process..?',
          okText: 'Yes',
          cancelText: 'No',
          onOkClick: () {
            //Call put Process api
            updatePauseProcess().then((value) => null);
          },
          onCancelClick: () {
            //hide pop up
          },
        );
      },
      child: CustomProgressHandler(
        isLoading: isLoading,
        loadingText: loadingText,
        child: PlatformScaffold(
          backgroundColor: Colors.white,
          appBar: PlatformAppBar(
            title: Text(
              widget.file.FILENAME,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[400],
                      blurRadius: 1.0,
                      spreadRadius: 0.0,
                      offset:
                          Offset(0.0, 2.0), // shadow direction: bottom right
                    )
                  ],
                ),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.file.CONTAINER_NO ?? widget.file.FILENAME,
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Colors.black54,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Weight : ${widget.file.WEIGHT}',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Colors.black54,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.file.Filedate,
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Colors.black54,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Items : ${widget.file.Details.length}',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Colors.black54,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              /* Text(
                'Process Steps ->',
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Colors.black87,
                    ),
              ),
              Divider(
                height: 1,
                color: Colors.black54,
              ),*/
              Expanded(
                child: steps != null && steps.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: steps.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: index == stepIndex
                                  ? ExpansionTile(
                                      //backgroundColor:     Theme.of(context).secondaryHeaderColor,
                                      initiallyExpanded: true,
                                      trailing: BlinkWidget(
                                        children: <Widget>[
                                          Icon(
                                            Icons.add_photo_alternate_rounded,
                                            color: Colors.green
                                                .shade200, //Colors.grey.shade300,
                                            size: 20,
                                          ),
                                          Icon(
                                            Icons.add_photo_alternate_rounded,
                                            color: Colors.green.shade800,
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                      title: Text(
                                        '${steps[index].StepSubEName} - ${steps[index].IsProductStep ? steps[index].ITEM_NAME : ''}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                              color: Colors.black87,
                                            ),
                                      ),
                                      expandedCrossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(8),
                                          child: AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.black12,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    child: Platform.isAndroid
                                                        ? FutureBuilder<void>(
                                                            future:
                                                                retrieveLostData(),
                                                            builder: (BuildContext
                                                                    context,
                                                                AsyncSnapshot<
                                                                        void>
                                                                    snapshot) {
                                                              switch (snapshot
                                                                  .connectionState) {
                                                                case ConnectionState
                                                                    .none:
                                                                case ConnectionState
                                                                    .waiting:
                                                                  return const Text(
                                                                    'You have not yet picked an image/video.',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  );
                                                                case ConnectionState
                                                                    .done:
                                                                  return (steps[index]
                                                                              .FileType ==
                                                                          'Video'
                                                                      ? _previewVideo()
                                                                      : steps[index].file ==
                                                                              null
                                                                          ? Center(
                                                                              child: Text(
                                                                                steps[index].StepSubEName,
                                                                                style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                                                      color: Colors.black54,
                                                                                    ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            )
                                                                          : Image
                                                                              .file(
                                                                              steps[index].file,
//                                                            fit: BoxFit.fill,
                                                                            ));
                                                                default:
                                                                  if (snapshot
                                                                      .hasError) {
                                                                    return Text(
                                                                      'Pick image/video error: ${snapshot.error}}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    );
                                                                  } else {
                                                                    return const Text(
                                                                      'You have not yet picked an image/video.',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    );
                                                                  }
                                                              }
                                                            },
                                                          )
                                                        : (steps[index]
                                                                    .FileType ==
                                                                'Video'
                                                            ? _previewVideo()
                                                            : steps[index]
                                                                        .file ==
                                                                    null
                                                                ? Center(
                                                                    child: Text(
                                                                      steps[index]
                                                                          .StepSubEName,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyText1
                                                                          .copyWith(
                                                                            color:
                                                                                Colors.black54,
                                                                          ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  )
                                                                : Image.file(
                                                                    steps[index]
                                                                        .file,
//                                                            fit: BoxFit.fill,
                                                                  )),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            steps[index].FileType ==
                                                                    'Video'
                                                                ? _recordVideo(
                                                                    ImageSource
                                                                        .camera,
                                                                  )
                                                                : _clickImage(
                                                                    ImageSource
                                                                        .camera,
                                                                  );
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            color: Colors
                                                                .lightGreen,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  steps[index].FileType ==
                                                                          'Video'
                                                                      ? Icons
                                                                          .video_call_outlined
                                                                      : Icons
                                                                          .add_a_photo_outlined,
                                                                  size: 20,
                                                                ),
                                                                Text(
                                                                  steps[index].FileType ==
                                                                          'Video'
                                                                      ? AppTranslations.of(
                                                                              context)
                                                                          .text(
                                                                              "key_record_video")
                                                                      : AppTranslations.of(
                                                                              context)
                                                                          .text(
                                                                              "key_click_photo"),
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .caption
                                                                      .copyWith(
                                                                        color: Colors
                                                                            .black,
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
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 8.0, left: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Visibility(
                                                visible:
                                                    !steps[index].IsCompulsory,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      stepIndex = stepIndex + 1;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Skip',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .copyWith(
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    if (steps[index].file ==
                                                        null) {
                                                      FlushbarMessage.show(
                                                        context,
                                                        'Please add file...!',
                                                        MessageTypes.ERROR,
                                                      );
                                                    } else {
                                                      await postProcessLog();
                                                    }
                                                  },
                                                  child: Text(
                                                    'Save',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .copyWith(
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  : IgnorePointer(
                                      ignoring: steps[index].file == null,
                                      child: ExpansionTile(
                                        backgroundColor: Theme.of(context)
                                            .secondaryHeaderColor,
                                        trailing: steps[index].file != null
                                            ? Container(
                                                //margin: EdgeInsets.all(8),
                                                child: AspectRatio(
                                                  aspectRatio: 16 / 9,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      /*   border: Border.all(
                                                        color: Colors.black12,
                                                      ),*/
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Expanded(
                                                          child: steps[index]
                                                                      .file !=
                                                                  null
                                                              ? steps[index]
                                                                          .FileType ==
                                                                      'Video'
                                                                  ? _previewVideo()
                                                                  : steps[index]
                                                                              .file ==
                                                                          null
                                                                      ? Center(
                                                                          child:
                                                                              Text(
                                                                            steps[index].StepSubEName,
                                                                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                                                  color: Colors.black54,
                                                                                ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        )
                                                                      : Image
                                                                          .file(
                                                                          steps[index]
                                                                              .file,
                                                                        )
                                                              : Center(
                                                                  child: Text(
                                                                    'Waiting...',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .subtitle1
                                                                        .copyWith(
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                  ),
                                                                ),
                                                        ),
                                                        Visibility(
                                                          visible: steps[index]
                                                                  .file ==
                                                              null,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    steps[index].FileType ==
                                                                            'Video'
                                                                        ? _recordVideo(
                                                                            ImageSource.camera,
                                                                          )
                                                                        : _clickImage(
                                                                            ImageSource.camera,
                                                                          );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(8),
                                                                    color: Colors
                                                                        .white70,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                          steps[index].FileType == 'Video'
                                                                              ? Icons.video_call_outlined
                                                                              : Icons.add_a_photo_outlined,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                        Text(
                                                                          steps[index].FileType == 'Video'
                                                                              ? AppTranslations.of(context).text("key_record_video")
                                                                              : AppTranslations.of(context).text("key_click_photo"),
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
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            /* Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              )*/
                                            : Icon(
                                                Icons.lock,
                                                color: Colors.red.shade300,
                                                size: 20,
                                              ),
                                        title: Text(
                                          '${steps[index].StepSubEName} - ${steps[index].IsProductStep ? steps[index].ITEM_NAME : ''}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .copyWith(
                                                color: steps[index].file != null
                                                    ? Colors.green
                                                    : Colors.black45,
                                              ),
                                        ),
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(8),
                                            child: AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.black12,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Expanded(
                                                      child: steps[index]
                                                                  .file !=
                                                              null
                                                          ? steps[index]
                                                                      .FileType ==
                                                                  'Video'
                                                              ? _previewVideo()
                                                              : steps[index]
                                                                          .file ==
                                                                      null
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                        steps[index]
                                                                            .StepSubEName,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyText1
                                                                            .copyWith(
                                                                              color: Colors.black54,
                                                                            ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    )
                                                                  : Image.file(
                                                                      steps[index]
                                                                          .file,
                                                                      /*  fit: BoxFit
                                                                          .fill,*/
                                                                    )
                                                          : Center(
                                                              child: Text(
                                                                'Waiting...',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .subtitle1
                                                                    .copyWith(
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                              ),
                                                            ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          steps[index].file ==
                                                              null,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                steps[index].FileType ==
                                                                        'Video'
                                                                    ? _recordVideo(
                                                                        ImageSource
                                                                            .camera,
                                                                      )
                                                                    : _clickImage(
                                                                        ImageSource
                                                                            .camera,
                                                                      );
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                color: Colors
                                                                    .white70,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      steps[index].FileType ==
                                                                              'Video'
                                                                          ? Icons
                                                                              .video_call_outlined
                                                                          : Icons
                                                                              .add_a_photo_outlined,
                                                                      size: 20,
                                                                    ),
                                                                    Text(
                                                                      steps[index].FileType ==
                                                                              'Video'
                                                                          ? AppTranslations.of(context).text(
                                                                              "key_record_video")
                                                                          : AppTranslations.of(context)
                                                                              .text("key_click_photo"),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .caption
                                                                          .copyWith(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
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
                            );
                          },
                          /*  separatorBuilder: (context, index) {
                            return CustomListSeparator();
                          },*/
                        ),
                      )
                    : isLoading
                        ? Text('Loading')
                        : Text('Not Available'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _clickImage(ImageSource iSource) async {
    try {
      var imageFile = await picker.getImage(
        source: iSource,
        imageQuality: 20,
      );
      if (imageFile != null) {
        await _handleImage(imageFile);
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_try_again"),
          MessageTypes.ERROR,
        );
      }
    } catch (ce) {
      retrieveLostData();
    }
  }

  _recordVideo(ImageSource iSource) async {
    try {
      if (_controller != null) {
        await _controller.setVolume(0.0);
      }
      var videoFile = await picker.getVideo(
        source: iSource,
        // maxDuration: Duration(seconds: 10),
      );

      if (videoFile != null) {
        await _handleVideo(videoFile);
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_try_again"),
          MessageTypes.ERROR,
        );
      }
    } catch (ce) {
      retrieveLostData();
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.type == RetrieveType.video) {
          _handleVideo(response.file);
        } else {
          _handleImage(response.file);
        }
      });
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  _handleImage(PickedFile pickedFile) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Please wait';
      });
      var imageFile = pickedFile;

      String dir = (await getTemporaryDirectory()).path;

      DateTime now = DateTime.now();
      String timeStamp = DateFormat("dd/MM/yyyy HH:mm").format(now);
      String iName = DateFormat("dd-MM-yyyy hh:mm:ss").format(now);

      var imgName = iName;
      String newPath = path.join(dir, '$imgName.png');
      print('NewPath: $newPath');
      File f = await File(imageFile.path).copy(newPath);
      List<int> bytes = await f.readAsBytes();

      const int size = 80;
      final i.ImageEditorOption option = i.ImageEditorOption();
      final i.AddTextOption textOption = i.AddTextOption();
      textOption.addText(
        i.EditorText(
          offset: Offset(1, 1),
          text: timeStamp,
          fontSizePx: size,
          textColor: Colors.red,
        ),
      );

      option.outputFormat = const i.OutputFormat.png();

      option.addOption(textOption);

      final Uint8List result = await i.ImageEditor.editImage(
        image: bytes,
        imageEditorOption: option,
      );
      print(option.toString());
      f.writeAsBytes(result);
      setState(() {
        capturedImage = f;
        steps[stepIndex].file = f;
        isLoading = false;
      });
    } catch (ce) {
      FlushbarMessage.show(
        context,
        ce.toString(),
        MessageTypes.WARNING,
      );
    }
  }

  _handleVideo(PickedFile pickedFile) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Please wait';
      });
      var videoFile = pickedFile;
      await _setUpVideo(videoFile);

      String dir = (await getTemporaryDirectory()).path;

      DateTime now = DateTime.now();
      String timeStamp = DateFormat("dd/MM/yyyy HH:mm").format(now);
      String iName = DateFormat("dd-MM-yyyy hh:mm:ss").format(now);

      var imgName = iName;
      String newPath = path.join(dir, '$imgName.mp4');
      print('NewPath: $newPath');

      File vidF = await File(videoFile.path).copy(newPath);

      setState(() {
        capturedImage = vidF;
        steps[stepIndex].file = vidF;
        isLoading = false;
      });
    } catch (ce) {
      FlushbarMessage.show(
        context,
        ce.toString(),
        MessageTypes.WARNING,
      );
    }
  }

  Future<List<StepDetail>> fetchSteps() async {
    List<StepDetail> stepDetail;
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Loading';
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "FileId": widget.file.FILEID.toString(),
          };

          Uri fetchDepartmentUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                StepDetailUrls.GetServiceStepDetailByServiceId,
            params,
          );
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
                stepDetail = responseData
                    .map((item) => StepDetail.fromMap(item))
                    .toList();
              });
            } else {
              PopupHandler.showWarningPopup(
                  context: this.context,
                  title: 'Warning',
                  description: 'Process steps not available',
                  onOkClick: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectServicePage(),
                      ),
                    );
                  });

              /*FlushbarMessage.show(
                context,
                data["Message"],
                MessageTypes.ERROR,
              );*/
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
      isLoading = false;
    });
    return stepDetail;
  }

  Future<void> postProcessLog() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Processing';
      });

      ProcessLog log = ProcessLog(
        ProcessId: widget.processId,
        EntryNo: 0,
        ProcessLogId: 0,
        ProcessDescription: steps[stepIndex].IsProductStep
            ? steps[stepIndex].ITEM_NAME
            : "Additional data",
        ProductId: steps[stepIndex].IsProductStep
            ? steps[stepIndex].ProductNo.toString()
            : '0',
        SSDetailId: steps[stepIndex].SSDetailId,
        UploadStatus: "Not Uploaded",
      );

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {};

          Uri postProcessLogUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ProcessLogUrls.PostProcessLogMaster,
            params,
          );

          String jsonBody = json.encode(log);

          print(postProcessLogUri);
          print(jsonBody);

          http.Response response = await http.post(
            postProcessLogUri,
            headers: NetworkHandler.postHeader(),
            body: jsonBody,
            encoding: Encoding.getByName("utf-8"),
          );

          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);

            if (data["Status"] == HttpStatusCodes.CREATED) {
              await postProcessLogFile(data["Data"]);
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
      isLoading = false;
      loadingText = 'Loading..';
    });
  }

  Future<void> postProcessLogFile(int processLogId) async {
    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> param = {
            'ProcessLogId': processLogId.toString(),
            'SSDetailId': steps[stepIndex].SSDetailId.toString(),
          };

          Uri postUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ProcessLogUrls.PostProcessLogImage,
            param,
          );
          print(capturedImage.path);

          var fff = capturedImage.readAsBytesSync().length;
          var kb = fff / 1024;
          var mb = kb / 1024;

          print('kb:$kb');
          print('mb:$mb');

          final mimeTypeData =
              lookupMimeType(steps[stepIndex].file.path).split('/');
          //  final mimeTypeData = lookupMimeType(capturedImage.path).split('/');
          //  final mimeTypeData = lookupMimeType(capturedImage.path, headerBytes: [0xFF, 0xD8]).split('/');
          final imageUploadRequest =
              http.MultipartRequest(HttpRequestMethods.POST, postUri);
          final file = await http.MultipartFile.fromPath(
            'image',
            steps[stepIndex].file.path,
            //   capturedImage.path,
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
              print(steps.length);
              print(stepIndex);
              if (stepIndex < steps.length - 1) {
                FlushbarMessage.show(
                  context,
                  'Saved Successfully...!',
                  MessageTypes.SUCCESS,
                );
                setState(() {
                  capturedImage = null;
                  stepIndex = stepIndex + 1;
                });
              } else {
                stepIndex = 0;
                steps = [];
                PopupHandler.showSuccessPopup(
                  context: this.context,
                  title: 'Completed...!',
                  description:
                      'Process completed...!\n Please Sign and Submit.',
                  onCancelClick: null,
                  onOkClick: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignNdSubmitPage(
                          file: widget.file,
                          processId: widget.processId,
                        ),
                      ),
                    );
                  },
                );

                /* FlushbarMessage.show(
                  context,
                  'Process complete...!\n Please Sign and Submit.',
                  MessageTypes.SUCCESS,
                );*/
                //  await Future.delayed(Duration(seconds: 4));

              }
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
  }

  Future<void> updatePauseProcess() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Processing';
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "ProcessId": widget.processId.toString(),
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
              setState(() {
                isLoading = false;
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
}

class FileProcessPageOld extends StatefulWidget {
  final TallyFile file;
  final int processId;

  FileProcessPageOld({this.file, this.processId});

  @override
  _FileProcessPageOldState createState() => _FileProcessPageOldState();
}

class _FileProcessPageOldState extends State<FileProcessPageOld> {
  File capturedImage;
  bool isLoading;
  String loadingText;

  ImagePicker picker;
  String _retrieveDataError;

  VideoPlayerController _controller;
  VideoPlayerController _toBeDisposed;

  List<StepDetail> steps = [];
  int stepIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    picker = ImagePicker();
    isLoading = false;
    loadingText = 'Loading';

    ConnectivityManager().initConnectivity(this.context, this);
    getData();
  }

  getData() {
    fetchSteps().then((value) {
      steps = value;
    });
  }

  Future<void> _setUpVideo(PickedFile file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      VideoPlayerController controller;
      controller = VideoPlayerController.file(File(file.path));
      _controller = controller;

      final double volume = 1.0;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {});
    }
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();

    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Widget _previewVideo() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return Center(
        child: Text(
          steps[stepIndex]
              .StepSubEName, //AppTranslations.of(context).text("key_not_recorded_video_yet"),
          style: Theme.of(context).textTheme.bodyText2.copyWith(
                color: Colors.black54,
              ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(
        _retrieveDataError,
        style: Theme.of(context).textTheme.bodyText2.copyWith(
              color: Colors.redAccent,
            ),
      );
      _retrieveDataError = null;
      return result;
    }
    return null;
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
          actions: [
            _actionsPopup(),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*     Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400],
                    blurRadius: 1.0,
                    spreadRadius: 0.0,
                    offset:
                        Offset(0.0, 2.0), // shadow direction: bottom right
                  )
                ],
              ),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(
                horizontal: 5,
              ),
              child: Text(
                widget.file.FileUniqueNo,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Colors.black54,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),*/
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                steps != null && steps.isNotEmpty
                    ? steps[stepIndex].StepSubEName + ' ->'
                    : 'Waiting...',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
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
                          child: steps != null && steps.isNotEmpty
                              ? steps[stepIndex].FileType == 'Video'
                                  ? _previewVideo()
                                  : capturedImage == null
                                      ? Center(
                                          child: Text(
                                            steps[stepIndex]
                                                .StepSubEName /*    AppTranslations.of(context).text(
                                                "key_not_clicked_photo_yet")*/
                                            ,
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
                                          capturedImage,
                                          fit: BoxFit.fill,
                                        )
                              : Center(
                                  child: Text(
                                    'Waiting...',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                          color: Colors.black87,
                                        ),
                                  ),
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: steps != null && steps.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        steps[stepIndex].FileType == 'Video'
                                            ? _recordVideo(
                                                ImageSource.camera,
                                              )
                                            : _clickImage(
                                                ImageSource.camera,
                                              );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        color: Colors.white70,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              steps[stepIndex].FileType ==
                                                      'Video'
                                                  ? Icons.video_call_outlined
                                                  : Icons.add_a_photo_outlined,
                                              size: 20,
                                            ),
                                            Text(
                                              steps[stepIndex].FileType ==
                                                      'Video'
                                                  ? AppTranslations.of(context)
                                                      .text("key_record_video")
                                                  : AppTranslations.of(context)
                                                      .text("key_click_photo"),
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
                                    )
                                  : Center(
                                      child: Text(
                                        'Waiting...',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(
                                              color: Colors.black87,
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
                await postProcessLog();
              },
              child: Container(
                color: Theme.of(context).accentColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      steps != null && stepIndex != steps.length
                          ? AppTranslations.of(context).text("key_next")
                          : AppTranslations.of(context).text("key_sign_submit"),
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

  Widget _actionsPopup() => PopupMenuButton(
        padding: EdgeInsets.only(right: 10),
        onSelected: (value) {
          //redirect to Sign and submit page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SignNdSubmitPage(
                processId: widget.processId,
                file: widget.file,
              ),
            ),
          );
        },
        icon: Icon(
          Icons.more_vert,
          color: Colors.white,
        ),
        itemBuilder: (context) {
          var list_new = [
            PopupMenuItem(
              child: Text(
                AppTranslations.of(context).text("key_sign_submit"),
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Colors.black87,
                    ),
              ),
              value: 'sas',
            ),
          ];
          return list_new;
        },
      );

  _recordVideo(ImageSource iSource) async {
    try {
      if (_controller != null) {
        await _controller.setVolume(0.0);
      }
      var videoFile = await picker.getVideo(
        source: iSource,
        // maxDuration: Duration(seconds: 10),
      );

      if (videoFile != null) {
        await _handleVideo(videoFile);
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_try_again"),
          MessageTypes.ERROR,
        );
      }
    } catch (ce) {
      retrieveLostData();
    }
  }

  _clickImage(ImageSource iSource) async {
    try {
      var imageFile = await picker.getImage(
        source: iSource,
        imageQuality: 20,
      );
      if (imageFile != null) {
        await _handleImage(imageFile);
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_try_again"),
          MessageTypes.ERROR,
        );
      }
    } catch (ce) {
      retrieveLostData();
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.type == RetrieveType.video) {
          _handleVideo(response.file);
        } else {
          _handleImage(response.file);
        }
      });
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  _handleImage(PickedFile pickedFile) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Please wait';
      });
      var imageFile = pickedFile;

      String dir = (await getTemporaryDirectory()).path;

      DateTime now = DateTime.now();
      String timeStamp = DateFormat("dd/MM/yyyy HH:mm").format(now);
      String iName = DateFormat("dd-MM-yyyy hh:mm:ss").format(now);

      var imgName = iName;
      String newPath = path.join(dir, '$imgName.png');
      print('NewPath: $newPath');
      File f = await File(imageFile.path).copy(newPath);
      List<int> bytes = await f.readAsBytes();

      const int size = 80;
      final i.ImageEditorOption option = i.ImageEditorOption();
      final i.AddTextOption textOption = i.AddTextOption();
      textOption.addText(
        i.EditorText(
          offset: Offset(1, 1),
          text: timeStamp,
          fontSizePx: size,
          textColor: Colors.red,
        ),
      );

      option.outputFormat = const i.OutputFormat.png();

      option.addOption(textOption);

      final Uint8List result = await i.ImageEditor.editImage(
        image: bytes,
        imageEditorOption: option,
      );
      print(option.toString());
      f.writeAsBytes(result);
      setState(() {
        capturedImage = f;
        isLoading = false;
      });
    } catch (ce) {
      FlushbarMessage.show(
        context,
        ce.toString(),
        MessageTypes.WARNING,
      );
    }
  }

  _handleVideo(PickedFile pickedFile) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Please wait';
      });
      var videoFile = pickedFile;
      await _setUpVideo(videoFile);

      String dir = (await getTemporaryDirectory()).path;

      DateTime now = DateTime.now();
      String timeStamp = DateFormat("dd/MM/yyyy HH:mm").format(now);
      String iName = DateFormat("dd-MM-yyyy hh:mm:ss").format(now);

      var imgName = iName;
      String newPath = path.join(dir, '$imgName.mp4');
      print('NewPath: $newPath');

      File vidF = await File(videoFile.path).copy(newPath);

      setState(() {
        capturedImage = vidF;
        isLoading = false;
      });
    } catch (ce) {
      FlushbarMessage.show(
        context,
        ce.toString(),
        MessageTypes.WARNING,
      );
    }
  }

  Future<List<StepDetail>> fetchSteps() async {
    List<StepDetail> stepDetail;
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Loading';
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {
            "FileId": widget.file.FILEID.toString(),
          };

          Uri fetchDepartmentUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                StepDetailUrls.GetServiceStepDetailByServiceId,
            params,
          );
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
                stepDetail = responseData
                    .map((item) => StepDetail.fromMap(item))
                    .toList();
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
    return stepDetail;
  }

  Future<void> postProcessLog() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Processing';
      });

      ProcessLog log = ProcessLog(
        ProcessId: widget.processId,
        EntryNo: 0,
        ProcessLogId: 0,
        ProcessDescription: "Additional data",
        ProductId: "0",
        SSDetailId: steps[stepIndex].SSDetailId,
        UploadStatus: "Not Uploaded",
      );

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> params = {};

          Uri postProcessLogUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ProcessLogUrls.PostProcessLogMaster,
            params,
          );

          String jsonBody = json.encode(log);

          print(postProcessLogUri);
          print(jsonBody);

          http.Response response = await http.post(
            postProcessLogUri,
            headers: NetworkHandler.postHeader(),
            body: jsonBody,
            encoding: Encoding.getByName("utf-8"),
          );

          if (response.statusCode == HttpStatusCodes.OK) {
            var data = json.decode(response.body);

            if (data["Status"] == HttpStatusCodes.CREATED) {
              await postProcessLogFile(data["Data"]);
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

  Future<void> postProcessLogFile(int processLogId) async {
    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          Map<String, dynamic> param = {
            'ProcessLogId': processLogId.toString(),
          };

          Uri postUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ProcessLogUrls.PostProcessLogImage,
            param,
          );
          print(capturedImage.path);

          final mimeTypeData = lookupMimeType(capturedImage.path).split('/');
          //  final mimeTypeData = lookupMimeType(capturedImage.path, headerBytes: [0xFF, 0xD8]).split('/');
          final imageUploadRequest =
              http.MultipartRequest(HttpRequestMethods.POST, postUri);
          final file = await http.MultipartFile.fromPath(
            'image',
            capturedImage.path,
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
              print(steps.length);
              print(stepIndex);
              if (stepIndex < steps.length - 1) {
                FlushbarMessage.show(
                  context,
                  'Saved Successfully...!',
                  MessageTypes.SUCCESS,
                );
                setState(() {
                  capturedImage = null;
                  stepIndex = stepIndex + 1;
                });
              } else {
                stepIndex = 0;
                steps = [];
                FlushbarMessage.show(
                  context,
                  'Process complete...!\n Please Sign and Submit.',
                  MessageTypes.SUCCESS,
                );
                await Future.delayed(Duration(seconds: 4));
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SignNdSubmitPage(
                      file: widget.file,
                      processId: widget.processId,
                    ),
                  ),
                );
              }
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
}
