import 'package:xml/xml.dart';

class ProdutoEstoque {
  final int codprod;
  final int codemp;
  final String razaoabrev;
  final int codlocal;
  final String descrlocal;
  final int estoque;
  final int reservado;

  ProdutoEstoque({
    this.codprod,
    this.codemp,
    this.razaoabrev,
    this.codlocal,
    this.descrlocal,
    this.estoque,
    this.reservado,
  });

  factory ProdutoEstoque.fromXml(XmlElement document) {
    return ProdutoEstoque(
      codprod: int.parse(document.findElements('CODPROD').first.text),
      codemp: int.parse(document.findElements('CODEMP').first.text),
      razaoabrev: document.findElements('RAZAOABREV').first.text,
      codlocal: int.parse(document.findElements('CODLOCAL').first.text),
      descrlocal: document.findElements('DESCRLOCAL').first.text,
      estoque: int.parse(document.findElements('ESTOQUE').first.text),
      reservado: int.parse(document.findElements('RESERVADO').first.text),
    );
  }

}
