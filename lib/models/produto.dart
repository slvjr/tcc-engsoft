import 'package:xml/xml.dart';

class Produto {
  final int codprod;
  final String descrprod;
  final String refforn;
  final String ativo;
  final String referencia;
  final String codvol;
  final String marca;
  final String imagem;
  final double preco;

  Produto({
    this.codprod,
    this.descrprod,
    this.refforn,
    this.ativo,
    this.referencia,
    this.codvol,
    this.marca,
    this.imagem,
    this.preco,
  });

  factory Produto.fromXml(XmlElement document) {
    return Produto(
      codprod: int.parse(document.findElements('CODPROD').first.text),
      descrprod: document.findElements('DESCRPROD').first.text,
      refforn: document.findElements('REFFORN').first.text,
      ativo: document.findElements('ATIVO').first.text,
      referencia: document.findElements('REFERENCIA').first.text,
      codvol: document.findElements('CODVOL').first.text,
      marca: document.findElements('MARCA').first.text,
      imagem: document.findElements('IMAGEM').first.text,
      preco: double.parse(document.findElements('PRECO').first.text),
    );
  }

}
