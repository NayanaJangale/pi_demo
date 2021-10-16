import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ZoomImagePage extends StatelessWidget {
  final String url, siv;
  const ZoomImagePage({
    this.siv,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(siv),
      ),
      body: PhotoView(
        backgroundDecoration: BoxDecoration(
          color: Colors.white,
        ),
        customSize: Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height * 0.9,
        ),
        basePosition: Alignment.center,
        imageProvider: NetworkImage(url),
        loadingBuilder: (context, event) {
          return Center(child: CupertinoActivityIndicator());
        },
      ),
    );
  }
}
