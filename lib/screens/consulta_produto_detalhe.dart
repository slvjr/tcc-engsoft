import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
//import '../models/produto.dart';
//import '../models/produto_estoque.dart';
import '../stores/form.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/badge_active.dart';
import '../services/api.dart';
import '../services/api_consulta.dart';

class ConsultaProdutoDetalheScreen extends StatefulWidget {
  @override
  _ConsultaProdutoDetalhePageState createState() =>
      _ConsultaProdutoDetalhePageState();
}

class _ConsultaProdutoDetalhePageState
    extends State<ConsultaProdutoDetalheScreen> {
  double get randHeight => Random().nextInt(100).toDouble();

  final _store = FormStore();

  int _codprod;
  Map _produto;
  List<Map> _estoque = [];
  List<Map> _endereco = [];

  @override
  Widget build(BuildContext context) {
    List args = ModalRoute.of(context).settings.arguments;
    _codprod = args.first;

    if (_produto == null) _loadProduto();

    return Scaffold(
      // Persistent AppBar that never scrolls
      appBar: AppBar(
        title: Text('Consulta produto - detalhe'),
        elevation: 0.0,
      ),
      body: Stack(children: [
        DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) {
              return [
                SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    Container(
                      child:
                          null, // aqui vai uma mensagem que sobe com o scroll
                    ),
                  ]),
                ),
              ];
            },
            body: Column(
              children: <Widget>[
                Card(
                    child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                            _produto == null ? "" : _produto['DESCRPROD'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)))),
                TabBar(
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(color: Colors.red, width: 4),
                    insets: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  labelColor: Colors.black,
                  tabs: [
                    Tab(text: 'Detalhes'),
                    Tab(text: 'Estoque'),
                    Tab(text: 'Endereço'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _createDetailsView(),
                      _createStockView(),
                      _createEnderecoView(),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _createDetailsView() {
    return ListView(children: <Widget>[
      DataTable(
        headingRowHeight: 0,
        columns: <DataColumn>[
          DataColumn(
            label: Text(''),
          ),
          DataColumn(
            label: Text(''),
          ),
        ],
        rows: <DataRow>[
          DataRow(
            cells: <DataCell>[
              DataCell(Text('Código')),
              DataCell(
                  Text(_produto == null ? "" : _produto['CODPROD'].toString())),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(Text('Marca:')),
              DataCell(Text(_produto == null ? "" : _produto['MARCA'])),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(Text('Referência')),
              DataCell(Text(_produto == null ? "" : _produto['REFFORN'])),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(Text('Ativo')),
              DataCell(
                  buildBadgeActive(_produto == null ? "" : _produto['ATIVO']))
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(Text('Cód. barras:')),
              DataCell(Text(_produto == null ? "" : _produto['REFERENCIA'])),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(Text('Unidade:')),
              DataCell(Text(_produto == null ? "" : _produto['CODVOL'])),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(Text('Preço:')),
              DataCell(Text(_produto == null
                  ? ""
                  : NumberFormat.currency(locale: 'pt_BR', name: 'R\$')
                      .format(_produto['PRECO']))),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(Text('Foto:')),
              DataCell(
                  _produto == null || _produto['IMAGEM'].isEmpty
                      ? buildBadgeActive("Não")
                      : buildBadgeActive("Abrir"), onTap: () {
                if (_produto != null) {
                  Navigator.pushNamed(context, '/consulta_produto_imagem',
                      arguments: [_produto['CODPROD'], _produto['DESCRPROD']]);
                }
              }),
            ],
          ),
          /*
          DataRow(r
            cells: <DataCell>[
              DataCell(Text('Imagem:')),
              DataCell(Text(prod.imagem)),
            ],
          ),
          */
        ],
      ),
      SizedBox(height: 240.0),
    ]);
  }

  Widget _createStockView() {
    return ListView(children: <Widget>[
      DataTable(
        columns: <DataColumn>[
          DataColumn(
            label: Text(
              'Local',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Quantidade',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Reservado',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        rows: _estoque
            .map(
              (row) => DataRow(cells: [
                DataCell(RichText(
                  text: TextSpan(
                    text: row['RAZAOABREV'],
                    style: TextStyle(color: Colors.black),
                    //style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                          text: "\n" + row['DESCRLOCAL'],
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic)),
                    ],
                  ),
                )),
                DataCell(
                  Center(
                      child: Text(
                    row['ESTOQUE'].toString(),
                  )),
                ),
                DataCell(
                  Center(
                      child: Text(
                    row['RESERVADO'].toString(),
                  )),
                ),
              ]),
            )
            .toList(),
      ),
      SizedBox(height: 240.0),
    ]);
  }

  Widget _createEnderecoView() {
    return ListView(children: <Widget>[
      DataTable(
        columns: <DataColumn>[
          DataColumn(
            label: Text(
              'Empresa',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Endereço',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        rows: _endereco
            .map(
              (row) => DataRow(cells: [
                DataCell(RichText(
                  text: TextSpan(
                    text: row['RAZAOABREV'],
                    style: TextStyle(color: Colors.black),
                    //style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                          text: "\n1000",
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic)),
                    ],
                  ),
                )),
                DataCell(
                  //Center(child:
                  Text(
                    row['ENDERECO'],
                  ),
                  //),
                ),
              ]),
            )
            .toList(),
      ),
      SizedBox(height: 240.0),
    ]);
  }

  _loadProduto() async {
    _store.loading = true;
    _produto = await api.consultaProduto(_codprod);
    _estoque = await api.consultaProdutoEstoque(_codprod);
    _endereco = await api.consultaProdutoEndereco(_codprod);
    setState(() {});
    _store.loading = false;

    if (_produto == null) _showDialogFecha();
  }

  _showDialogFecha() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Atenção"),
          content: Text("Produto não encontrado."),
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
}
