import 'dart:async';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'package:coletor_digitalsat/services/api.dart';

extension ApiServiceInventario on ApiService {
  Future<Map<String, dynamic>> consultaProduto(String barcode) async {
    String _body = '''
<query viewName="AD_VIEW_TGFCTE_CONTAGEM_PROD" orderBy="CODPROD">
   <fields>
    <field>CODPROD</field>
    <field>DESCRPROD</field>
    <field>MARCA</field>
    <field>UNIDADE</field>
    <field>ATIVO</field>
    <field>RUA</field>
    <field>PREDIO</field>
    <field>ANDAR</field>
   </fields>
   <where>REGEXP_LIKE(REFERENCIA, '^$barcode\$', 'i')</where>
</query>''';

    String _response =
        await this.service('CRUDServiceProvider.loadView', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      int qde = document.findAllElements('record').length;
      if (qde < 1)
        this.setError('Produto não encontrado.');
      else if (qde > 1)
        this.setError('Mais de um produto encontrado.');
      else {
        Map<String, dynamic> product = {
          'CODPROD': int.parse(document.findAllElements('CODPROD').first.text),
          'DESCRPROD': document.findAllElements('DESCRPROD').first.text,
          'MARCA': document.findAllElements('MARCA').first.text,
          'UNIDADE': document.findAllElements('UNIDADE').first.text,
          'ATIVO': document.findAllElements('ATIVO').first.text,
          'RUA': document.findAllElements('RUA').first.text,
          'PREDIO': document.findAllElements('PREDIO').first.text,
          'ANDAR': document.findAllElements('ANDAR').first.text,
        };
        return product;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> consultaProdutoCod(int codigo) async {
    String _body = '''
<query viewName="AD_VIEW_TGFCTE_CONTAGEM_PROD" orderBy="CODPROD">
   <fields>
    <field>CODPROD</field>
    <field>DESCRPROD</field>
    <field>MARCA</field>
    <field>UNIDADE</field>
    <field>ATIVO</field>
    <field>RUA</field>
    <field>PREDIO</field>
    <field>ANDAR</field>
   </fields>
   <where>CODPROD = ${codigo.toString()}</where>
</query>''';

    String _response =
        await this.service('CRUDServiceProvider.loadView', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      //var linha = document.findAllElements('linha').first;
      int qde = document.findAllElements('record').length;
      if (qde < 1)
        this.setError('Produto não encontrado.');
      else if (qde > 1)
        this.setError('Mais de um produto encontrado.');
      else {
        Map<String, dynamic> product = {
          'CODPROD': int.parse(document.findAllElements('CODPROD').first.text),
          'DESCRPROD': document.findAllElements('DESCRPROD').first.text,
          'MARCA': document.findAllElements('MARCA').first.text,
          'UNIDADE': document.findAllElements('UNIDADE').first.text,
          'ATIVO': document.findAllElements('ATIVO').first.text,
          'RUA': document.findAllElements('RUA').first.text,
          'PREDIO': document.findAllElements('PREDIO').first.text,
          'ANDAR': document.findAllElements('ANDAR').first.text,
        };
        return product;
      }
    }
    return null;
  }

  Future<int> insereContagem(int codprod, int qtdest) async {
    String dtcontagem = DateFormat('dd/MM/yyyy').format(DateTime.now());
    String datahora = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    print(datahora);
    String _body = '''
<dataSet rootEntity="AD_TGFCTE" includePresentationFields="S"  datasetid="1444487520009_1">
  <entity path="">
    <fieldset list="*"/>
  </entity>
  <dataRow>
    <localFields>
      <DTCONTAGEM>$dtcontagem</DTCONTAGEM>
      <CODPROD>$codprod</CODPROD>
      <CODUSU>{idUsu}</CODUSU>
      <QTDEST>$qtdest</QTDEST>
      <DATAHORA>$datahora</DATAHORA>
    </localFields>
  </dataRow>
</dataSet>''';

    String _response =
        await this.service('CRUDServiceProvider.saveRecord', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      int codigo = int.parse(document.findAllElements('CODIGO').first.text);
      if (codigo > 0) return codigo;
    }
    return 0;
  }

  /////
  /// Atualiza localização do produto
  /// TODO: dinamizar a empresa, está fixo 9
  Future<int> atualizaLocalizacao(
      int codprod, String rua, String predio, String andar) async {
    String _body = '''
<dataSet rootEntity="AD_LOCALIZACAO">
  <entity>
    <fieldset/>
    <field/>
  </entity>
  <dataRow>
    <localFields>
      <RUA>$rua</RUA>
      <PREDIO>$predio</PREDIO>
      <ANDAR>$andar</ANDAR>
    </localFields>
    <key>
      <CODPROD>${codprod.toString()}</CODPROD>
      <CODEMP>1</CODEMP>
    </key>
  </dataRow>
</dataSet>''';
    String _response =
        await this.service('CRUDServiceProvider.saveRecord', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      int qde = int.parse(document
          .findAllElements('entities')
          .first
          .getAttributeNode('total')
          .value);
      if (qde > 0) return qde;
    }
    return 0;
  }

  /////
  // Carrega os endereços que tem recontagem pendente
  Future<List<String>> carregaEnderecos() async {
    List<String> ruas = [];
    String _body = '''
<query viewName="AD_VIEW_TGFCTE_RECONTAGEM_RUA" orderBy="RUA">
   <fields>
    <field>RUA</field>
   </fields>
   <where></where>
</query>''';

    String _response =
        await this.service('CRUDServiceProvider.loadView', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      document.findAllElements('RUA').forEach((element) {
        ruas.add(element.text);
      });
    }
    return ruas;
  }

  /////
  // Carrega o próximo produto com recontagem marcada
  carregaProxRecontagem(String endereco) async {
    Map<String, dynamic> produto;
    String _body = '''
<query viewName="AD_VIEW_TGFCTE_RECONTAGEM_PROD">
  <fields>
    <field>CODPROD</field>
    <field>DESCRPROD</field>
    <field>REFERENCIA</field>
    <field>MARCA</field>
    <field>UNIDADE</field>
    <field>ENDERECO</field>
  </fields>
  <where>RUA = '$endereco'</where>
</query>''';
    String _response =
        await this.service('CRUDServiceProvider.loadView', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      if (document.findAllElements('CODPROD').isNotEmpty) {
        produto = {
          'CODPROD': int.parse(document.findAllElements('CODPROD').first.text),
          'DESCRPROD': document.findAllElements('DESCRPROD').first.text,
          'REFERENCIA': document.findAllElements('REFERENCIA').first.text,
          'MARCA': document.findAllElements('MARCA').first.text,
          'UNIDADE': document.findAllElements('UNIDADE').first.text,
          'ENDERECO': document.findAllElements('ENDERECO').first.text,
        };
      }
    }
    return produto;
  }
}
