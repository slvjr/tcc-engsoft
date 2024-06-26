import 'dart:async';
import 'package:coletor_digitalsat/services/api.dart';

extension ApiServiceArmazenagem on ApiService {
  Future<Map<String, dynamic>> buscaFuncao(String usuario, String senha) async {
    String _body = '<NOMUSU>$usuario</NOMUSU><INTERNO>$senha</INTERNO>';

    String _response = await this.service('MgeWmsSP.buscaFuncao', _body);

    if (_response != null) {
      Map<String, dynamic> attributes = {};
      return attributes;
    }
    return null;
  }
}
