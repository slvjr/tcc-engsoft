import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ConsultaProdutoImagemScreen extends StatefulWidget {
  @override
  _ConsultaProdutoImagemPageState createState() =>
      _ConsultaProdutoImagemPageState();
}

class _ConsultaProdutoImagemPageState
    extends State<ConsultaProdutoImagemScreen> {
  @override
  Widget build(BuildContext context) {
    List args = ModalRoute.of(context).settings.arguments;
    int _codprod = args.first;
    String _title =
        args.asMap().containsKey(1) ? args[1] : 'Consulta produto - imagem';

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        elevation: 0.0,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(
              "http://10.1.1.195:8280/mge/Produto@IMAGEM@CODPROD=" +
                  _codprod.toString() +
                  ".dbimage"),
          backgroundDecoration: BoxDecoration(
            color: Colors.white,
          ),
          loadingBuilder: (context, event) {
            if (event == null) {
              return const Center(
                child: Text("Carregando"),
              );
            }

            final value = event.cumulativeBytesLoaded /
                (event.expectedTotalBytes ?? event.cumulativeBytesLoaded);

            final percentage = (100 * value).floor();
            return Center(
              child: Text("$percentage%"),
            );
          },
        ),
      ),
/*
      Image.network(
        "http://10.1.1.195:8280/mge/Produto@IMAGEM@CODPROD=" +
            _codprod.toString() +
            ".dbimage",
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
*/
    );
  }
}
