import 'dart:async';
import 'package:xml/xml.dart';
import 'package:coletor_digitalsat/services/api.dart';
import 'package:coletor_digitalsat/constants/config.dart';

extension ApiServiceArmazenagem on ApiService {
  Future<Map<String, dynamic>> buscaUltimaTarefaExecucaoColetor() async {
    String _body = '<idusu>{idBase64}</idusu>';

    String _response =
        await this.service('MgeWmsSP.buscaUltimaTarefaExecucaoColetor', _body);

    if (_response != null) {
      Map<String, dynamic> attributes = {};
      return attributes;
    }
    return null;
  }

  Future<Map<String, dynamic>> removeTarefaExecucaoColetor() async {
    String _body = '<idusu>{idBase64}</idusu>' +
        '<TAREFA>' +
        '<NUTAREFA>0</NUTAREFA>' +
        '<SEQUENCIATAREFA>0</SEQUENCIATAREFA>' +
        '<SITUACAO>E</SITUACAO>' +
        '</TAREFA>';

    String _response =
        await this.service('MgeWmsSP.removeTarefaExecucaoColetor', _body);

    if (_response != null) {
      Map<String, dynamic> attributes = {};
      return attributes;
    }
    return null;
  }

  Future<Map<String, dynamic>> buscaTarefa(int tipo) async {
    Map<String, dynamic> attributes = {};

    String _body = '<idusu>{idBase64}</idusu>' +
        '<CODTAREFA>$tipo</CODTAREFA>' +
        '<CODEQUIP>${Config.equipCodigo}</CODEQUIP>';

    String _response = await this.service('MgeWmsSP.buscaTarefa', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      linha.attributes.forEach((e) {
        // vai do C1 ao C49
        attributes[e.name.toString()] = e.value;
      });
    }
    return attributes;
  }

  Future<Map<String, dynamic>> marcaTarefaEmTransito(
      int tarefa, int sequencia, String produto) async {
    Map<String, dynamic> attributes = {};

    String _body = '<idusu>{idBase64}</idusu>' +
        '<NUTAREFA>$tarefa</NUTAREFA>' +
        '<SEQUENCIA>$sequencia</SEQUENCIA>' +
        '<QTDPEGACONEX>0.0</QTDPEGACONEX>' +
        '<CODBARRAPROD>$produto</CODBARRAPROD>';

    String _response =
        await this.service('MgeWmsSP.marcaTarefaEmTransito', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      linha.attributes.forEach((e) {
        attributes[e.name.toString()] = e.value;
      });
    }
    return attributes;
  }

  Future<Map<String, dynamic>> envioTarefa() async {
    Map<String, dynamic> attributes = {};

    String _body =
        '<idusu>{idBase64}</idusu>' + '<USAEXPLOTESEP>false</USAEXPLOTESEP>';

    await this.service('MgeWmsSP.envioTarefa', _body);

    return attributes;
  }

  Future<Map<String, dynamic>> rejeitaTarefa(int tarefa, int sequencia) async {
    Map<String, dynamic> attributes = {};

    String _body = '<idusu>{idBase64}</idusu>' +
        '<TAREFA>' +
        '<NUTAREFA>$tarefa</NUTAREFA>' +
        '<SEQUENCIA>$sequencia</SEQUENCIA>' +
        '</TAREFA>';

    await this.service('MgeWmsSP.rejeitaTarefa', _body);

    return attributes;
  }
}
