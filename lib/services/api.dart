/* 

Faz a conexão com o ERP

*/

library api;

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../services/prefs.dart';
import '../constants/config.dart';

final ApiService api = new ApiService._private();

class ApiService {
  // constructor
  ApiService._private() {
    setBaseUrl();
  }

  // config
  final String _serviceURL = "service.sbr?serviceName=";
  int _connIndex = 0;
  int _baseIndex = 0;
  String _baseURL = Config.baseUrl[0][0];

  String _token;
  int _id; // id do usuário
  String _idBase64;
  String _error;
  int _status; // resposta do webservice
  String _statusMessage; // resposta do webservice
  DateTime _last; // último uso

  // methods
  bool hasError() {
    return this._error?.isNotEmpty ?? false;
  }

  String getError() {
    if (getStatus() != null && getStatus() != 1 && hasStatusMessage())
      return getStatusMessage();
    else
      return this._error;
  }

  void setError(String error) {
    this._error = error;
  }

  int getStatus() {
    return this._status;
  }

  bool hasStatusMessage() {
    return this._statusMessage != null;
  }

  String getStatusMessage() {
    return this._statusMessage;
  }

  bool isActive() {
    return this._token != null;
  }

  void setBaseUrl([int $conn, int $base]) {
    if ($conn == null) $conn = Prefs.getInt('connection') ?? 0;
    if ($base == null) $base = Prefs.getInt('database') ?? 0;
    if (($conn == 0 || $conn == 1) && ($base == 0 || $base == 1)) {
      _connIndex = $conn;
      _baseIndex = $base;
      this._baseURL = Config.baseUrl[_connIndex][_baseIndex];
      Prefs.setInt("connection", _connIndex);
      Prefs.setInt("database", _baseIndex);
    }
  }

  int getConnection() {
    // índice da conexão (0/1)
    return _connIndex ?? 0;
  }

  int getDatabase() {
    // índice da base de dados (0/1)
    return _baseIndex ?? 0;
  }

  Future<String> checkCredencials(String user, String password) async {
    // alterado para String para retornar o CallID
    final passwordMd5 =
        md5.convert(utf8.encode(user.toUpperCase() + password)).toString();

    String body = '<NOMUSU>$user</NOMUSU>' +
        '<INTERNO2>$passwordMd5</INTERNO2>' +
        '<APARELHO>COLETORWMS</APARELHO>' +
        '<APARELHO_ID>20210422141928_0.877868175506592</APARELHO_ID>' +
        '<VERSAOCOLETOR>3.20.0b161</VERSAOCOLETOR>';

    var response = await serviceRequest("MobileLoginSP.login", body);
    print(_error);
    if (response != null) {
      final document = XmlDocument.parse(response);
      // checa se gerou id da sessão
      final jsessId = document.findAllElements('jsessionid');
      final callId = document.findAllElements('callID');
      if (jsessId.isNotEmpty && callId.isNotEmpty) {
        var sessionId = jsessId.single.text.trim();
        if (sessionId.isNotEmpty) {
          this.disconnect();
          return callId.single.text.trim();
        }
      }
    }

    return null;
  }

  Future<bool> connect() async {
    final user = Prefs.getString('username');
    final passwd = Prefs.getString('password');
    final passwdMd5 =
        md5.convert(utf8.encode(user.toUpperCase() + passwd)).toString();

    String body = '<NOMUSU>$user</NOMUSU>' +
        '<INTERNO2>$passwdMd5</INTERNO2>' +
        '<APARELHO>COLETORWMS</APARELHO>' +
        '<APARELHO_ID>20210422141928_0.877868175506592</APARELHO_ID>' +
        '<VERSAOCOLETOR>3.20.0b161</VERSAOCOLETOR>';

    var response = await serviceRequest("MobileLoginSP.login", body);

    if (response?.isNotEmpty ?? false) {
      final document = XmlDocument.parse(response);

      // checa se gerou id da sessão
      final docSessId = document.findAllElements('jsessionid');
      if (docSessId.isNotEmpty) {
        this._token = docSessId.single.text.trim();
        try {
          this._id = int.parse(latin1.decode(base64Decode(document
              .findAllElements('idusu')
              .single
              .text
              .replaceAll("\n", "")
              .trim())));
        } catch (e) {
          this._error = "ID do usuário inválida.";
          return false;
        }
        this._idBase64 = document
            .findAllElements('idusu')
            .single
            .text
            .replaceAll("\n", "")
            .trim();
        return true;
      } else {
        this._error = "Sessão do ERP inválida.";
        return false;
      }
    } else
      return false;
  }

