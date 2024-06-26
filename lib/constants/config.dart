class Config {
  Config._();

  static const bool debug = true;

  static const String appName = "Coletor DigitalSat";
  static const String appLogo = "assets/images/logo.png";
  static const String loginBackground = "assets/images/login_bg.jpg";

  /* ERP */
  static const List baseUrl = [
    [
      "http://10.20.30.40:8880/mge/", // interno-producao
      "http://10.20.30.40:8882/mge/", // interno-teste
    ],
    [
      "http://200.100.50.25:8080/mge/", // externo-producao
      "http://200.100.50.25:8180/mge/", // externo-teste
    ],
  ];

  /* WMS */
  static const int equipTipo = 5; // coletor de dados
  static const int equipCodigo = 7;
}
