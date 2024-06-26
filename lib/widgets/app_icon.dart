import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  final image;

  const AppIconWidget({
    Key key,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // pega o tamanho da tela
    var size = MediaQuery.of(context).size;

    // calcula largura do container
    double imageSize;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      imageSize = (size.width * 0.30);
    } else {
      imageSize = (size.height * 0.30);
    }

    return Image.asset(
      image,
      height: imageSize,
    );
  }
}
