import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart' as i;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pulse_india/localization/app_translations.dart';

class CustomTakePicture extends StatefulWidget {
  final CameraDescription camera;

  const CustomTakePicture({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _CustomTakePictureState createState() => _CustomTakePictureState();
}

class _CustomTakePictureState extends State<CustomTakePicture> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("key_let_selfie"),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColorDark,
        child: Icon(Icons.camera),
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            var f = await _controller.takePicture();

            File file = await File(f.path).copy(path);

            List<int> bytes = await file.readAsBytes();

            DateTime now = DateTime.now();
            String timeStamp = DateFormat("dd/MM/yyyy HH:mm").format(now);

            const int size = 30;
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
            file.writeAsBytes(result);

            Navigator.pop(context, path);
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
