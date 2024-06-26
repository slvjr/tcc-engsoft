import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/messagebar.dart';
import '../services/api.dart';
import '../services/api_tarefa.dart';

class ReabastecimentoScreen extends StatefulWidget {
  @override
  _ReabastecimentoPageState createState() => _ReabastecimentoPageState();
}

class _ReabastecimentoPageState extends State<ReabastecimentoScreen> {
  bool _loading = false;
  Map _tarefa = {};
  int _fase = 0;

  TextEditingController _produtoController;
  TextEditingController _origemController;
  TextEditingController _destinoController;

  Future<void> changeLoading(bool value) async {
    setState(() {
      _loading = value;
    });
  }

  void atualizaTarefa(busca) {
    _tarefa = {
      'tarefa': int.parse(busca['C1']),
      'sequencia': int.parse(busca['C2']),
      'produto': busca['C20'],
      'produto_descricao': busca['C15'],
      'unidade': busca['C25'],
      'quantidade': busca['C9'],
      'origem': busca['C16'],
      'origem_descricao': busca['C17'],
      'destino': busca['C18'],
      'destino_descricao': busca['C19'],
    };
    atualizaFase(1);
  }

  void atualizaFase(int fase) {
    setState(() {
      if (fase == 0) {
        _produtoController.clear();
        _origemController.clear();
        _destinoController.clear();
      }
      _fase = fase;
    });
  }

