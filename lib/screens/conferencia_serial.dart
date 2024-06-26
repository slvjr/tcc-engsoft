import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../stores/form.dart';
import '../widgets/progress_indicator.dart';
import '../services/api.dart';
import '../services/api_conferencia.dart';

class ConferenciaSerialScreen extends StatefulWidget {
  @override
  _ConferenciaSerialPageState createState() => _ConferenciaSerialPageState();
}

class _ConferenciaSerialPageState extends State<ConferenciaSerialScreen> {
  Map<String, dynamic> produto;
  TextEditingController _serieController;
  List<String> items = [];
  final _store = FormStore();

  @override
  initState() {
    super.initState();
    this._serieController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    produto = ModalRoute.of(context).settings.arguments;

    return WillPopScope(
        onWillPop: _cancelaConferenciaSerie,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Conferência - Serial"),
          ),
          body: Stack(children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(children: [
                  Card(
                      child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(produto['DESCRPROD'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)))),
                  SizedBox(height: 10.0),
                  Text('Informe o número de série:',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: this._serieController,
                    decoration: InputDecoration(
                      labelText: 'Número de série',
                      suffixIcon: IconButton(
                        onPressed: () => _scanSerie(),
                        icon: Icon(Icons.camera_alt),
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      contentPadding: new EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                    ),
                    onChanged: (value) {
                      //Do something with this value
                    },
                  ),
                  Wrap(children: [
                    ElevatedButton(
                      onPressed: () {
                        _cancelaConferenciaSerie();
                      },
                      child: const Text('Cancelar'),
                      //color: Colors.red,
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () {
                        _validaSerie();
                      },
                      child: const Text('Prosseguir'),
                    ),
                  ]),
                  SizedBox(width: 5),
                  items.isEmpty
                      ? SizedBox(width: 5)
                      : Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Dismissible(
                                  key: Key(item),
                                  direction: DismissDirection.startToEnd,
                                  child: ListTile(
                                    contentPadding:
                                        EdgeInsets.only(left: 16.0, right: 0.0),
                                    visualDensity: VisualDensity(
                                        horizontal: -4, vertical: -4),
                                    title: Text(item),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          items.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    setState(() {
                                      items.removeAt(index);
                                    });
                                  },
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(height: 1);
                              }),
                        ),
                ]),
              ),
            ),
            Observer(
              builder: (context) {
                return Visibility(
                  visible: _store.loading,
                  child: CustomProgressIndicatorWidget(),
                );
              },
            )
          ]),
        ));
  }

  Future _scanSerie() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      //print('nothing return.');
    } else {
      this._serieController.text = barcode;
      this._validaSerie();
    }
  }

  _validaSerie() async {
    String barcode = this._serieController.text;
    String erro;

    bool existe = false;
    items.forEach((element) {
      if (element == barcode) existe = true;
    });

    _store.loading = true;
    if (barcode == "")
      erro = "Precisa informar a série.";
    else if (barcode.length < 5)
      erro = "Número de série inválido.";
    else if (existe) erro = "Série já registrada.";

    if (erro?.isEmpty ?? true) {
      //await api.connect();
      if (api.isActive()) {
        await api.validaUnicidadeSerieSeparacao(
            produto['NUCONFERENCIA'], produto['CODBARRAS'], barcode);
        if (api.getStatus() == 1) {
          setState(() {
            items.insert(0, barcode); // insere no início [0]
          });
          this._serieController.clear();
          if (items.length == produto['QUANTIDADE']) {
            String series = "";
            // atingiu a quantidade de séries
            items.forEach((element) {
              if (series.isNotEmpty) series += ",";
              series += element;
            });
            Navigator.pop(context, series);
          }
        } else
          erro = api?.getStatusMessage();
      } else {
        if (api.hasError())
          erro = api.getError();
        else
          erro = "Validação falhou.";
      }
    }

    _store.loading = false;

    if (erro != null) {
      FlushbarHelper.createError(
        message: erro,
        duration: Duration(seconds: 3),
      )..show(context);
    } else {
      FlushbarHelper.createSuccess(
        message: "Série registrada, informe a próxima.",
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  Future<bool> _cancelaConferenciaSerie() async {
    var confirma = await _showDialogCancela();
    if (confirma) {
      Navigator.of(context).pop(false);
      return true;
    } else
      return false;
  }

  Future<bool> _showDialogCancela() {
    return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Cancelando conferência - serial"),
              content: Text(
                  "Confirma cancelar a conferência de séries em andamento?"),
              actions: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey)),
                  child: Text(
                    "Não",
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ElevatedButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
