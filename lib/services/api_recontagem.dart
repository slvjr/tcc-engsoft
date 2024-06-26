import 'dart:async';
import 'package:xml/xml.dart';
import 'package:coletor_digitalsat/services/api.dart';

extension ApiServiceRecontagem on ApiService {
  Future<Map<String, dynamic>> buscaInfoRecontagem(String endereco) async {
    Map<String, dynamic> attributes = {};
    String _body = '<ENDERECO>$endereco</ENDERECO>';

    String _response =
        await this.service('MgeWmsSP.buscaInfoRecontagem', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      linha.attributes.forEach((e) {
        attributes[e.name.toString()] = e.value;
      });
    }
    return attributes;
  }

  Future<Map<String, dynamic>> recontagemDoca(String endereco) async {
    Map<String, dynamic> attributes = {};
    String _body = '<idusu>{idBase64}</idusu>' +
        '<ENDERECO>$endereco</ENDERECO>' +
        '<tipoConferencia>QUALQUER</tipoConferencia>';

    String _response = await this.service('MgeWmsSP.recontagemDoca', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      linha.attributes.forEach((e) {
        attributes[e.name.toString()] = e.value;
      });
    }
    return attributes;
  }

  Future<Map<String, dynamic>> proximaRecontagem(
      int conferencia, int tarefa, int endereco) async {
    Map<String, dynamic> attributes = {};
    String _body = '<idusu>{idBase64}</idusu>' +
        '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<NUTAREFA>$tarefa</NUTAREFA>' +
        '<CODEND>$endereco</CODEND>' +
        '<tipoConferencia>QUALQUER</tipoConferencia>';

    String _response = await this.service('MgeWmsSP.proximaRecontagem', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      linha.attributes.forEach((e) {
        attributes[e.name.toString()] = e.value;
      });
    }
    return attributes;
  }

  Future<Map<String, dynamic>> buscaInfoProduto(
      String codigo, int conferencia, int quantidade) async {
    Map<String, dynamic> attributes = {};
    String _body = '<idusu>{idBase64}</idusu>' +
        '<CODBARRAS>$codigo</CODBARRAS>' +
        '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<QUANTIDADE>$quantidade</QUANTIDADE>' +
        '<PRIMEIRARECONTAGEM>false</PRIMEIRARECONTAGEM>';

    String _response = await this.service('MgeWmsSP.buscaInfoProduto', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      linha.attributes.forEach((e) {
        attributes[e.name.toString()] = e.value;
      });
    }
    return attributes;
  }

  Future<Map<String, dynamic>> buscaInfoProduto2(
      String codigo, int conferencia, double quantidade, double avaria) async {
    Map<String, dynamic> attributes = {};
    String _body = '<idusu>{idBase64}</idusu>' +
        '<VALIDARQTD>true</VALIDARQTD>' +
        '<considerarLeituraCorrente>true</considerarLeituraCorrente>' +
        '<CODBARRAS>$codigo</CODBARRAS>' +
        '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<QUANTIDADE>$quantidade</QUANTIDADE>' +
        '<QTDAVARIA>$avaria</QTDAVARIA>' +
        '<LOTE></LOTE>' +
        '<UTILIZAEXPLOTE>false</UTILIZAEXPLOTE>';

    String _response = await this.service('MgeWmsSP.buscaInfoProduto', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      linha.attributes.forEach((e) {
        attributes[e.name.toString()] = e.value;
      });
    }
    return attributes;
  }

  Future<bool> validaUnicidadeSerieSeparacao(
      int conferencia, String produto, String serie) async {
    String _body = '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<CODBARRASPROD>$produto</CODBARRASPROD>' +
        '<NROSERIE>$serie</NROSERIE>';

    String _response =
        await this.service('MgeWmsSP.validaUnicidadeSerieSeparacao', _body);

    if (_response != null)
      return true;
    else
      return false;
  }

  Future<Map<String, dynamic>> envioRecontagem(String codbarra, int conferencia,
      double quantidade, double avaria, int sequencia,
      [String series]) async {
    String xmlSeries = "";
    if (series?.isNotEmpty ?? false) xmlSeries = "<SERIES>$series</SERIES>";
    String _body = '<idusu>{idBase64}</idusu>' +
        '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<SEQUENCIA>1</SEQUENCIA>' +
        '<NUTAREFA>995</NUTAREFA>' +
        '<CODBARRAS>$codbarra</CODBARRAS>' +
        '<QUANTIDADE>$quantidade</QUANTIDADE>' +
        '<FUNCAORECPECA>false</FUNCAORECPECA>' +
        '<QTDPECAS>0</QTDPECAS>' +
        '<TIPOREC>NORMAL</TIPOREC>' +
        '<QTDAVARIA>$avaria</QTDAVARIA>' +
        '<CONTROLE> </CONTROLE>' +
        '<DTVAL> </DTVAL>' +
        '<UTILIZAEXPLOTE>false</UTILIZAEXPLOTE>' +
        '<CODBARRASCONCATWMS></CODBARRASCONCATWMS>' +
        '<PRIMEIRARECONTAGEM>false</PRIMEIRARECONTAGEM>' +
        '<RECRIAVOLPOSREC>false</RECRIAVOLPOSREC>';
    xmlSeries;

    String _response = await this.service('MgeWmsSP.envioRecontagem', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      Map<String, dynamic> attributes = {
        'MENSAGEM': int.parse(linha.getAttribute('MENSAGEM')),
        'SEQUENCIA': int.parse(linha.getAttribute('SEQUENCIA')),
      };
      return attributes;
    }
    return null;
  }
}
