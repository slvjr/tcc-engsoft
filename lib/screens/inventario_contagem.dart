import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_beep/flutter_beep.dart';
import '../stores/form.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/messagebar.dart';
import '../services/api.dart';
import '../services/api_inventario.dart';

class InventarioContagemScreen extends StatefulWidget {
  @override
  _InventarioContagemPageState createState() => _InventarioContagemPageState();
}

class _InventarioContagemPageState extends State<InventarioContagemScreen> {
  TextEditingController _codprodController;
  TextEditingController _codbarrasController;
  TextEditingController _locruaController;
  TextEditingController _locpredioController;
  TextEditingController _locandarController;
  TextEditingController _quantidadeController;
  Map<String, dynamic> _produto;

  final _store = FormStore();

  @override
  initState() {
    super.initState();
    this._codprodController = new TextEditingController();
    this._codbarrasController = new TextEditingController();
    this._locruaController = new TextEditingController();
    this._locpredioController = new TextEditingController();
    this._locandarController = new TextEditingController();
    this._quantidadeController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventário - Contagem"),
      ),
      body: Stack(children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              SizedBox(height: 10.0),
              Text('Leitura do produto:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10.0),
              Focus(
                child: TextFormField(
                  controller: this._codprodController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Código interno',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1.0),
                          borderRadius: BorderRadius.circular(5.0))),
                  onChanged: (value) {
                    // se está em branco, libera o campo do código de barras
                    if (_codprodController.text.isEmpty) _atualizaProduto();
                  },
                ),
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    _atualizaProduto();
                  }
                },
              ),
              SizedBox(height: 10.0),
              Visibility(
                visible: _produto != null,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(children: [
                      Text(
                        _produto != null
                            ? _produto['CODPROD'].toString() +
                                " - " +
                                _produto['DESCRPROD']
                            : "",
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
                          _produto != null && _produto['ATIVO'] == 'N'
                              ? "INATIVO"
                              : "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        Expanded(
                          child: Text(
                            _produto != null ? _produto['UNIDADE'] : "",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ])
                    ]),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Visibility(
                visible: _codprodController.text.isEmpty,
                child: Focus(
                  child: TextFormField(
                    controller: this._codbarrasController,
                    //keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Código de barras',
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
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      _atualizaProduto();
                    }
                  },
                ),
              ),
              SizedBox(height: 10.0),
              Text('Localização:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: this._locruaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Rua',
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
                  ),
                  SizedBox(width: 10.0),
                  Flexible(
                    child: TextFormField(
                      controller: this._locpredioController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Prédio',
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
                  ),
                  SizedBox(width: 10.0),
                  Flexible(
                    child: TextFormField(
                      controller: this._locandarController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Andar',
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
                  ),
                ],
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

  Future _scan() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      //print('nothing return.');
    } else {
      this._codbarrasController.text = barcode;
    }
  }

  _register() async {
    if (_codprodController.text.isNotEmpty && _produto == null) {
      // se informou o código interno, precisa conferir o produto
      _atualizaProduto();
      return;
    }

    String codprod = this._codprodController.text;
    String barcode = this._codbarrasController.text;
    int quantidade = int.tryParse(this._quantidadeController.text) ?? -1;
    String erro;
    int codigo = 0;

    _store.loading = true;

    if (barcode.isEmpty && codprod.isEmpty)
      erro = "Informe o código do produto ou código de barras.";
    else if (barcode.isNotEmpty && codprod.isNotEmpty)
      erro = "Informe ou código do produto, ou código de barras.";
    else if (!(quantidade >= 0)) erro = "Informe a quantidade.";

    // first, finds the product
    if (erro == null) {
      await api.connect();
      if (api.isActive()) {
        // faz a busca...
        Map product;
        if (codprod.isEmpty)
          product = await api.consultaProduto(barcode);
        else
          product = await api.consultaProdutoCod(int.tryParse(codprod) ?? 0);
        if (product != null) {
          codigo = await api.insereContagem(product['CODPROD'], quantidade);
          // se teve atualização da localização, registra no banco
          if ((this._locruaController.text.isNotEmpty ||
                  this._locpredioController.text.isNotEmpty ||
                  this._locandarController.text.isNotEmpty) &&
              (this._locruaController.text != _produto['RUA'] ||
                  this._locpredioController.text != _produto['PREDIO'] ||
                  this._locandarController.text != _produto['ANDAR']))
            await api.atualizaLocalizacao(
                product['CODPROD'],
                this._locruaController.text,
                this._locpredioController.text,
                this._locandarController.text);
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

      this._codprodController.text = "";
      this._codbarrasController.text = "";
      this._locruaController.text = "";
      this._locpredioController.text = "";
      this._locandarController.text = "";
      this._quantidadeController.text = "";
      _produto = null;
    } else {
      FlutterBeep.beep(false);
      Messagebar.error(
          erro ?? "Não foi possível registrar a contagem.", context);
    }
  }

  // quando é digitado o código interno, mostra o produto para confirmar
  _atualizaProduto() async {
    _store.loading = true;

    String erro;
    String codprod = this._codprodController.text;
    String codbarras = this._codbarrasController.text;

    if (codprod.isNotEmpty) {
      int codigo = 0;
      codigo = int.tryParse(codprod) ?? 0;

      if (codprod.isNotEmpty && !(codigo > 0))
        erro = "Código do produto inválido.";

      if (erro == null) {
        _produto = await api.consultaProdutoCod(codigo);
        if (_produto == null) {
          erro = api.hasError() ? api.getError() : "Produto não encontrado.";
        }
      }
    } else if (codbarras.isNotEmpty) {
      if (codbarras.contains(' ')) erro = "Código de barras inválido.";
      if (erro == null) {
        _produto = await api.consultaProduto(codbarras);
        if (_produto == null) {
          erro = api.hasError() ? api.getError() : "Produto não encontrado.";
        }
      }
    } else
      _produto = null;

    if (_produto != null) {
      // atualiza a localização que está registrada
      this._locruaController.text = _produto['RUA'];
      this._locpredioController.text = _produto['PREDIO'];
      this._locandarController.text = _produto['ANDAR'];
    }

    setState(() {});

    _store.loading = false;

    if (erro != null) {
      Messagebar.error(erro, context);
    }
  }
}