  @override
  initState() {
    _iniciaReabastecimento();
    super.initState();
    _produtoController = new TextEditingController();
    _origemController = new TextEditingController();
    _destinoController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _cancelaReabastecimento,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Reabastecimento"),
          ),
          body: Stack(children: <Widget>[
            SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(children: [
                    Visibility(
                      visible: _fase > 0,
                      child: Column(children: [
                        Text('Pegue:', style: TextStyle(fontSize: 18)),
                        Card(
                            color: Colors.orange[50],
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(children: [
                                Text(_tarefa['produto_descricao'] ?? "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                SizedBox(height: 10.0),
                                Row(children: [
                                  Expanded(
                                    child: Column(children: [
                                      Text("Quantidade"),
                                      Text(
                                        (_tarefa['quantidade']?.toString() ??
                                                "") +
                                            " " +
                                            (_tarefa['unidade']?.toString() ??
                                                ""),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ]),
                                  ),
                                  Expanded(
                                    child: Column(children: [
                                      Text("Endereço"),
                                      Text(
                                        _tarefa['origem_descricao']
                                                ?.toString() ??
                                            "",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ]),
                                  ),
                                ]),
                              ]),
                            )),
                        SizedBox(height: 10.0),
                        TextFormField(
                          enabled: _fase == 1,
                          controller: this._produtoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Produto',
                            suffixIcon: IconButton(
                              onPressed: () => _scanProduto(),
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
                        ),
                        SizedBox(height: 10.0),
                        TextFormField(
                          enabled: _fase == 1,
                          controller: _origemController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Endereço de origem',
                            suffixIcon: IconButton(
                              onPressed: () => _scanOrigem(),
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
                        ),
                        SizedBox(height: 10.0),
                        Visibility(
                            visible: _fase == 1,
                            child: Wrap(children: [
                              ElevatedButton(
                                onPressed: () {
                                  _rejeitaTarefa();
                                },
                                child: const Text('Rejeitar'),
                              ),
                              SizedBox(width: 5),
                              ElevatedButton(
                                onPressed: () {
                                  _marcaTarefa(this._produtoController.text,
                                      this._origemController.text);
                                },
                                child: const Text('Prosseguir'),
                              ),
                            ])),
                      ]),
                    ),
                    Visibility(
                      visible: _fase > 1,
                      child: Column(children: [
                        SizedBox(height: 10.0),
                        Text('Destino:', style: TextStyle(fontSize: 18)),
                        Card(
                            color: Colors.orange[50],
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(children: [
                                //Text("Destino:"),
                                Text(_tarefa['destino_descricao'] ?? "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ]),
                            )),
                        SizedBox(height: 10.0),
                        TextFormField(
                          controller: _destinoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Endereço de destino',
                            suffixIcon: IconButton(
                              onPressed: () => _scanDestino(),
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
                              _rejeitaTarefa();
                            },
                            child: const Text('Rejeitar'),
                          ),
                          SizedBox(width: 5),
                          ElevatedButton(
                            onPressed: () {
                              _envioTarefa(this._destinoController.text);
                            },
                            child: const Text('Prosseguir'),
                          ),
                        ]),
                      ]),
                    ),
                    SizedBox(height: 10.0),
                  ]),
                )),
            Visibility(
              visible: _loading,
              child: CustomProgressIndicatorWidget(),
            ),
          ]),
        ));
  }

  Future _iniciaReabastecimento() async {
    changeLoading(true);
    //await api.connect();
    //if (api.isActive()) {
    await api.buscaUltimaTarefaExecucaoColetor();
    await api.removeTarefaExecucaoColetor();
    await _buscaTarefa();
    //api.disconnect();
    //}
    changeLoading(false);
  }

  Future _buscaTarefa() async {
    changeLoading(true);
    String erro = "";
    await api.buscaUltimaTarefaExecucaoColetor();
    final busca = await api.buscaTarefa(4);
    if (busca.isNotEmpty) {
      atualizaTarefa(busca);
    } else {
      // pega erro e fecha
      if (api.hasStatusMessage())
        erro = api.getStatusMessage();
      else if (api.hasError())
        erro = api.getError();
      else
        erro = "Próxima tarefa não encontrada.";
    }
    changeLoading(false);
    if (erro.isNotEmpty) _showDialogErro(erro);
  }

  Future _scanProduto() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode != null) {
      _produtoController.text = barcode;
      if (_origemController.text.isNotEmpty)
        _marcaTarefa(_produtoController.text, _origemController.text);
    }
  }

  Future _scanOrigem() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode != null) {
      _origemController.text = barcode;
      if (_produtoController.text.isNotEmpty)
        _marcaTarefa(_produtoController.text, _origemController.text);
    }
  }

  Future _scanDestino() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode != null) {
      _destinoController.text = barcode;
      _envioTarefa(this._destinoController.text);
    }
  }

  Future<bool> _marcaTarefa(String produto, String origem) async {
    String erro = "";

    if (produto?.isEmpty ?? true)
      erro = "Precisa informar o código do produto.";
    else if (produto.length < 5)
      erro = "Código de barras do produto inválido.";
    else if (produto != _tarefa['produto'])
      erro = "Produto inválido.";
    else if (origem.replaceAll(new RegExp(r'[^0-9]'), '') !=
        _tarefa['origem'].replaceAll(new RegExp(r'[^0-9]'), ''))
      erro = "Endereço de origem inválido.";

    if (erro.isEmpty) {
      await api.marcaTarefaEmTransito(
          _tarefa['tarefa'], _tarefa['sequencia'], produto);
      if (api.getStatus() != 1)
        erro = api.getStatusMessage();
      else {
        Messagebar.success("Tarefa em trânsito, prossiga.", context);
        atualizaFase(2);
      }
    }
    if (erro.isNotEmpty) Messagebar.error(erro, context);

    return true;
  }

  Future<bool> _rejeitaTarefa() async {
    String erro = "";

    print(_tarefa['tarefa']);

    if (!((_tarefa['tarefa'] ?? 0) > 0))
      erro = "Não há tarefa em andamento.";
    else if (!((_tarefa['sequencia'] ?? 0) > 0))
      erro = "Sequência não identificada.";

    if (erro.isEmpty) {
      var confirma = await _showDialogCancela();
      if (!confirma)
        return false;
      else {
        changeLoading(true);
        await api.rejeitaTarefa(_tarefa['tarefa'], _tarefa['sequencia']);
        changeLoading(false);
        if (api.getStatus() != 1)
          erro = api.getStatusMessage();
        else {
          atualizaFase(0);
          _showDialogErro("Tarefa rejeitada.");
          //_buscaTarefa();
        }
      }
    }
    if (erro.isNotEmpty) {
      Messagebar.error(erro, context);
      return false;
    } else
      return true;
  }

  Future<bool> _envioTarefa(String destino) async {
    String erro = "";

    if (destino?.isEmpty ?? true)
      erro = "Precisa informar o endereço de destino.";
    else if (destino.replaceAll(new RegExp(r'[^0-9]'), '') !=
        _tarefa['destino'].replaceAll(new RegExp(r'[^0-9]'), ''))
      erro = "Endereço de destino inválido.";

    if (erro.isEmpty) {
      await api.envioTarefa();
      if (api.getStatus() != 1)
        erro = api.getStatusMessage();
      else {
        atualizaFase(0);
        Messagebar.success("Tarefa enviada, buscando a próxima.", context);
        _buscaTarefa();
      }
    }
    if (erro.isNotEmpty) Messagebar.error(erro, context);

    return true;
  }

  Future<bool> _showDialogErro(String erro) {
    return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Atenção"),
              content: Text(erro),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("Fechar"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _showDialogCancela() {
    return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Atenção"),
              content: Text("Confirma rejeitar a tarefa em andamento?"),
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

  Future<bool> _cancelaReabastecimento() async {
    if (_fase == 0) {
      // se nao tem conferencia em andamento, apenas fecha
      Navigator.of(context).pop(true);
      return true;
    } else
      return await _rejeitaTarefa();
  }
}
