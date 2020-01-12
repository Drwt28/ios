import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreen extends StatelessWidget {
  String image, tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Homework'),),
      body: Hero(
        tag: tag,
        child: PhotoView(
          imageProvider: NetworkImage(image),
        ),
      ),
    );
  }

  FullScreen({@required this.image, this.tag});
}
