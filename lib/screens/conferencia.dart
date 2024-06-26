import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../stores/form.dart';
import '../widgets/messagebar.dart';
import '../widgets/progress_indicator.dart';
import '../services/api.dart';
import '../services/api_conferencia.dart';

class ConferenciaScreen extends StatefulWidget {
  @override
  _ConferenciaPageState createState() => _ConferenciaPageState();
}

class _ConferenciaPageState extends State<ConferenciaScreen> {
  // número da conferência em andamento
  int nuconferencia = 0;

  TextEditingController _docaController;
  TextEditingController _prodQdeController;
  TextEditingController _prodAvariaController;
  TextEditingController _produtoController;

  final _store = FormStore();

  @override
  initState() {
    _iniciaConferencia();
    super.initState();
    this._docaController = new TextEditingController();
    this._prodQdeController = new TextEditingController();
    this._prodAvariaController = new TextEditingController();
    this._produtoController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _cancelaConferencia,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Conferência"),
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
                    enabled: nuconferencia == 0,
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
                      visible: nuconferencia == 0,
                      child: ElevatedButton(
                        onPressed: () {
                          nuconferencia > 0 ? null : _buscaDoca();
                        },
                        child: const Text('Consultar'),
                      )),
                  Visibility(
                      visible: nuconferencia > 0,
                      child: Column(children: [
                        SizedBox(height: 10.0),
                        Text('Conferir produtos:',
                            style: TextStyle(fontSize: 18)),
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
                            nuconferencia > 0 ? _insereProduto() : null;
                          },
                          child: const Text('Prosseguir'),
                        ),
                      ])),
                  Wrap(children: [
                    ElevatedButton(
                      onPressed: () {
                        _cancelaConferencia();
                      },
                      child: const Text('Cancelar'),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () {
                        _finalizaConferencia();
                      },
                      child: const Text('Finalizar'),
                    ),
                  ]),
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

  Future _iniciaConferencia() async {
    // no futuro vamos entender o que pode acontecer aqui :O
    _store.loading = true;
    await api.temItensConferidosColetor();
    // aqui deve fazer alguma checagem...
    _store.loading = false;
  }

  Future _scanDoca() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      //print('nothing return.');
    } else {
      this._docaController.text = barcode;
      this._buscaDoca();
    }
  }

  _buscaDoca() async {
    String barcode = this._docaController.text;
    String erro = "";

    _store.loading = true;
    if (barcode == "")
      erro = "Precisa informar o endereço.";
    else if (barcode.length < 5) erro = "Endereço inválido.";

    if (erro?.isEmpty ?? true) {
      // faz a busca...
      Map<String, dynamic> doca;
      doca = await api.selecaoDoca(barcode);
      if (doca?.isNotEmpty ?? false) {
        int conferencia = 0;
        conferencia = int.tryParse(doca['NUCONFERENCIA'].toString()) ?? 0;
        _defineDoca(conferencia);
      } else {
        if (api.getStatus() == 0)
          erro = api.getStatusMessage();
        else
          erro = api?.getError() ?? "Doca não encontrada.";
      }
    }

    _store.loading = false;

    if (erro.isNotEmpty)
      Messagebar.error(erro, context);
    else if (nuconferencia > 0)
      Messagebar.success(
          "Doca selecionada, prossiga com a conferência dos produtos.",
          context);
  }

  // define a doca da conferência
  int _defineDoca(int conferencia) {
    if (nuconferencia == 0 && conferencia > 0) {
      setState(() {
        nuconferencia = conferencia;
      });
      return conferencia;
      // TODO: (des)ativa campos/botões
    } else
      return 0;
  }

  Future _scanProduto() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      //print('nothing return.');
    } else {
      this._produtoController.text = barcode;
      this._insereProduto();
    }
  }

  Future<bool> _insereProduto() async {
    int quantidade = int.tryParse(this._prodQdeController?.text) ?? 0;
    int avaria = int.tryParse(this._prodAvariaController?.text) ?? 0;
    String barcode = this._produtoController?.text;
    String erro;

    _store.loading = true;

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
      produto = await api.buscaInfoProduto(nuconferencia, barcode);
      if (produto?.isNotEmpty ?? false) {
        var series;
        if (produto['USASERIESEPWMS'] == 'true') {
          // insere informações que não vêm pela API
          produto['NUCONFERENCIA'] = nuconferencia;
          produto['QUANTIDADE'] = quantidade;
          // pega séries da separação
          series = await Navigator.pushNamed(context, '/conferencia_serial',
              arguments: produto);
          if (series.runtimeType != String || series.isEmpty)
            erro = "Série(s) não informada(s).";
        } else
          series = "";
        if (erro?.isEmpty ?? true) {
          Map<String, dynamic> busca;
          busca = await api.buscaQtdeContadaColetor(barcode, nuconferencia);
          produto = await api.buscaInfoProduto2(
              barcode, nuconferencia, quantidade.toDouble(), avaria.toDouble());
          if (produto?.isNotEmpty ?? false) {
            Map<String, dynamic> insere;
            // agora insere o produto
            insere = await api.insereItemConferidoColetor(
                barcode,
                nuconferencia,
                quantidade.toDouble(),
                avaria.toDouble(),
                series);
          } else
            erro = api?.getError() ?? "Produto não encontrado.";
        }
      } else
        erro = api?.getError() ?? "Produto não encontrado.";
    }

    _store.loading = false;

    if (erro?.isNotEmpty ?? false) {
      Messagebar.error(erro, context);
      return false;
    } else {
      Messagebar.success("Item inserido com sucesso.", context);

      // limpa os campos
      this._prodQdeController.text = "";
      this._prodAvariaController.text = "";
      this._produtoController.text = "";

      return true;
    }
  }

  _finalizaConferencia() async {
    String erro;
    String statusMessage; // não é necessáriamente um erro

    _store.loading = true;

    // verificar se adicionou produtos...
    if (nuconferencia == 0) erro = "Doca não foi selecionada.";

    if (erro?.isEmpty ?? true) {
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
          statusMessage = "Conferência processada com sucesso.";
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Conferência finalizada"),
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
        erro = api?.getError() ?? "Não foi possível finalizar a conferência.";
    }

    _store.loading = false;

    if (erro != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Cancelando conferência"),
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

  Future<bool> _cancelaConferencia() async {
    String erro;

    if (nuconferencia < 1) {
      // se nao tem conferencia em andamento, apenas fecha
      Navigator.of(context).pop(true);
      return true;
    } else {
      var confirma = await _showDialogCancela();
      if (!confirma)
        return false;
      else {
        _store.loading = true;
        await api.cancelaConferencia(nuconferencia);
        if (!api.hasError()) {
          await api.removeItensConferidosColetor(nuconferencia);
        } else {
          erro = api.getError();
        }
        _store.loading = false;
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
              title: Text("Cancelando conferência"),
              content: Text("Confirma cancelar a conferência em andamento?"),
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
