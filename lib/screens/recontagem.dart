import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import '../widgets/messagebar.dart';
import '../widgets/progress_indicator.dart';
import '../services/api.dart';
import '../services/api_recontagem.dart';

class RecontagemScreen extends StatefulWidget {
  @override
  _RecontagemPageState createState() => _RecontagemPageState();
}

class _RecontagemPageState extends State<RecontagemScreen> {
  bool _loading = false;

  Future<void> changeLoading(bool value) async {
    setState(() {
      _loading = value;
    });
  }

  // recontagem em andamento
  Map<String, int> recontagem = {
    'conferencia': 0,
    'tarefa': 0,
    'endereco': 0, // código da doca, não o endereço mascarado
    'sequencia': 0,
  };
  String produto_descr = "";

  TextEditingController _docaController;
  TextEditingController _prodQdeController;
  TextEditingController _prodAvariaController;
  TextEditingController _produtoController;

  @override
  initState() {
    _iniciaRecontagem();
    super.initState();
    this._docaController = new TextEditingController();
    this._prodQdeController = new TextEditingController();
    this._prodAvariaController = new TextEditingController();
    this._produtoController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _cancelaRecontagem,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Recontagem"),
          ),
          body: Stack(children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(children: [
                  SizedBox(height: 10.0),
                  Text('Leitura da doca:', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10.0),
                  TextFormField(
                    enabled: recontagem['conferencia'] == 0,
                    controller: this._docaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Endereço da doca',
                      suffixIcon: IconButton(
                        onPressed: () => _scanDoca(),
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
                  Visibility(
                      visible: recontagem['conferencia'] == 0,
                      child: ElevatedButton(
                        onPressed: () {
                          recontagem['conferencia'] > 0 ? null : _buscaDoca();
                        },
                        child: const Text('Consultar'),
                      )),
                  Visibility(
                      visible: recontagem['conferencia'] > 0,
                      child: Column(children: [
                        SizedBox(height: 10.0),
                        Text('Reconte o produto:',
                            style: TextStyle(fontSize: 18)),
                        Card(
                            color: Colors.orange[50],
                            child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(children: [
                                  Text(produto_descr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                ]))),
                        SizedBox(height: 10.0),
                        TextFormField(
                          controller: this._prodQdeController,
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
                        SizedBox(height: 10.0),
                        TextFormField(
                          controller: this._prodAvariaController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Quantidade avariada',
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
                          controller: this._produtoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Código do produto',
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
                        ElevatedButton(
                          onPressed: () {
                            recontagem['conferencia'] > 0
                                ? _enviaRecontagem()
                                : null;
                          },
                          child: const Text('Prosseguir'),
                        ),
                      ])),
                  Wrap(children: [
                    ElevatedButton(
                      onPressed: () {
                        _cancelaRecontagem();
                      },
                      child: const Text('Cancelar'),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () {
                        _finalizaRecontagem();
                      },
                      child: const Text('Finalizar'),
                    ),
                  ]),
                ]),
              ),
            ),
            Visibility(
              visible: _loading,
              child: CustomProgressIndicatorWidget(),
            ),
          ]),
        ));
  }

  Future _iniciaRecontagem() async {
    // nenhuma chacagem inicial...
  }

  Future _scanDoca() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode?.isNotEmpty ?? false) {
      this._docaController.text = barcode;
      this._buscaDoca();
    }
  }

  _buscaDoca() async {
    String barcode = this._docaController.text;
    String erro = "";

    changeLoading(true);
    if (barcode == "")
      erro = "Precisa informar o endereço.";
    else if (barcode.length < 5) erro = "Endereço inválido.";

    if (erro?.isEmpty ?? true) {
      // verifica de tem recontagem em andamento na doca
      await api.buscaInfoRecontagem(barcode);
      // TODO: continuar caso exista em andamento

      // faz a busca...
      Map<String, dynamic> doca;
      doca = await api.recontagemDoca(barcode);
      if (doca?.isNotEmpty ?? false) {
        _atualizaRecontagem(int.tryParse(doca['NUCONFERENCIA']),
            int.tryParse(doca['NUTAREFA']), int.tryParse(doca['CODEND']));
        _proximaRecontagem();
      } else {
        erro = api?.getError() ?? "Doca ou recontagem não encontradas.";
      }
    }

    changeLoading(false);

    if (erro.isNotEmpty)
      Messagebar.error(erro, context);
    else if (recontagem['conferencia'] > 0)
      Messagebar.success(
          "Doca selecionada, prossiga com a recontagem dos produtos.", context);
  }

  // atualiza a Doca
  _atualizaRecontagem(int conferencia, int tarefa, int endereco) {
    if (recontagem['conferencia'] == 0 && conferencia > 0) {
      setState(() {
        recontagem['conferencia'] = conferencia;
        recontagem['tarefa'] = tarefa;
        recontagem['endereco'] = endereco;
      });
    }
  }

  // atualiza a Doca
  _atualizaProduto(String descricao, int sequencia) {
    if (recontagem['conferencia'] > 0 && sequencia > 0) {
      setState(() {
        recontagem['sequencia'] = sequencia;
        produto_descr = descricao;
      });
    }
  }

  _proximaRecontagem() async {
    Map<String, dynamic> proxima;
    String erro = "";

    proxima = await api.proximaRecontagem(recontagem['conferencia'],
        recontagem['tarefa'], recontagem['endereco']);
    if (proxima?.isNotEmpty ?? false) {
      _atualizaProduto(
          proxima['DESCRPROD'], int.tryParse(proxima['SEQUENCIA']));
    } else
      erro = api.getError() ?? "Próximo produto não encontrado.";
    print(proxima);

    if (erro.isNotEmpty) Messagebar.error(erro, context);
  }

  Future _scanProduto() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      //print('nothing return.');
    } else {
      this._produtoController.text = barcode;
      this._enviaRecontagem();
    }
  }

  Future<bool> _enviaRecontagem() async {
    int quantidade = int.tryParse(this._prodQdeController?.text) ?? 0;
    int avaria = int.tryParse(this._prodAvariaController?.text) ?? 0;
    String barcode = this._produtoController?.text;
    String erro;

    changeLoading(true);

    if (avaria < 1) avaria = 0;
    if (quantidade < 1)
      erro = "Precisa informar a quantidade do produto.";
    else if (quantidade > 9999)
      erro = "Quandidade do produto inválida.";
    else if (avaria > quantidade)
      erro = "Quandidade avariada não pode ser maior que a quantidade total.";
    else if (barcode == "")
      erro = "Precisa informar o código de barras do produto.";
    else if (barcode.length < 5) erro = "Código de barras inválido.";

    if (erro?.isEmpty ?? true) {
      // faz a busca...
      Map<String, dynamic> produto;
      produto = await api.buscaInfoProduto(
          barcode, recontagem['conferencia'], quantidade);
      if (produto?.isNotEmpty ?? false) {
        var series;
        if (produto['USASERIESEPWMS'] == 'true') {
          // insere informações que não vêm pela API
          produto['NUCONFERENCIA'] = recontagem['conferencia'];
          produto['QUANTIDADE'] = quantidade;
          // pega séries da separação
          series = await Navigator.pushNamed(context, '/recontagem_serial',
              arguments: produto);
          if (series.runtimeType != String || series.isEmpty)
            erro = "Série(s) não informada(s).";
        } else
          series = "";
        if (erro?.isEmpty ?? true) {
          Map<String, dynamic> busca;
          busca = await api.buscaInfoProduto2(
              barcode,
              recontagem['conferencia'],
              quantidade.toDouble(),
              avaria.toDouble());
          if (produto?.isNotEmpty ?? false) {
            Map<String, dynamic> insere;
            // agora envia a recontagem
            insere = await api.envioRecontagem(
                barcode,
                recontagem['conferencia'],
                quantidade.toDouble(),
                avaria.toDouble(),
                recontagem['sequencia'],
                series);
          } else
            erro = api?.getError() ?? "Produto não encontrado.";
        }
      } else
        erro = api?.getError() ?? "Produto não encontrado.";
    }

    changeLoading(false);

    if (erro?.isNotEmpty ?? false) {
      Messagebar.error(erro, context);
      return false;
    } else {
      String msg = "";

      if (api.getStatus() == 0 && api.hasStatusMessage())
        msg = api.getStatusMessage();
      else
        msg = "Item inserido com sucesso.";

      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Recontagem"),
              content: Text(msg),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("Prosseguir"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          });

      print("*** SIMPLESMENTE TERMINA ***");

      // limpa os campos
      this._prodQdeController.text = "";
      this._prodAvariaController.text = "";
      this._produtoController.text = "";

      return true;
    }
  }

  _finalizaRecontagem() async {
    String erro;
    String statusMessage; // não é necessáriamente um erro

    changeLoading(true);

    // verificar se adicionou produtos...
    if (recontagem['conferencia'] == 0) erro = "Doca não foi selecionada.";

    if (erro?.isEmpty ?? true) {
      /*
      var itens = await api.temItensConferidosColetor();
      var busca = await api.buscaInfoProduto3(nuconferencia);
      // produtosConferidos
      bool status;
      status = await api.produtosConferidos(nuconferencia);
      statusMessage = api.getStatusMessage();
      if (status) {
        // originalmente era depois do dialog, mas nao vi necessidade
        await api.removeItensConferidosColetor(nuconferencia);
        if (statusMessage?.isEmpty ?? true)
          statusMessage = "Recontagem processada com sucesso.";
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Recontagem finalizada"),
              content: Text(statusMessage),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else
        erro = api?.getError() ?? "Não foi possível finalizar a recontagem.";
        */
    }

    changeLoading(false);

    if (erro != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Cancelando recontagem"),
              content: Text(erro),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("Fechar"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          });
    }
  }

  Future<bool> _cancelaRecontagem() async {
    String erro;

    if (recontagem['conferencia'] < 1) {
      // se nao tem conferencia em andamento, apenas fecha
      Navigator.of(context).pop(true);
      return true;
    } else {
      var confirma = await _showDialogCancela();
      if (!confirma)
        return false;
      else {
        /*
        changeLoading(true);
        await api.cancelaRecontagem(nuconferencia);
        if (!api.hasError()) {
          await api.removeItensConferidosColetor(nuconferencia);
        } else {
          erro = api.getError();
        }
        changeLoading(false);
        */
      }
    }

    if (erro?.isNotEmpty ?? false) {
      Messagebar.error(erro, context);
      return false;
    } else {
      Navigator.of(context).pop(true);
      return true;
    }
  }

  Future<bool> _showDialogCancela() {
    return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Confirma cancelar a recontagem em andamento?"),
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