  // kill the session with the ERP
  Future<bool> disconnect() async {
    if (this._token == null) return false;

    final String _serviceName = "MobileLoginSP.logout";
    final _serviceURL = "service.sbr?serviceName=$_serviceName";
    var _response;
    final String _body = '';

    try {
      final uri = Uri.parse(_baseURL + _serviceURL);
      final http.Response response = await http
          .post(
            uri,
            headers: <String, String>{
              'Cookie': 'JSESSIONID=' + this._token,
            },
            body: _body,
          )
          .timeout(Duration(seconds: 15));
      _response = response;
    } catch (e) {
      this._error = "Sem conexão com a rede.";
      return false;
    }

    if (_response.statusCode == 200) {
      final document = XmlDocument.parse(_response.body);
      // check if had error
      final statusMessage = document.findAllElements('statusMessage');
      if (statusMessage.isNotEmpty) {
        try {
          this._error = latin1.decode(base64Decode(
              statusMessage.single.text.replaceAll("\n", "").trim()));
        } catch (e) {
          this._error = "Dados de retorno inválidos.";
        }
        return false;
      }
    } else {
      this._error = "Falha ao comunicar com o ERP.";
      return false;
    }

    return true;
  }

  /*

  AQUI COMEÇA A INTERFACE NOVA 

  */

  Future<Map<String, dynamic>> login(String usuario, String senha) async {
    String _body = '<NOMUSU>TALITA</NOMUSU>' +
        '<INTERNO>123456</INTERNO>' +
        '<APARELHO>COLETORWMS</APARELHO>' +
        '<APARELHO_ID>20210422141928_0.877868175506592</APARELHO_ID>' +
        '<VERSAOCOLETOR>3.20.0b161</VERSAOCOLETOR>';

    String _response = await this.serviceRequest('MobileLoginSP.login', _body);

    if (_response != null) {
      final document = XmlDocument.parse(_response);
      var linha = document.findAllElements('linha').first;
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

  // atalho para serviceRequest onde checa se permanece conectado
  Future<String> service(String serviceName, String requestBody) async {
    // se a conexão não está ativa, reconecta
    if (!isActive()) {
      await connect();
    }

    // substitui {variaveis} no body
    requestBody = requestBody.replaceAll('{idBase64}', this._idBase64 ?? "");
    requestBody = requestBody.replaceAll('{idUsu}', this._id.toString() ?? "");

    // faz a consulta
    String response = await serviceRequest(serviceName, requestBody);
    if (_status == 3) {
      // se não está autorizado, tenta refazer a sessão e insistir
      await connect();
      response = await serviceRequest(serviceName, requestBody);
    }

    // atualiza o último uso
    _last = DateTime.now();

    // retorna a resposta
    return response;
  }

  Future<String> serviceRequest(String serviceName, String requestBody) async {
    if (Config.debug) print("════════════╡ $serviceName ╞════════════");
    String callId;
    String url = _baseURL + _serviceURL + serviceName;

    // reseta variáveis da sessão
    this._error = "";
    this._status = null;
    this._statusMessage = "";

    // header da chamada
    Map<String, String> _headers = {
      'Content-Type': 'text/xml;charset=ISO-8859-1',
    };
    // se não está fazendo login...
    if (serviceName != "MobileLoginSP.login") {
      // ...precisa informar a JSESSIONID
      _headers['Cookie'] = 'JSESSIONID=' + this._token;
      // ...também o CallID
      int callidCount = Prefs.getInt('callid_count');
      if (callidCount == null) callidCount = 1;
      callidCount++;
      callId = "&callID=" +
          (Prefs.getString('callid') ?? "") +
          "_" +
          callidCount.toString();
      Prefs.setInt('callid_count', callidCount);
      url += callId;
    }

    // monta o body
    String _body = '<?xml version="1.0" encoding="ISO-8859-1"?>' +
        '<serviceRequest serviceName="$serviceName">' +
        '<requestBody>' +
        requestBody +
        '</requestBody>' +
        '</serviceRequest>';
    var _response;

    if (Config.debug) print(_body);

    try {
      final uri = Uri.parse(url);
      final http.Response response = await http
          .post(
            uri,
            headers: _headers,
            body: _body,
          )
          .timeout(Duration(seconds: 15));
      _response = response;
    } catch (e) {
      this._error = "Sem conexão com a rede.";
    }

    if (!hasError()) {
      if (_response.statusCode == 200) {
        final document = XmlDocument.parse(_response.body);
        var serviceResponse = document.findAllElements('serviceResponse').first;
        this._status =
            int.tryParse(serviceResponse.getAttribute('status')) ?? null;
        final statusMessage = document.findAllElements('statusMessage');
        if (statusMessage.isNotEmpty) {
          try {
            this._statusMessage = latin1.decode(base64Decode(
                statusMessage.single.text.replaceAll("\n", "").trim()));
            // pega a mensagem de erro gerada pelo ERP
            if (this._status != 1) this._error = this._statusMessage;
          } catch (e) {
            this._error = "Ocorreu um erro não especificado.";
          }
        } else {
          final responseBody = document.findAllElements('responseBody');
          if (responseBody == null) {
            this._error = "Nenhum registro encontrado.";
          } else {
            this._error = "";
          }
        }
      } else {
        this._error = "Falha ao comunicar com o ERP.";
      }
    }

    if (Config.debug) {
      print(_response?.body ?? "<!-- Sem resposta -->");
      print('════════════════════════════════════════');
    }

    if (hasError())
      return null;
    else
      return _response?.body ?? "";
  }
}
