import 'package:flutter/material.dart';
import 'screens/splash.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/consulta_produto.dart';
import 'screens/consulta_produto_detalhe.dart';
import 'screens/consulta_produto_imagem.dart';
import 'screens/conferencia.dart';
import 'screens/conferencia_serial.dart';
import 'screens/recontagem.dart';
import 'screens/recontagem_serial.dart';
import 'screens/armazenagem.dart';
import 'screens/separacao.dart';
import 'screens/reabastecimento.dart';
import 'screens/inventario_contagem.dart';
import 'screens/inventario_recontagem.dart';
import 'screens/configuracoes.dart';

class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String consulta_produto = '/consulta_produto';
  static const String consulta_produto_detalhe = '/consulta_produto_detalhe';
  static const String consulta_produto_imagem = '/consulta_produto_imagem';
  static const String conferencia = '/conferencia';
  static const String conferencia_serial = '/conferencia_serial';
  static const String recontagem = '/recontagem';
  static const String recontagem_serial = '/recontagem_serial';
  static const String armazenagem = '/armazenagem';
  static const String separacao = '/separacao';
  static const String reabastecimento = '/reabastecimento';
  static const String inventario_contagem = '/inventario_contagem';
  static const String inventario_recontagem = '/inventario_recontagem';
  static const String configuracoes = '/configuracoes';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    consulta_produto: (BuildContext context) => ConsultaProdutoScreen(),
    consulta_produto_detalhe: (BuildContext context) =>
        ConsultaProdutoDetalheScreen(),
    consulta_produto_imagem: (BuildContext context) =>
        ConsultaProdutoImagemScreen(),
    conferencia: (BuildContext context) => ConferenciaScreen(),
    conferencia_serial: (BuildContext context) => ConferenciaSerialScreen(),
    recontagem: (BuildContext context) => RecontagemScreen(),
    recontagem_serial: (BuildContext context) => RecontagemSerialScreen(),
    armazenagem: (BuildContext context) => ArmazenagemScreen(),
    separacao: (BuildContext context) => SeparacaoScreen(),
    reabastecimento: (BuildContext context) => ReabastecimentoScreen(),
    inventario_contagem: (BuildContext context) => InventarioContagemScreen(),
    inventario_recontagem: (BuildContext context) =>
        InventarioRecontagemScreen(),
    configuracoes: (BuildContext context) => ConfiguracoesScreen(),
  };
}
