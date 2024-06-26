import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
//import 'package:cached_network_image/cached_network_image.dart';
import '../stores/form.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/messagebar.dart';
import '../services/api.dart';
import '../services/api_consulta.dart';

class ConsultaProdutoScreen extends StatefulWidget {
  @override
  _ConsultaProdutoPageState createState() => _ConsultaProdutoPageState();
}

class _ConsultaProdutoPageState extends State<ConsultaProdutoScreen> {
  TextEditingController _outputController;
  List<Map<String, dynamic>> prodList = [];

  final _store = FormStore();

  @override
  initState() {
    super.initState();
    this._outputController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consulta produto"),
      ),
      body: Stack(children: <Widget>[
        Column(children: [
          SizedBox(height: 10.0),
          Text('Pesquisa por produto:', style: TextStyle(fontSize: 18)),
          Container(
            padding: EdgeInsets.all(10.0),
            child: TextFormField(
              controller: this._outputController,
              decoration: InputDecoration(
                  hintText: 'Código ou nome do produto',
                  suffixIcon: IconButton(
                    onPressed: () => _scan(),
                    icon: Icon(Icons.camera_alt),
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(width: 32.0),
                      borderRadius: BorderRadius.circular(5.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1.0),
                      borderRadius: BorderRadius.circular(5.0))),
              onChanged: (value) {
                //Do something with this value
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _search();
            },
            child: const Text('Consultar'),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: prodList?.length ?? 0,
              itemBuilder: prodListItem,
              padding: EdgeInsets.all(10.0),
            ),
          )
        ]),
//          ),
//        ),
        Observer(
          builder: (context) {
            return Visibility(
              visible: _store.loading,
              child: CustomProgressIndicatorWidget(),
            );
          },
        )
      ]),
    );
  }

  Future _scan() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
    } else {
      //this._outputController.text += '\n' + barcode;
      this._outputController.text = barcode;
    }
  }

  _search() async {
    String barcode = this._outputController.text;
    String erro;

    _store.loading = true;

    if (barcode == "") erro = "Precisa informar código ou nome para consultar.";
    //else if (barcode.length < 5) erro = "Código ou nome inválido.";

    if (erro == null) {
      prodList = await api.pesquisaProduto(barcode);
      setState(() {});
      if ((prodList?.length ?? 0) == 1) {
        Navigator.pushNamed(context, '/consulta_produto_detalhe',
            arguments: [prodList[0]['CODPROD']]);
      } else if (api.hasError())
        erro = api.getError();
      // fecha o teclado para deixar a lista de resultados visível
      else
        FocusScope.of(context).unfocus();
    }

    _store.loading = false;

    if (erro != null) {
      Messagebar.error(erro, context);
    }
  }

  Widget prodListItem(BuildContext context, int index) {
    return Card(
      child: InkWell(
        splashColor: Colors.grey,
        onTap: () => Navigator.pushNamed(context, '/consulta_produto_detalhe',
            arguments: [prodList[index]['CODPROD'], null]),
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(children: [
            Text(
              prodList[index]['DESCRPROD'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5.0),
            Row(children: [
              Expanded(
                child: Text(
                  prodList[index]['MARCA'],
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                child: Text(
                  prodList[index]['CODPROD'].toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                child: Text(
                  prodList[index]['REFERENCIA'],
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
