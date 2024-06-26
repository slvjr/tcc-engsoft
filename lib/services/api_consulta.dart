import 'dart:async';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'package:coletor_digitalsat/services/api.dart';

extension ApiServiceConsulta on ApiService {
  Future<List<Map<String, dynamic>>> pesquisaProduto(String barcode) async {
    String _body = '''
<dataSet rootEntity="Produto" includePresentationFields="S" parallelLoader="false" disableRowsLimit="false" orderByExpression="this.CODPROD">
  <entity path="">
    <fieldset list="CODPROD, DESCRPROD, MARCA, REFERENCIA, ATIVO"/>
  </entity>
  <criteria>
    <expression>this.CODPROD LIKE '$barcode' OR REGEXP_LIKE(this.REFERENCIA, '^$barcode\$', 'i') OR REGEXP_LIKE(this.DESCRPROD, \'''' +
        barcode.replaceAll(' ', '.*') +
        '''\', 'i')</expression>
  </criteria>
</dataSet>''';

    String _response =
        await this.service('CRUDServiceProvider.loadRecords', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      //var linha = document.findAllElements('linha').first;
      int qde = int.parse(document
          .findAllElements('entities')
          .first
          .getAttributeNode('total')
          .value);
      if (qde == 0)
        this.setError('Produto não encontrado.');
      else {
        List<Map<String, dynamic>> product = [];
        final entity = document.findAllElements('entity');
        if (entity.isNotEmpty)
          entity.forEach((element) {
            product.add({
              'CODPROD': int.parse(element.getElement('f0').text),
              'DESCRPROD': element.getElement('f1').text,
              'MARCA': element.getElement('f2').text,
              'REFERENCIA': element.getElement('f3').text,
              'ATIVO': element.getElement('f4').text,
            });
          });
        return product;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> consultaProduto(int codigo) async {
    String _body = '''
<query viewName="AD_VIEW_WMS_CONSULTAPRODUTO" orderBy="DESCRPROD">
<where>CODPROD = $codigo</where>
</query>
''';

    String _response =
        await this.service('CRUDServiceProvider.loadView', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      if (document.findAllElements('records').isEmpty)
        this.setError('Produto não encontrado.');
      else {
        Map<String, dynamic> product = {
          'CODPROD': int.parse(document.findAllElements('CODPROD').first.text),
          'DESCRPROD': document.findAllElements('DESCRPROD').first.text,
          'REFFORN': document.findAllElements('REFFORN').first.text,
          'ATIVO': document.findAllElements('ATIVO').first.text,
          'REFERENCIA': document.findAllElements('REFERENCIA').first.text,
          'CODVOL': document.findAllElements('CODVOL').first.text,
          'MARCA': document.findAllElements('MARCA').first.text,
          'IMAGEM': document.findAllElements('IMAGEM').first.text,
          'PRECO': double.parse(document.findAllElements('PRECO').first.text),
        };
        return product;
      }
    }
    return null;
  }

  Future<List<Map>> consultaProdutoEstoque(int codigo) async {
    List<Map> estoque = [];
    String _body = '''
<query viewName="AD_VIEW_WMS_CONSULTAESTOQUE" orderBy="RAZAOABREV,DESCRLOCAL">
<where>CODPROD = $codigo</where>
</query>
''';

    String _response =
        await this.service('CRUDServiceProvider.loadView', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      Iterable<XmlElement> records = document.findAllElements('record');
      records.forEach((element) {
        estoque.add({
          'CODPROD': int.parse(element.findAllElements('CODPROD').first.text),
          'CODEMP': int.parse(element.findAllElements('CODEMP').first.text),
          'RAZAOABREV': element.findAllElements('RAZAOABREV').first.text,
          'CODLOCAL': element.findAllElements('CODLOCAL').first.text,
          'DESCRLOCAL': element.findAllElements('DESCRLOCAL').first.text,
          'ESTOQUE':
              double.parse(element.findAllElements('ESTOQUE').first.text),
          'RESERVADO':
              double.parse(element.findAllElements('RESERVADO').first.text),
        });
      });
    }
    return estoque;
  }

  Future<List<Map>> consultaProdutoEndereco(int codigo) async {
    List<Map> endereco = [];
    String _body = '''
<query viewName="AD_VIEW_WMS_CONSULTAENDERECO" orderBy="RAZAOABREV">
<where>CODPROD = $codigo</where>
</query>
''';

    String _response =
        await this.service('CRUDServiceProvider.loadView', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      Iterable<XmlElement> records = document.findAllElements('record');
      records.forEach((element) {
        endereco.add({
          'CODPROD': int.parse(element.findAllElements('CODPROD').first.text),
          'CODEMP': int.parse(element.findAllElements('CODEMP').first.text),
          'RAZAOABREV': element.findAllElements('RAZAOABREV').first.text,
          'RUA': element.findAllElements('RUA').first.text,
          'PREDIO': element.findAllElements('PREDIO').first.text,
          'ANDAR': element.findAllElements('ANDAR').first.text,
          'ENDERECO': element.findAllElements('ENDERECO').first.text,
        });
      });
    }
    return endereco;
  }

  Future<int> insereContagem(int codprod, int qtdest) async {
/*****
 RETIREI DA TGFCTE PELA DIFICULDADE EM GERAR A SEQUENCIA
 *****
    String _body = '''
<dataSet rootEntity="ContagemEstoque" includePresentationFields="S"  datasetid="1444487520009_1">
  <entity path="">
    <fieldset list="*"/>
  </entity>
  <dataRow>
    <localFields>
      <DTCONTAGEM>28/07/2022</DTCONTAGEM>
      <CODEMP>1</CODEMP>
      <CODLOCAL>9000</CODLOCAL>
      <CODPROD>$codprod</CODPROD>
      <QTDEST>$qtdest</QTDEST>
      <CODPARC>0</CODPARC>
      <TIPO>P</TIPO>
      <QTDESTUNCAD>$qtdest</QTDESTUNCAD>
    </localFields>
  </dataRow>
</dataSet>''';
*/
    String dtcontagem = DateFormat('dd/MM/yyyy').format(DateTime.now());
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
}
