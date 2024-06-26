import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_beep/flutter_beep.dart';
import '../stores/form.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/messagebar.dart';
import '../services/api.dart';
import '../services/api_inventario.dart';

class InventarioRecontagemScreen extends StatefulWidget {
  @override
  _InventarioRecontagemPageState createState() =>
      _InventarioRecontagemPageState();
}

class _InventarioRecontagemPageState extends State<InventarioRecontagemScreen> {
  TextEditingController _codprodController;
  TextEditingController _quantidadeController;
  String _enderecoValue;
  Map<String, dynamic> _produto;

  final _store = FormStore();
  List<String> _ruas = [];

  @override
  initState() {
    super.initState();
    this._codprodController = new TextEditingController();
    this._quantidadeController = new TextEditingController();
    _loadEnderecos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventário - Recontagem"),
      ),
      body: Stack(children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              SizedBox(height: 10.0),
              Text('Selecione o local:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                focusColor: Colors.white,
                value: _enderecoValue,
                //elevation: 5,
                decoration: InputDecoration(
                    labelText: 'Endereço',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(width: 32.0),
                        borderRadius: BorderRadius.circular(5.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.0),
                        borderRadius: BorderRadius.circular(5.0))),
                style: TextStyle(color: Colors.white),
                iconEnabledColor: Colors.black,
                items: _ruas.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      'Rua ' + value,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (String value) {
                  _enderecoValue = value;
                  _loadProxRecontagem();
                },
              ),
              Visibility(
                visible: _produto != null,
                child: Column(children: [
                  SizedBox(height: 10.0),
                  Text('Produto:', style: TextStyle(fontSize: 18)),
                  Card(
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(
                          context, '/consulta_produto_detalhe',
                          arguments: [_produto['CODPROD']]),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(children: [
                          Text(
                            _produto != null ? _produto['DESCRPROD'] : "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 5.0),
                          Row(children: [
                            Expanded(
                              child: Text(
                                _produto != null ? _produto['MARCA'] : "",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(
                                child: Text(
                              _produto != null ? _produto['UNIDADE'] : "",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            )),
                            Expanded(
                              child: Text(
                                _produto != null ? _produto['ENDERECO'] : "",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ])
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
              SizedBox(height: 10.0),
              Text('Contagem:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10.0),
              TextFormField(
                controller: this._quantidadeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(width: 32.0),
                      borderRadius: BorderRadius.circular(5.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1.0),
                      borderRadius: BorderRadius.circular(5.0)),
                  contentPadding: new EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    _register();
                  },
                  child:
                      const Text('Registrar', style: TextStyle(fontSize: 16))),
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
    );
  }

/*
  Future _scan() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      //print('nothing return.');
    } else {
      this._codbarrasController.text = barcode;
    }
  }
*/
  _register() async {
    int quantidade = int.tryParse(this._quantidadeController.text) ?? -1;
    String erro;
    int codigo = 0;

    _store.loading = true;

    if (quantidade < 0) {
      erro = "Precisa informar a quantidade.";
    } else {
      await api.connect();
      if (api.isActive()) {
        if (_produto != null && _produto['CODPROD'] > 0) {
          codigo = await api.insereContagem(_produto['CODPROD'], quantidade);
        } else
          erro = api.hasError() ? api.getError() : "Contagem não registrada.";
        api.disconnect();
      } else {
        if (api.hasError())
          erro = api.getError();
        else
          erro = "Busca falhou.";
      }
    }

    _store.loading = false;

    if (codigo > 0) {
      FlutterBeep.beep();
      Messagebar.success("Contagem registrada.", context);
      _loadProxRecontagem();
      this._codprodController.text = "";
      this._quantidadeController.text = "";
    } else {
      FlutterBeep.beep(false);
      Messagebar.error(
          erro ?? "Não foi possível registrar a contagem.", context);
    }
  }

  _loadProxRecontagem() async {
    _store.loading = true;

    _produto = await api.carregaProxRecontagem(_enderecoValue);

    setState(() {});

    _store.loading = false;

    if (_produto != null && _produto['CODPROD'] > 0) {
      Messagebar.info("Informe a quantidade contada.", context);
    } else {
      _enderecoValue = null;
      _showDialogProximaRua();
      _loadEnderecos();
      /*
      Messagebar.error(
          "Não há mais recontagem nesse endereço. Selecione outra rua para prosseguir.",
          context);
      */
    }
  }

  _loadEnderecos() async {
    _store.loading = true;

    _ruas = await api.carregaEnderecos();
    setState(() {});

    _store.loading = false;

    if (_ruas != null && _ruas.length > 0) {
      //FlutterBeep.beep(true);
      Messagebar.info("Selecione uma rua para prosseguir.", context);
    } else {
      //FlutterBeep.beep(false);
      _showDialogFecha();
    }
  }

  _showDialogFecha() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Atenção"),
          content: Text("Nenhuma recontagem pendente."),
          actions: <Widget>[
            ElevatedButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop(false);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  _showDialogProximaRua() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Atenção"),
          content: Text("Não há mais itens para recontar nessa rua."),
          actions: <Widget>[
            ElevatedButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
