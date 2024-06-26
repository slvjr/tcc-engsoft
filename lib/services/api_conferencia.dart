import 'dart:async';
import 'package:xml/xml.dart';
import 'package:coletor_digitalsat/services/api.dart';

extension ApiServiceConferencia on ApiService {
  Future<Map<String, dynamic>> selecaoDoca(String endereco) async {
    String _body = '<idusu>{idBase64}</idusu>' +
        '<ENDERECO>' +
        endereco +
        '</ENDERECO>' +
        '<MULTICONFERENTES>false</MULTICONFERENTES>' +
        '<tipoConferencia>QUALQUER</tipoConferencia>' +
        '<verificarNroPalete>false</verificarNroPalete>';

    String _response = await this.service('MgeWmsSP.selecaoDoca', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      //print(document.findAllElements('linha').first.attributes);
      Map<String, dynamic> attributes = {
        'NUCONFERENCIA': int.parse(linha.getAttribute('NUCONFERENCIA')),
        'UTILIZACONTROLE': linha.getAttribute('UTILIZACONTROLE'),
        'TIPCONF': linha.getAttribute('TIPCONF'),
        'DEVOLUCAO': linha.getAttribute('DEVOLUCAO'),
      };
      return attributes;
    }
    return null;
  }

  Future<Map<String, dynamic>> buscaInfoProduto(int conferencia,
      [String produto, double quantidade, double avaria]) async {
    print(produto);
    print(quantidade);
    String _body = '<idusu>{idBase64}</idusu>' +
        '<CODBARRAS>$produto</CODBARRAS>' +
        '<CONFPARCIAL>false</CONFPARCIAL>' +
        '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<MULTICONFERENTES>false</MULTICONFERENTES>';

    String _response = await this.service('MgeWmsSP.buscaInfoProduto', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      //print(document.findAllElements('linha').first.attributes);
      Map<String, dynamic> attributes = {
        'CODPROD': linha.getAttribute('CODPROD'),
        'CODBARRAS': linha.getAttribute('CODBARRAS'),
        'DESCRPROD': linha.getAttribute('DESCRPROD'),
        'UTILIZALOTE': linha.getAttribute('UTILIZALOTE'),
        'SHELFLIFE': linha.getAttribute('SHELFLIFE'),
        'DTSERVIDOR': linha.getAttribute('DTSERVIDOR'),
        'PRODUTOOUTROPEDIDO': linha.getAttribute(
            'PRODUTOOUTROPEDIDO'), // 'N'=faz parte do pedido atual, 'S'=não do atual
        'DIVERGENCIA': linha.getAttribute('DIVERGENCIA'),
        'QTDECANCELADA': linha.getAttribute('QTDECANCELADA'),
        'CODVOLQTDCANCELADA': linha.getAttribute('CODVOLQTDCANCELADA'),
        'NUCONFERENCIA': int.parse(linha.getAttribute('NUCONFERENCIA')),
        'CONFENTRADA': linha.getAttribute('CONFENTRADA'),
        'TEMITENSACONFERIR': linha.getAttribute('TEMITENSACONFERIR'),
        'USASERIESEPWMS': linha.getAttribute('USASERIESEPWMS'),
        'INFOCAMPOADEND': linha.getAttribute('INFOCAMPOADEND'),
        'USAVOLUMECONTINUO': linha.getAttribute('USAVOLUMECONTINUO'),
        'NORMAPALETIZACAO': linha.getAttribute('NORMAPALETIZACAO'),
      };
      return attributes;
    }
    return null;
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

  Future<Map<String, dynamic>> buscaInfoProduto2(
      String codigo, int conferencia, double quantidade, double avaria) async {
    String _body = '<idusu>{idBase64}</idusu>' +
        '<VALIDARQTD>true</VALIDARQTD>' +
        '<considerarLeituraCorrente>true</considerarLeituraCorrente>' +
        '<CODBARRAS>$codigo</CODBARRAS>' +
        '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<QUANTIDADE>$quantidade</QUANTIDADE>' +
        '<QTDAVARIA>$avaria</QTDAVARIA>' +
        '<LOTE></LOTE>' +
        '<DTVALIDADE></DTVALIDADE>' +
        '<CONFPARCIAL>false</CONFPARCIAL>' +
        '<UTILIZAEXPLOTE>false</UTILIZAEXPLOTE>';

    String _response = await this.service('MgeWmsSP.buscaInfoProduto', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      //print(document.findAllElements('linha').first.attributes);
      Map<String, dynamic> attributes = {
        'CODPROD': linha.getAttribute('CODPROD'),
        'CODBARRAS': linha.getAttribute('CODBARRAS'),
        'DESCRPROD': linha.getAttribute('DESCRPROD'),
        'UTILIZALOTE': linha.getAttribute('UTILIZALOTE'),
        'SHELFLIFE': linha.getAttribute('SHELFLIFE'),
        'DTSERVIDOR': linha.getAttribute('DTSERVIDOR'),
        'PRODUTOOUTROPEDIDO': linha.getAttribute(
            'PRODUTOOUTROPEDIDO'), // 'N'=faz parte do pedido atual, 'S'=não do atual
        'DIVERGENCIA': linha.getAttribute('DIVERGENCIA'),
        'QTDECANCELADA': linha.getAttribute('QTDECANCELADA'),
        'CODVOLQTDCANCELADA': linha.getAttribute('CODVOLQTDCANCELADA'),
        'NUCONFERENCIA': int.parse(linha.getAttribute('NUCONFERENCIA')),
        'CONFENTRADA': linha.getAttribute('CONFENTRADA'),
        'TEMITENSACONFERIR': linha.getAttribute('TEMITENSACONFERIR'),
        'USASERIESEPWMS': linha.getAttribute('USASERIESEPWMS'),
        'INFOCAMPOADEND': linha.getAttribute('INFOCAMPOADEND'),
        'USAVOLUMECONTINUO': linha.getAttribute('USAVOLUMECONTINUO'),
        'NORMAPALETIZACAO': linha.getAttribute('NORMAPALETIZACAO'),
      };
      return attributes;
    }
    return null;
  }

  Future<Map<String, dynamic>> buscaInfoProduto3(int conferencia) async {
    String _body = '<VALIDARQTD>true</VALIDARQTD>' +
        '<CONFPARCIAL>false</CONFPARCIAL>' +
        '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<UTILIZAEXPLOTE>false</UTILIZAEXPLOTE>' +
        '<MULTICONFERENTES>false</MULTICONFERENTES>' +
        '<idusu>{idBase64}</idusu>';

    String _response = await this.service('MgeWmsSP.buscaInfoProduto', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      //print(document.findAllElements('linha').first.attributes);
      Map<String, dynamic> attributes = {
        'CODPROD': linha.getAttribute('CODPROD'),
        'CODBARRAS': linha.getAttribute('CODBARRAS'),
        'DESCRPROD': linha.getAttribute('DESCRPROD'),
        'UTILIZALOTE': linha.getAttribute('UTILIZALOTE'),
        'SHELFLIFE': linha.getAttribute('SHELFLIFE'),
        'DTSERVIDOR': linha.getAttribute('DTSERVIDOR'),
        'PRODUTOOUTROPEDIDO': linha.getAttribute(
            'PRODUTOOUTROPEDIDO'), // 'N'=faz parte do pedido atual, 'S'=não do atual
        'DIVERGENCIA': linha.getAttribute('DIVERGENCIA'),
        'QTDECANCELADA': linha.getAttribute('QTDECANCELADA'),
        'CODVOLQTDCANCELADA': linha.getAttribute('CODVOLQTDCANCELADA'),
        'NUCONFERENCIA': int.parse(linha.getAttribute('NUCONFERENCIA')),
        'CONFENTRADA': linha.getAttribute('CONFENTRADA'),
        'TEMITENSACONFERIR': linha.getAttribute('TEMITENSACONFERIR'),
        'USASERIESEPWMS': linha.getAttribute('USASERIESEPWMS'),
        'INFOCAMPOADEND': linha.getAttribute('INFOCAMPOADEND'),
        'USAVOLUMECONTINUO': linha.getAttribute('USAVOLUMECONTINUO'),
        'NORMAPALETIZACAO': linha.getAttribute('NORMAPALETIZACAO'),
      };
      return attributes;
    }
    return null;
  }

  Future<Map<String, dynamic>> buscaQtdeContadaColetor(
      String codigo, int conferencia) async {
    String _body = '<idusu>{idBase64}</idusu>' +
        '<CONFERENCIA>' +
        '<CODBARRA>$codigo</CODBARRA>' +
//        '<CONFPARCIAL>false</CONFPARCIAL>' +
        '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<CONTROLE> </CONTROLE>' +
        '</CONFERENCIA>';

    String _response =
        await this.service('MgeWmsSP.buscaQtdeContadaColetor', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
      //print(document.findAllElements('linha').first.attributes);
      Map<String, dynamic> attributes = {
        'NUCONFERENCIA': int.parse(linha.getAttribute('NUCONFERENCIA')),
        'CODBARRA': linha.getAttribute('CODBARRA'),
        'CONTROLE': linha.getAttribute('CONTROLE'),
        'QUANTIDADE': int.parse(linha.getAttribute('QUANTIDADE')),
        'QTDAVARIA': int.parse(linha.getAttribute('QTDAVARIA')),
      };
      return attributes;
    }
    return null;
  }

  Future<Map<String, dynamic>> insereItemConferidoColetor(
      String codbarra, int conferencia, double quantidade, double avaria,
      [String series]) async {
    String xmlSeries = "";
    if (series?.isNotEmpty ?? false) xmlSeries = "<SERIES>$series</SERIES>";
    String _body = '<idusu>{idBase64}</idusu>' +
        '<CONFERENCIA>' +
        '<CODBARRA>$codbarra</CODBARRA>' +
        '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<CONTROLE> </CONTROLE>' +
        '<DTVALIDADE></DTVALIDADE>' +
        '<DTFABRICACAO></DTFABRICACAO>' +
        '<QUANTIDADE>$quantidade</QUANTIDADE>' +
        '<QTDAVARIA>$avaria</QTDAVARIA>' +
        '<QTDPECAS>0</QTDPECAS>' +
        '<VOLCONTINUO>null</VOLCONTINUO>' +
        xmlSeries +
        '</CONFERENCIA>';

    String _response =
        await this.service('MgeWmsSP.insereItemConferidoColetor', _body);

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

  Future<Map<String, dynamic>> temItensConferidosColetor() async {
    String _body = '<idusu>{idBase64}</idusu>';

    String _response =
        await this.service('MgeWmsSP.temItensConferidosColetor', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha');
      if (linha.isNotEmpty) {
        Map<String, dynamic> attributes = {
          'NUCONFERENCIA': linha.first.getAttribute('NUCONFERENCIA'),
        };
        return attributes;
      }
    }
    return null;
  }

  Future<bool> cancelaConferencia(int conferencia) async {
    String _body = '<idusu>{idBase64}</idusu>' +
        '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<MULTICONFERENTES>false</MULTICONFERENTES>';

    //String _response =
    await this.service('MgeWmsSP.cancelaConferencia', _body);

    return (!this.hasError());
  }

  Future<bool> removeItensConferidosColetor(int conferencia) async {
    String _body = '<idusu>{idBase64}</idusu>' +
        '<CONFERENCIA>' +
        '<NUCONFERENCIA>$conferencia</NUCONFERENCIA>' +
        '<REMOVERSERIES>false</REMOVERSERIES>' +
        '</CONFERENCIA>';

    //String _response =
    await this.service('MgeWmsSP.removeItensConferidosColetor', _body);

    return (!this.hasError());
  }

  Future<bool> produtosConferidos(int conferencia) async {
    String _body = '<idusu>{idBase64}</idusu>' +
        '<nuConferencia>$conferencia</nuConferencia>' +
        '<tipoConferencia>QUALQUER</tipoConferencia>' +
        '<UTILIZAEXPLOTE>false</UTILIZAEXPLOTE>' +
        '<MULTICONFERENTES>false</MULTICONFERENTES>' +
        '<PREFERENCIANOTIFDIVFINAL>false</PREFERENCIANOTIFDIVFINAL>' +
        '<finalizarConferenciaParcial>true</finalizarConferenciaParcial>';

    String _response = await this.service('MgeWmsSP.produtosConferidos', _body);

    print(_response);

    return (!this.hasError());
  }
}
